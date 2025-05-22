require 'rails_helper'

RSpec.describe MuralPay::CreatePayout do
  let(:account_id) { 'abc-123' }
  let(:payload) do
    {
      "sourceAccountId": "faec0c01-a0fa-4643-ad40-16ca4c60904c",
      "memo": "December contract",
      "payouts": [
        {
          "amount": {
            "tokenSymbol": "USDC",
            "tokenAmount": 100
          },
          "payoutDetails": {
            "type": "fiat",
            "bankName": "Bancamia S.A.",
            "bankAccountOwner": "test",
            "fiatAndRailDetails": {
                "type": "cop",
                "symbol": "COP",
                "accountType": "CHECKING",
                "phoneNumber": "+57 601 555 5555",
                "bankAccountNumber": "1234567890123456",
                "documentNumber": "1234563",
                "documentType": "NATIONAL_ID"
              }
          },
          "recipientInfo": {
            "type": "individual",
            "firstName": "Javier",
            "lastName": "Gomez",
            "email": "jgomez@gmail.com",
            "dateOfBirth": "1980-02-22",
            "physicalAddress": {
              "address1": "Cra. 37 #10A 29",
              "country": "CO",
              "state": "Antioquia",
              "city": "Medellin",
              "zip": "050015"
            }
          }
        }
      ]
    }
  end 
  let(:response_body) do
    {
      "id": "37f8cfcd-e05d-4003-b77d-840f0decbbbe",
      "createdAt": "2025-05-22T17:18:16.100Z",
      "updatedAt": "2025-05-22T17:18:16.100Z",
      "sourceAccountId": "faec0c01-a0fa-4643-ad40-16ca4c60904c",
      "memo": "December contract",
      "status": "AWAITING_EXECUTION",
      "payouts": [
          {
              "id": "47e737e3-c7b5-46dd-b668-35d0d19b5e8a",
              "createdAt": "2025-05-22T17:18:16.105Z",
              "updatedAt": "2025-05-22T17:18:16.105Z",
              "amount": {
                  "tokenSymbol": "USDC",
                  "tokenAmount": 100
              },
              "details": {
                  "type": "fiat",
                  "fiatAndRailCode": "cop",
                  "fiatAmount": {
                      "fiatAmount": 305421.23,
                      "fiatCurrencyCode": "COP"
                  },
                  "transactionFee": {
                      "tokenSymbol": "USDC",
                      "tokenAmount": 0.35
                  },
                  "exchangeFeePercentage": 1.4,
                  "exchangeRate": 3108.613065,
                  "feeTotal": {
                      "tokenSymbol": "USDC",
                      "tokenAmount": 1.75
                  },
                  "fiatPayoutStatus": {
                      "type": "created"
                  }
              }
          }
        ]
      }
  end

  before do
    stub_request(:post, 'https://api-staging.muralpay.com/api/payouts/payout')
      .with(
        body: payload.to_json,
        headers: {
          'Authorization' => "Bearer #{Rails.application.credentials[:mural_pay][:api_key]}",
          'transfer-api-key' => Rails.application.credentials[:mural_pay][:transfer_api_key],
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      ).to_return(status: 200, body: response_body.to_json, headers: {})
  end

  it 'returns parsed payout data' do
    result = JSON.parse(described_class.new(payload).call)
    expect(result["id"]).to eq('37f8cfcd-e05d-4003-b77d-840f0decbbbe')
    expect(result["status"]).to eq('AWAITING_EXECUTION')
  
  end

  it 'raises an error when the API response is unsuccessful' do
    stub_request(:post, 'https://api-staging.muralpay.com/api/payouts/payout')
      .to_return(status: 400, body: { error: 'Bad Request' }.to_json)

    expect {
      described_class.new(payload).call
    }.to raise_error(RuntimeError, /Mural API error \(400\)/)
  end
end
