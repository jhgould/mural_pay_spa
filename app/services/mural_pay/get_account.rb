module MuralPay
  class GetAccount
    def initialize(id:)
      @id = id
    end

    def call
      response = MuralPayService.connection.get("/api/accounts/#{@id}")

      raise MuralPay::MuralPayApiError.new(response.status, response.body) unless response.success?

      response.body
    end
  end 
end