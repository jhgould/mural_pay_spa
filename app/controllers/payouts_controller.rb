class PayoutsController < ApplicationController
  def new
  end
  
  def create
    account_id = params[:sourceAccountId]
    memo = params[:memo]
    if  params[:translate_memo] == "main_language"
      translated_memo = OpenAi::OpenAiService.new.translate(params[:memo], language: params[:country]) 
    elsif params[:translate_memo] == "other_language"
      translated_memo = OpenAi::OpenAiService.new.translate(params[:memo], language: params[:translate_memo_language]) 
    else 
      translated_memo = ""
    end 
    payload = {
      "sourceAccountId": account_id,
      "memo": {memo: memo, translated_memo: translated_memo}.to_s,
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

    begin
      result = MuralPay::CreatePayout.new(payload).call
      if result
        @account = Account.find_by(account_source_id: account_id)
        @created_payout_request = PayoutRequest.create(payout_request_id: result[:id], account: @account)
        redirect_to payouts_path(@account.account_source_id), flash: { notice: 'Payout request created successfully.' }
      end
    rescue MuralPay::MuralPayApiError => e
      error_message = parse_mural_error_message(e.body) || "There was a problem creating your payout."
      respond_to do |format|
        format.html { redirect_to root_path, alert: error_message }
        format.turbo_stream { redirect_to root_path, alert: error_message }
      end
    end
  end 


  def index
    account_id = params["format"]
    payout_requests = Account.find_by(account_source_id: account_id).payout_requests
    @payout_request_details = payout_requests.map do |payout_request|
       MuralPay::GetPayoutRequest.new(id: payout_request.payout_request_id).call
    end 
  end 

  def execute
    account = PayoutRequest.find_by(payout_request_id: params[:id]).account
  
    begin
      MuralPay::ExecutePayoutRequest.new(id: params[:id]).call
      flash[:notice] = 'Payout request executed successfully.'
    rescue MuralPay::MuralPayApiError => e
      error_message = parse_mural_error_message(e.body) || "There was a problem executing your payout."
      flash[:alert] = error_message
    end
  
    redirect_to payouts_path(account.account_source_id)
  end
  
  private
  
  def parse_mural_error_message(body)
    if body.is_a?(Hash) && body["message"]
      body["message"]
    elsif body.is_a?(Hash) && body[:message]
      body[:message]
    elsif body.is_a?(String)
      begin
        json = JSON.parse(body)
        json["message"] || json[:message]
      rescue
        nil
      end
    else
      nil
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
