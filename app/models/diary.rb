class Diary < ApplicationRecord
  belongs_to :user

  after_create :analyze_and_comment

  private

  def analyze_and_comment
    emotion = EmotionAnalyzer.analyze(content)  # ここは @post じゃなくて content だよ
    comment = AiCommentGenerator.generate_comment(content, emotion[:label], emotion[:score])

    update(
      sentiment_score: emotion[:score],
      sentiment_label: emotion[:label],
      ai_comment: comment
    )
  end
end
