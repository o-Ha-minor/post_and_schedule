class Post < ApplicationRecord
    has_one_attached :image
    belongs_to :user
    belongs_to :group, optional: true
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy

    include Rails.application.routes.url_helpers

    # ActiveStorage画像のURL（only_path: true で host 不要）
    def image_url
      rails_blob_path(image, only_path: true) if image.attached?
    end

    def likes_count
      if association(:likes).loaded?
        # ロード済みの場合はカウントする（SQLクエリなし）
        likes.size
      else
        likes.count
      end
    end
end
