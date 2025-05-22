require 'rails_helper'


RSpec.feature 'User creates account', type: :feature do
  scenario 'User fills in the form and submits' do

    allow_any_instance_of(MuralPay::CreateAccount).to receive(:call).and_return(
      {
        id: 'fake-id-123',
        name: 'Test Account',
        status: 'INITIALIZING',
        isApiEnabled: true
      }
    )

    stub_request(:get, "https://api-staging.muralpay.com/api/accounts").
      to_return(
        status: 200,
        body: [].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    visit new_account_path

    fill_in 'Name', with: 'Test Account'
    fill_in "Description", with: 'This is a test account' 

    click_button 'Create Account'

    expect(page).to have_content('Account created successfully.')

  end 

end 