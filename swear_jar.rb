require 'rest-client'
require 'sinatra/base'

class SwearJar < Sinatra::Application
  class Bank
    class Exception < RuntimeError; end

    BASE_URL = 'https://api.bnk.dev'.freeze

    def headers
      {
        authorization: "Bearer #{api_key}",
        content_type: :json,
      }
    end

    def api_key
      @api_key ||= ENV['BANK_API_KEY']
    end

    def execute_request_and_parse_response(request)
      response = request.execute
      JSON.parse(response.body, symbolize_names: true)
    rescue RestClient::ExceptionWithResponse => e
      puts e.response.body
      raise Exception
    end

    def accounts
      request = RestClient::Request.new(
        headers: headers,
        method: :get,
        url: "#{BASE_URL}/accounts",
      )
      execute_request_and_parse_response(request).dig(:data)
    end

    def account!(name:)
      request = RestClient::Request.new(
        headers: headers,
        method: :post,
        payload: { name: name }.to_json,
        url: "#{BASE_URL}/accounts",
      )
      execute_request_and_parse_response(request)
    end

    def transfer!(account_id:, swear_jar_id:, amount:, description:)
      request = RestClient::Request.new(
        headers: headers,
        method: :post,
        payload: transfer_payload(amount, description, swear_jar_id),
        url: "#{BASE_URL}/accounts/#{account_id}/transfers/accounts",
      )
      execute_request_and_parse_response(request)
    end

    def transfer_payload(amount, description, swear_jar_id)
      {
        amount: amount,
        description: description,
        destination_account_id: swear_jar_id,
      }.to_json
    end
  end

  DESCRIPTION = 'Swear jar fine'.freeze
  FINE_AMOUNT = 25
  SWEAR_JAR_NAME = 'Swear jar'.freeze

  enable :sessions

  helpers do # rubocop:disable Metrics/BlockLength
    def bank
      @bank ||= Bank.new
    end

    def bank_account_id
      @bank_account_id ||= ENV['BANK_ACCOUNT_ID']
    end

    def bank_api_key
      @bank_api_key ||= ENV['BANK_API_KEY']
    end

    def populate_session
      session_data_to_carry_forward = {
        show_confirmation_flash: session[:show_confirmation_flash],
      }
      session.clear
      session.merge!(session_data_to_carry_forward)

      if bank_api_key
        populate_account_data
      else
        session[:show_api_key_flash] = true
      end
    end

    def populate_account_data
      accounts =
        bank.accounts.map { |account| account.slice(:id, :name, :balance) }

      bank_account = accounts.find { |account| account[:id] == bank_account_id }
      if bank_account
        session[:account] = bank_account
      else
        session[:accounts] = accounts
      end

      swear_jar = accounts.find { |account| account[:name] == SWEAR_JAR_NAME }
      session[:swear_jar] = swear_jar
    end
  end

  get '/' do
    populate_session
    erb :index
  end

  post '/jar' do
    bank.account!(name: SWEAR_JAR_NAME)
    redirect '/'
  end

  post '/jar/swear' do
    session[:show_confirmation_flash] = false
    bank.transfer!(
      account_id: bank_account_id || @params[:account_id],
      amount: FINE_AMOUNT,
      description: DESCRIPTION,
      swear_jar_id: session[:swear_jar]&.dig(:id),
    )
    session[:show_confirmation_flash] = true
    redirect '/'
  rescue Bank::Exception
    redirect '/'
  end
end

SwearJar.run! if $PROGRAM_NAME == __FILE__
