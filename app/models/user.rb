class User < ApplicationRecord
    validates :name, { length: { maximum: 20 }, presence: true, uniqueness: true }
    validates :email, { length: { minimum: 1 }, uniqueness: true }
    has_secure_password

    # グループ機能の実装
    has_many :group_users
    has_many :groups, through: :group_users

    # Active Storageのアタッチメント設定
    has_one_attached :image
    has_many :events, dependent: :destroy
    has_many :posts
    has_many :tasks
    has_many :events
    has_many :likes, dependent: :destroy
    has_many :comments
end
