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
    account_id = params[:sourceAccountId]
    memo = params[:memo]
    payload = {
      "sourceAccountId": account_id,
      "memo": memo,
      "payouts": [
        {
          "amount": {
            "tokenSymbol": params[:tokenSymbol],
            "tokenAmount": params[:tokenAmount].to_f
          },
          "payoutDetails": {
            "type": params[:type],
            "bankName": params[:bankName],
            "bankAccountOwner": params[:bankAccountOwner],
            "fiatAndRailDetails": {
              "type": params[:fiatType],
              "symbol": params[:fiatSymbol],
              "accountType": params[:accountType],
              "phoneNumber": params[:phoneNumber],
              "bankAccountNumber": params[:bankAccountNumber],
              "documentNumber": params[:documentNumber],
              "documentType": params[:documentType]
            }
          },
          "recipientInfo": {
            "type": params[:recipientType],
            "firstName": params[:firstName],
            "lastName": params[:lastName],
            "email": params[:email],
            "dateOfBirth": params[:dateOfBirth],
            "physicalAddress": {
              "address1": params[:address1],
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
      :sourceAccountId,
      :memo,
      :tokenSymbol,
      :tokenAmount,
      :type,
      :bankName,
      :bankAccountOwner,
      :fiatType,
      :fiatSymbol,
      :accountType,
      :phoneNumber,
      :bankAccountNumber,
      :documentNumber,
      :documentType,
      :recipientType,
      :firstName,
      :lastName,
      :email,
      :dateOfBirth,
      :address1,
      :country,
      :state,
      :city,
      :zip
    )
  end
    
end
