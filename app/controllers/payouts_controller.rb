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
    if result 
      @account = Account.find_by(account_source_id: account_id)
      @created_payout_request = PayoutRequest.create(payout_request_id: result[:id], account: @account)
      redirect_to payouts_path(@account.account_source_id), flash: { notice: 'Payout request created successfully.' }
    end 
  end



  def index
    account_id = params["format"]
    payout_requests = Account.find_by(account_source_id: account_id).payout_requests
    @payout_request_details = payout_requests.map do |payout_request|
       MuralPay::GetPayoutRequest.new(id: payout_request.payout_request_id).call
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
