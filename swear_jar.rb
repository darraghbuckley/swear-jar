require 'rest-client'
require 'sinatra/base'

class SwearJar < Sinatra::Application
  class Bank
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
    end

    def accounts
      request = RestClient::Request.new(
        headers: headers,
        method: :get,
        url: "#{BASE_URL}/accounts",
      )
      execute_request_and_parse_response(request)
    end

    def account!(entity_id:, name:)
      request = RestClient::Request.new(
        headers: headers,
        method: :post,
        payload: {
          entity_id: entity_id,
          name: name,
        }.to_json,
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

  helpers do
    def bank
      @bank ||= Bank.new
    end

    def populate_session
      accounts = bank.accounts.map do |account|
        account.slice(:id, :name, :balance)
      end

      swear_jar = accounts.find do |account|
        account[:name] == SWEAR_JAR_NAME
      end

      session[:accounts] = accounts
      session[:swear_jar] = swear_jar
    end
  end

  get '/' do
    populate_session
    erb :index
  end

  post '/jar' do
    entity_id = session.dig(:accounts, 0, :entity_id)
    bank.account!(entity_id: entity_id, name: SWEAR_JAR_NAME)
    content_type :json
    halt 200
  end

  post '/jar/swear' do
    account_id = @params[:account_id]
    bank.transfer!(
      account_id: account_id,
      amount: FINE_AMOUNT,
      description: DESCRIPTION,
      swear_jar_id: session[:swear_jar]&.dig(:id),
    )
    session[:account_id] = account_id
    session[:show_confirmation_flash] = true
    redirect '/'
  end
end

SwearJar.run! if $PROGRAM_NAME == __FILE__
