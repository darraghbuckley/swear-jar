require "#{__dir__}/../test_helper"

describe SwearJar do
  include Rack::Test::Methods

  def app
    SwearJar
  end

  describe '/' do
    it 'accepts a request' do
      response_stub = instance_double(
        RestClient::Response,
        body: [
          { id: 'account0', name: 'Account', balance: 101 },
        ].to_json,
      )
      expect_any_instance_of(RestClient::Request).to receive(:execute)
        .and_return(response_stub)
      response = get '/'
      expect(response.status).to eq(200)
    end

    it 'gracefully handles failures' do
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
      expect(response.status).to eq(200)
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
  end
end
