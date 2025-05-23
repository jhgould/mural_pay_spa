module MuralPay 
  class ExecutePayoutRequest
    def initialize(id:)
      @id = id
    end

    def call
      response = connection.post("/api/payouts/payout/#{@id}/execute")
      
      unless response.success?
        # Raise your custom error class
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
