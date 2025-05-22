module MuralPay
  class CreateAccount
    def initialize(name:)
      @name = name
    end

    def call
      response = MuralPayService.connection.post('/api/accounts', { name: @name })

      raise "Mural API error: #{response.status}" unless response.success?

      response.body
    end
  end
end
