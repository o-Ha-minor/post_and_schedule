require "openai"

class AiCommentGenerator
  def self.strip_code_block(text)
    text.gsub(/\A```json\s*|```\z/, "").strip
  end

  def self.generate_comment(text)
    prompt = <<~PROMPT
      以下はユーザーの日記です：
      "#{text}"
      この投稿に対して、感情分析を行い、（positive, negative, neutral）のうちどれかを"label"、
      感情の度合いを0〜1で通知化し"score"としてください。
      さらに、75文字程度で共感あるコメントを生成し、"comment"としてください。
      結果はJSON形式で返してください。
    PROMPT

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    response = client.chat(
      parameters: {
        model: ENV.fetch("GPT_MODEL", "gpt-3.5-turbo"),
        messages: [
          { role: "system", content: "やさしい日本語で、心の癒しとなるようにお願い。" },
          { role: "user", content: prompt }
        ]
      }
    )

    content = response.dig("choices", 0, "message", "content")
    content = strip_code_block(content)

    JSON.parse(content, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error("JSON.parse error: #{e.message}")
    { label: "neutral", score: 0.5, comment: "コメント生成に失敗しました" }
  rescue => e
    Rails.logger.error("OpenAI Error: #{e.message}")
    { label: "neutral", score: 0.5, comment: "コメント生成に失敗しました" }
  end
end
