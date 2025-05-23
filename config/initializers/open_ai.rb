require "openai"

OpenAI.configure do |config|
  config.access_token = Rails.application.credentials[:open_ai][:api_key]
  config.log_errors = true 
end