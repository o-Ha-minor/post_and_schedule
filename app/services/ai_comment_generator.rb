require "openai"

class AiCommentGenerator
  def self.generate_comment(text, label, score)
    prompt = <<~PROMPT
      以下はユーザーの日記です：
      "#{text}"

      感情分析の結果は "#{label} (#{score.round(2)})" でした。
      この投稿に対して、50文字以内で共感あるコメントを生成してください。
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
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error("OpenAI Error: #{e.message}")
    "コメント生成に失敗しました"
  end
end
