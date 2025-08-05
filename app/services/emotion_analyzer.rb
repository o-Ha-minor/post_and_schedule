require "faraday"
require "json"

class EmotionAnalyzer
  API_URL = "http://localhost:5000"

  def self.analyze(text)
    conn = Faraday.new(url: API_URL) do |faraday|
      faraday.request :json
      faraday.adapter Faraday.default_adapter
    end

    response = conn.post("/analyze") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { text: text }.to_json
    end

    puts "Status: #{response.status}"
    puts "Body: #{response.body.inspect}"

    if response.success?
      data = JSON.parse(response.body)
      {
        score: data["score"],
        label: data["sentiment"] || data["label"]
      }
    else
      Rails.logger.error("Emotion analysis failed: #{response.body}")
      {
        score: 0.0,
        label: "neutral"
      }
    end
  end
end
