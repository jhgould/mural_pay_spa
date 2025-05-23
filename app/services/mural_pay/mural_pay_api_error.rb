module MuralPay
  class MuralPayApiError < StandardError
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
      super("Mural API error (#{status}): #{body}")
    end
  end
end
