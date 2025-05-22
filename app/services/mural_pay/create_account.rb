module MuralPay
  class CreateAccount
    def initialize(name:, description:)
      @name = name  
      @description = description 
    end

    def call
      response = MuralPayService.connection.post('/api/accounts', { name: @name, description: @description })

      raise "Mural API error: #{response.status}" unless response.success?

      response.body
    end
  end
end
