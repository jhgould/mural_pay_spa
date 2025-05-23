module MuralPay
  class GetPayoutRequest

    def initialize(id:)
      @id = id
    end

    def call
      response = MuralPayService.connection.get("/api/payouts/payout/#{@id}")

      raise "Mural API error: #{response.status}" unless response.success?

      response.body
    end
  end 
end