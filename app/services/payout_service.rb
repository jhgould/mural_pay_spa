class PayoutService
  def initialize(params, account)
    @params = params
    @account = account
  end

  def create_payout
    translated_memo = translate_memo
    payload = build_payload(translated_memo)
    
    result = MuralPay::CreatePayout.new(payload).call
    if result
      create_payout_request(result[:id])
      { success: true, id: result[:id], account: @account }
    end
  rescue MuralPay::MuralPayApiError => e
    { success: false, error: parse_mural_error_message(e.body) }
  end

  private

  attr_reader :params

  def translate_memo
    case params[:translate_memo]
    when "main_language"
      OpenAi::OpenAiService.new.translate(params[:memo], language: params[:country])
    when "other_language"
      OpenAi::OpenAiService.new.translate(params[:memo], language: params[:translate_memo_language])
    else
      ""
    end
  end

  def build_payload(translated_memo)
    {
      sourceAccountId: params[:sourceAccountId],
      memo: { memo: params[:memo], translated_memo: translated_memo }.to_s,
      payouts: [build_payout_details]
    }
  end

  def build_payout_details
    {
      amount: {
        tokenSymbol: params[:tokenSymbol],
        tokenAmount: params[:tokenAmount].to_f
      },
      payoutDetails: {
        type: params[:type],
        bankName: params[:bankName],
        bankAccountOwner: params[:bankAccountOwner],
        fiatAndRailDetails: build_fiat_details
      },
      recipientInfo: build_recipient_info
    }
  end

  def build_fiat_details
    {
      type: params[:fiatType],
      symbol: params[:fiatSymbol],
      accountType: params[:accountType],
      phoneNumber: params[:phoneNumber],
      bankAccountNumber: params[:bankAccountNumber],
      documentNumber: params[:documentNumber],
      documentType: params[:documentType]
    }
  end

  def build_recipient_info
    {
      type: params[:recipientType],
      firstName: params[:firstName],
      lastName: params[:lastName],
      email: params[:email],
      dateOfBirth: params[:dateOfBirth],
      physicalAddress: {
        address1: params[:address1],
        country: params[:country],
        state: params[:state],
        city: params[:city],
        zip: params[:zip]
      }
    }
  end

  def create_payout_request(payout_id)
    PayoutRequest.create!(payout_request_id: payout_id, account: @account)
  end

  def parse_mural_error_message(body)
    if body.is_a?(Hash)
      body["message"] || body[:message]
    elsif body.is_a?(String)
      JSON.parse(body)["message"] rescue "There was a problem creating your payout."
    else
      "There was a problem creating your payout."
    end
  end
end
