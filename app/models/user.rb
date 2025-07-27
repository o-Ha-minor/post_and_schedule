class User < ApplicationRecord
    validates :name, { length: { maximum: 20 }, presence: true, uniqueness: true }
    validates :email, { length: { minimum: 1 }, uniqueness: true }
    has_secure_password

    # Active Storageのアタッチメント設定
    has_one_attached :image
    has_many :events, dependent: :destroy
    has_many :posts
    has_many :tasks
    has_many :events
    has_many :likes, dependent: :destroy
    has_many :comments
end
