class Comment < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  belongs_to :post
  has_many :likes, dependent: :destroy

  include Rails.application.routes.url_helpers

  def image_url
    rails_blob_path(image, only_path: true) if image.attached?
  end

  def likes_count
    likes.count
  end
end
