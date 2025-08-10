class Diary < ApplicationRecord
  belongs_to :user

  after_create :analyze_and_comment

  private

  def analyze_and_comment
    # contentだけ渡して、GPTから感情ラベル・スコア・コメントを含むハッシュをもらう
    result = AiCommentGenerator.generate_comment(content)

    # DBを更新（ラベル名はカラム名に合わせて調整してね）
    update(
      sentiment_label: result[:label],
      sentiment_score: result[:score],
      ai_comment: result[:comment]
    )
  end
end
