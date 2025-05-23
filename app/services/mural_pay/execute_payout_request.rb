module MuralPay 
  class ExecutePayoutRequest
    
    def initialize(id:)
      @id = id
    end

    def call

      response = connection.post("/api/payouts/payout/#{@id}/execute")
      
      raise "Mural API error (#{response.status}): #{response.body}" unless response.success?

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