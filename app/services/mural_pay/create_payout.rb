module MuralPay
  class CreatePayout
    ENDPOINT = '/api/payouts/payout'.freeze

    def initialize(payload)
      @payload = payload
    end

    def call
      response = connection.post(ENDPOINT, @payload)

      unless response.success?
        raise MuralPay::MuralPayApiError.new(response.status, response.body)
      end

      response.body
    end

    private

    def connection
      MuralPayService.connection(
        'transfer-api-key' => Rails.application.credentials.dig(:mural_pay, :transfer_api_key)
      )
    end
  end
end
