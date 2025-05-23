module OpenAi
  class OpenAiService 

    def initialize
      @client = OpenAI::Client.new
    end


    def translate(memo, language)
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "user", content: "Translate only the following text to the primary language spoken in the country with the code '#{language}'. Return only the translated text, with no explanation or additional output:#{memo}"
 }
          ],
          temperature: 0.7,
        }
      )
      response.dig("choices", 0, "message", "content")
    rescue StandardError => e
      Rails.logger.error("OpenAI translation error: #{e.message}")
      nil
    end

  end
end 