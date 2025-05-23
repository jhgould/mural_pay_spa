require 'rails_helper' 

RSpec.feature 'User creates payment request', type: :feature do 
  before do 
    allow_any_instance_of(MuralPay::GetPayoutRequest).to receive(:call).and_return(
      {
          "id": "7e979839-7d43-42c8-83b8-c2eae1dcecf4",
          "createdAt": "2025-05-23T01:19:38.449Z",
          "updatedAt": "2025-05-23T01:19:38.449Z",
          "transactionHash": "0x574a4c02814355e60441fd92a518ccd9a753eed93da38bbd397db91c92790f01",
          "sourceAccountId": "39a4f7b5-7663-49d8-87be-a0afdf4c204c",
          "memo": "December contract",
          "status": "EXECUTED",
          "payouts": [
              {
                  "id": "7f499808-86e5-4d03-95ac-209acfe228db",
                  "createdAt": "2025-05-23T01:19:38.454Z",
                  "updatedAt": "2025-05-23T03:54:39.246Z",
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
                          "type": "pending",
                          "initiatedAt": "2025-05-23T03:55:04.269Z"
                      }
                  }
              }
          ]
      }
    )

    allow_any_instance_of(MuralPay::CreateAccount).to receive(:call).and_return(
      {
        id: 'fake-id-123',
        name: 'Test Account',
        status: 'INITIALIZING',
        isApiEnabled: true
      }
    )

    allow_any_instance_of(MuralPay::GetAccounts).to receive(:call).and_return([
      {
        id: "12345-abc",
        name: "Test Account",
        status: "ACTIVE",
        isApiEnabled: true,
        updatedAt: Time.now.iso8601,
        accountDetails: {
          balances: [{ tokenAmount: 1000, tokenSymbol: "USDC" }],
          walletDetails: {
            walletAddress: "0xTestWalletAddress",
            blockchain: "POLYGON"
          },
          depositAccount: {
            id: "dep-123",
            accountId: "12345-abc",
            status: "ACTIVATED",
            currency: "USD",
            bankName: "Test Bank",
            bankAccountNumber: "123456789",
            bankRoutingNumber: "987654321",
            paymentRails: ["ACH_PUSH", "WIRE"]
          }
        }
      }
    ])

    allow_any_instance_of(MuralPay::CreatePayout).to receive(:call).and_return(
      {
        id: "db28d5c2-1fb4-4efd-9a90-37f1fc629221",
        createdAt: "2025-05-22T21:53:39.984Z",
        updatedAt: "2025-05-22T21:53:39.984Z",
        sourceAccountId: "0451124b-ca4e-4d6a-8ba2-76f70df431cf",
        status: "AWAITING_EXECUTION",
        payouts: [
          {
            id: "65687973-a6fa-487d-9188-02cc50567191",
            createdAt: "2025-05-22T21:53:39.990Z"
          }
        ]
      }
    )

    allow_any_instance_of(MuralPay::ExecutePayoutRequest).to receive(:call).and_return(
      {
        id: "e5728f35-f13e-45a2-ba38-144da973938a",
        createdAt: "2025-04-05T04:24:03.862Z",
        updatedAt: "2025-04-05T04:24:03.862Z",
        sourceAccountId: "5d75e362-0812-4ea8-b203-c7c3a09f8473",
        memo: "December Contract",
        status: "PENDING",
        payouts: [
          {
            id: "34998641-c981-44bc-beda-14b930999284",
            createdAt: "2025-04-05T04:24:03.869Z",
            updatedAt: "2025-04-05T04:24:03.869Z",
            amount: {
              tokenSymbol: "USDC",
              tokenAmount: 100
            },
            details: {
              type: "fiat",
              fiatAndRailCode: "cop",
              fiatAmount: {
                fiatAmount: 305421.23,
                fiatCurrencyCode: "COP"
              },
              transactionFee: {
                tokenSymbol: "USDC",
                tokenAmount: 0.35
              },
              exchangeFeePercentage: 1.4,
              exchangeRate: 3108.613065,
              feeTotal: {
                tokenSymbol: "USDC",
                tokenAmount: 1.75
              },
              fiatPayoutStatus: {
                type: "created"
              }
            }
          }
        ]
      }
    )

    Account.create(
      account_source_id: '12345-abc'
    )
  end 

  scenario "user creates and executes a payment request" do
    visit root_path


    click_button '+ New Account'
    fill_in 'Account Name', with: 'Test Account'
    fill_in 'Description', with: 'This is a test account'
    click_button 'Create Account'

    click_link 'Create Payout Request'
    fill_in 'Token Symbol', with: 'USDC'
    fill_in 'Token Amount', with: '100.00'
    fill_in 'Bank Name', with: 'BANK'
    fill_in 'Bank Account Owner', with: 'John Doe'
    fill_in 'Fiat Type', with: 'cop'
    fill_in 'Fiat Symbol', with: 'COP'
    select 'Checking', from: 'Account Type'
    fill_in 'Phone Number', with: '1234567890'
    fill_in 'Bank Account Number', with: '123456789'
    fill_in 'Document Number', with: '123456789'
    select 'National ID', from: 'Document Type'
    fill_in 'First Name', with: 'first name test name'
    fill_in 'Last Name', with: 'last name test name'
    fill_in 'Email', with: 'test@email.com'
    fill_in 'Date of Birth', with: '1990-01-01'
    fill_in 'Address', with: '123 Test St'
    fill_in 'Country', with: 'Test Country'
    fill_in 'State', with: 'Test State'
    fill_in 'City', with: 'Test City'
    fill_in 'Zip Code', with: '12345'
    
    click_button 'Create Payout Request'


    click_button 'Approve' 
    expect(page).to have_content('EXECUTED')

  end 


end