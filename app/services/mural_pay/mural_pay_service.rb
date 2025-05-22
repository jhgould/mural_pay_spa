module MuralPay
  class MuralPayService
    BASE_URL = 'https://api-staging.muralpay.com'

    def self.connection(extra_headers = {})
      Faraday.new(url: BASE_URL) do |conn|
        conn.request :json
        conn.response :json, parser_options: { symbolize_names: true }

        conn.headers['Authorization'] = "Bearer #{Rails.application.credentials[:mural_pay][:api_key]}"
        conn.headers['Content-Type'] = 'application/json'
        conn.headers['Accept'] = 'application/json'

        extra_headers.each { |k, v| conn.headers[k] = v }
      end
    end
  end
end
