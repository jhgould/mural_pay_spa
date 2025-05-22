class AccountsController < ApplicationController 
  
  def new 
  end 

  def create 
    account = MuralPay::CreateAccount.new(name: account_params["name"], description: account_params["description"]).call
    
    respond_to do |format|
      if account
        format.html { redirect_to root_path, flash: { notice: 'Account created successfully.' } }
        format.turbo_stream { 
          flash.now[:notice] = 'Account created successfully.'
        }
      else 
        format.html { render :new }
        format.turbo_stream { 
          flash.now[:alert] = 'Failed to create account.'
          render turbo_stream: turbo_stream.replace('new-account-form', partial: 'accounts/form')
        }
      end
    end
  end 

  private 

  def account_params
    params.permit(:name, :description)
  end 

end 