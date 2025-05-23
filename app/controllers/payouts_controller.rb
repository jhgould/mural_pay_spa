class PayoutsController < ApplicationController
  def new
  end
  
  def execute
    payout_id = params[:id]
    
    begin
      # Call the API to execute the payout
      MuralPay::ExecutePayoutRequest.new(id: payout_id).call
      
      respond_to do |format|
        format.html { 
          flash[:notice] = "Payout #{payout_id} execution initiated successfully!"
          redirect_to root_path
        }
        format.turbo_stream {
          flash.now[:notice] = "Payout #{payout_id} execution initiated successfully!"
        }
      end
    rescue => e
      respond_to do |format|
        format.html { 
          flash[:alert] = "Error executing payout: #{e.message}"
          redirect_to root_path
        }
        format.turbo_stream {
          flash.now[:alert] = "Error executing payout: #{e.message}"
        }
      end
    end
  end

  def create
    account_id = params[:account_id]
    payload = {
      "sourceAccountId": account_id,
      "payouts": [
        {
          "amount": {
            "tokenSymbol": params[:token_symbol],
            "tokenAmount": params[:token_amount].to_f
          },
          "payoutDetails": {
            "type": params[:payout_type],
            "bankName": params[:bank_name],
            "bankAccountOwner": params[:bank_account_owner],
            "fiatAndRailDetails": {
              "type": params[:fiat_type],
              "symbol": params[:fiat_symbol],
              "accountType": params[:account_type],
              "phoneNumber": params[:phone_number],
              "bankAccountNumber": params[:bank_account_number],
              "documentNumber": params[:document_number],
              "documentType": params[:document_type]
            }
          },
          "recipientInfo": {
            "type": params[:recipient_type],
            "firstName": params[:first_name],
            "lastName": params[:last_name],
            "email": params[:email],
            "dateOfBirth": params[:date_of_birth],
            "physicalAddress": {
              "address1": params[:address],
              "country": params[:country],
              "state": params[:state],
              "city": params[:city],
              "zip": params[:zip]
            }
          }
        }
      ]
    }

    result = MuralPay::CreatePayout.new(payload).call
    
    respond_to do |format|
      if result
        @account = Account.find_by(account_source_id: account_id)
        @created_payout_request = PayoutRequest.create(payout_request_id: result[:id], account: @account)
        
        # Get the payout details for the Turbo Stream response
        begin
          @payout_details = MuralPay::GetPayoutRequest.new(id: result[:id]).call
        rescue => e
          Rails.logger.error("Error fetching created payout request: #{e.message}")
          @payout_details = nil
        end
        
        format.html { redirect_to root_path, flash: { notice: 'Payout request created successfully.' } }
        format.turbo_stream { 
          flash.now[:notice] = 'Payout request created successfully.'
          render turbo_stream: turbo_stream.replace('payout-request-details', partial: 'payouts/payout_request_details', locals: { payout_details: @payout_details })
        }
      else
        format.html { redirect_to root_path, flash: { alert: 'Failed to create payout request.' } }
        format.turbo_stream { 
          flash.now[:alert] = 'Failed to create payout request.'
        }
      end
    end
  end


  private

  def payout_params
    params.permit(
      :account_id,
      :token_symbol,
      :token_amount,
      :payout_type,
      :bank_name,
      :bank_account_owner,
      :fiat_type,
      :fiat_symbol,
      :account_type,
      :phone_number,
      :bank_account_number,
      :document_number,
      :document_type,
      :recipient_type,
      :first_name,
      :last_name,
      :email,
      :date_of_birth,
      :address,
      :country,
      :state,
      :city,
      :zip
    )
  end
    
end
