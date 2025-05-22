module MuralPay
  class GetAccount
    def initialize(id:)
      @id = id
    end

    def call
      response = MuralPayService.connection.get("/api/accounts/#{@id}")

      raise "Mural API error: #{response.status}" unless response.success?

      response.body
    end
  end 
end