module MuralPay
  class GetAccounts
    def call
      response = MuralPayService.connection.get("/api/accounts")

      raise "Mural API error: #{response.status}" unless response.success?

      response.body
    end
  end 
end