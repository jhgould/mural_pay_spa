require 'rails_helper'

RSpec.describe MuralPay::CreateAccount do
  describe '#call' do
    let(:account_name) { 'Interview Test Account' }
    let (:description) { 'This is a test account for interview purposes.' }
    let(:api_url) { 'https://api-staging.muralpay.com/api/accounts' }
    let(:fake_response) do
      {
        id: '4175b9f5-009d-4eb9-8303-c62f25aa603a',
        status: 'INITIALIZING',
        createdAt: '2025-05-22T03:37:26.125Z',
        updatedAt: '2025-05-22T03:37:26.125Z',
        name: account_name,
        isApiEnabled: true
      }
    end

    before do
      stub_request(:post, api_url)
        .with(
          body: { name: account_name, description: description }.to_json,
          headers: {
            'Authorization' => "Bearer #{Rails.application.credentials[:mural_pay][:api_key]}",
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        )
        .to_return(status: 200, body: fake_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the parsed response with account data' do
      result = MuralPay::CreateAccount.new(name: account_name, description: description).call

      expect(result).to include(
        id: a_string_matching(/\A[0-9a-f-]+\z/),
        name: account_name,
        status: 'INITIALIZING',
        isApiEnabled: true
      )
    end
  end
end
