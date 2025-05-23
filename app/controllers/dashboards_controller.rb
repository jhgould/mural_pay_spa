class DashboardsController < ApplicationController 

  def index
    api_accounts = MuralPay::GetAccounts.new.call
    local_account_ids = Account.pluck(:account_source_id).to_set

    @accounts = api_accounts.select { |account| local_account_ids.include?(account[:id]) }
  end

end 