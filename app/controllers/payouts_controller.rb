class PayoutsController < ApplicationController
  before_action :set_account, only: [:index]
  before_action :set_payout_request, only: [:execute]

  def new
  end
  
  def create
    account = Account.find_by!(account_source_id: payout_params[:sourceAccountId])
    result = PayoutService.new(payout_params, account).create_payout

    if result[:success]
      redirect_to payouts_path(account.account_source_id), notice: 'Payout request created successfully.'
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: result[:error] }
        format.turbo_stream { redirect_to root_path, alert: result[:error] }
      end
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Account not found.' }
      format.turbo_stream { redirect_to root_path, alert: 'Account not found.' }
    end
  end


  def index
    @payout_request_details = @account.payout_requests.map do |payout_request|
      MuralPay::GetPayoutRequest.new(id: payout_request.payout_request_id).call
    end
  rescue MuralPay::MuralPayApiError => e
    flash.now[:alert] = "Error fetching payout requests"
    @payout_request_details = []
  end 

  def execute
    MuralPay::ExecutePayoutRequest.new(id: params[:id]).call
    flash[:notice] = 'Payout request executed successfully.'
    redirect_to payouts_path(@payout_request.account.account_source_id)
  rescue MuralPay::MuralPayApiError => e
    flash[:alert] = "There was a problem executing your payout: #{e.body[:message]}"
    redirect_to payouts_path(@payout_request.account.account_source_id)
  end
  
  private

  def set_account
    @account = Account.find_by!(account_source_id: params[:format])
  end

  def set_payout_request
    @payout_request = PayoutRequest.find_by!(payout_request_id: params[:id])
  end

  def payout_params
    params.except(:authenticity_token, :commit, :controller, :action).permit(
      :sourceAccountId,
      :memo,
      :translate_memo,
      :translate_memo_language,
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
