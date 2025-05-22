class DashboardsController < ApplicationController 

  def index
    @accounts = MuralPay::GetAccounts.new.call
  end 

end 