module MuralPay
  class GetAccounts
    def call
      response = MuralPayService.connection.get("/api/accounts")

      raise MuralPay::MuralPayApiError.new(response.status, response.body) unless response.success?

      response.body
    end
  end 
end