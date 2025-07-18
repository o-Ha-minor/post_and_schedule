class Post < ApplicationRecord
    has_one_attached :image
    belongs_to :user
    validates :user_id, presence: true
    has_many :likes, dependent: :destroy
    has_many :comments, dependent: :destroy
end
