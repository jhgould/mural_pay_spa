require 'rails_helper'

RSpec.describe MuralPay::CreatePayout do
  let(:account_id) { 'abc-123' }
  let(:payload) do
    {
      sourceAccountId: account_id,
      payouts: [
        {
          amount: {
            tokenAmount: 1000,
            tokenSymbol: 'USDC'
          },
          payoutDetails: {
            type: 'fiat',
            bankName: 'Test Bank',
            bankAccountOwner: 'Test Owner'
          },
          recipientInfo: {
            type: 'individual',
            firstName: 'John',
            lastName: 'Doe',
            email: 'test@email.com',
            dateOfBirth: '1990-01-01',
            physicalAddress: {
              address1: '123 Main St',
              country: 'US',
              state: 'CA',
              city: 'Los Angeles',
              zip: '90001'
            }
          }
        }
      ],
      memo: 'Test payout'
    }
  end

  let(:response_body) do
    {
      id: '123',
      status: 'PENDING',
      memo: 'Test payout'
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
    expect(result["id"]).to eq('123')
    expect(result["status"]).to eq('PENDING')
    expect(result["memo"]).to eq('Test payout')
  end

  it 'raises an error when the API response is unsuccessful' do
    stub_request(:post, 'https://api-staging.muralpay.com/api/payouts/payout')
      .to_return(status: 400, body: { error: 'Bad Request' }.to_json)

    expect {
      described_class.new(payload).call
    }.to raise_error(RuntimeError, /Mural API error \(400\)/)
  end
end
