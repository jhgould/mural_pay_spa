module MuralPay
  class GetPayoutRequest

    def initialize(id:)
      @id = id
    end

    def call
      response = MuralPayService.connection.get("/api/payouts/payout/#{@id}")

      raise MuralPay::MuralPayApiError.new(response.status, response.body) unless response.success?

      response.body
    end
  end 
end