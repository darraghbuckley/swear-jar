require "#{__dir__}/../test_helper"

describe SwearJar do
  include Rack::Test::Methods

  def app
    SwearJar
  end

  describe '/' do
    it 'accepts a request' do
      expect_any_instance_of(app).to receive(:bank_api_key)
        .and_return('api_key')
      response_stub = instance_double(
        RestClient::Response,
        body: {
          data: [{ id: 'account0', name: 'Account', balance: 101 }],
        }.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_return(response_stub)
      response = get '/'
      expect(response.status).to eq(200)
    end

    it 'accepts a request without BANK_API_KEY' do
      response = get '/'
      expect(response.status).to eq(200)
    end

    it 'accepts a request with BANK_ACCOUNT_ID' do
      account_id = 'account0'
      expect_any_instance_of(app).to receive(:bank_api_key)
        .and_return('api_key')
      expect_any_instance_of(app).to receive(:bank_account_id)
        .and_return(account_id)
      response_stub = instance_double(
        RestClient::Response,
        body: {
          data: [{ id: account_id, name: 'Account', balance: 101 }],
        }.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_return(response_stub)
      response = get '/'
      expect(response.status).to eq(200)
    end

    it 'gracefully handles failures' do
      expect_any_instance_of(app).to receive(:bank_api_key)
        .and_return('api_key')
      response_stub = instance_double(
        RestClient::Response,
        body: {}.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_raise(RestClient::ExceptionWithResponse, response_stub)
      response = get '/'
      expect(response.status).to eq(500)
    end
  end

  describe '/jar' do
    it 'accepts a request and redirects' do
      response_stub = instance_double(
        RestClient::Response,
        body: { id: 'account0', name: 'Account', balance: 101 }.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_return(response_stub)
      response = post '/jar'
      expect(response.status).to eq(302)
    end
  end

  describe '/jar/swear' do
    it 'accepts a request and redirects' do
      response_stub = instance_double(
        RestClient::Response,
        body: { id: 'account0', name: 'Account', balance: 101 }.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_return(response_stub)
      response = post '/jar/swear'
      expect(response.status).to eq(302)
    end

    it 'gracefully handles failures' do
      response_stub = instance_double(
        RestClient::Response,
        body: {}.to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_raise(RestClient::ExceptionWithResponse, response_stub)
      response = post '/jar/swear'
      expect(response.status).to eq(302)
    end
  end
end
