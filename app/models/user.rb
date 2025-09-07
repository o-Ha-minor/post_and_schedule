class User < ApplicationRecord
  validates :name, { length: { maximum: 20 }, presence: true, uniqueness: true }
  validates :email, { length: { minimum: 1 }, uniqueness: true }
  has_secure_password

  # グループ機能の実装
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users

  # Active Storageのアタッチメント設定
  has_one_attached :image

  # 関連付け（counter_cacheを追加）
  has_many :posts, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  include Rails.application.routes.url_helpers

  # 投稿数を効率的に取得（既にロード済みかどうかを確認）
  def posts_count
    if association(:posts).loaded?
      posts.size
    else
      posts.count
    end
  end

  # グループ数を効率的に取得
  def groups_count
    if association(:groups).loaded?
      groups.size
    else
      groups.count
    end
  end

  # 獲得いいね数を効率的に取得
  def total_likes_count
    if association(:posts).loaded? && posts.all? { |post| post.association(:likes).loaded? }
      posts.sum { |post| post.likes.size }
    else
      posts.joins(:likes).count
    end
  end

  # 画像URLを取得
  def image_url
    if image.attached?
      rails_blob_path(image, only_path: true)
    else
      nil
    end
  end

  # プロフィール表示用のデータを効率的に取得するスコープ
  scope :with_profile_data, -> {
    includes(
      posts: :likes,
      groups: :users
    )
  }

  # JSON用のデータを効率的に生成
  def profile_data_for_json(limit: 10)
    # 必要なアソシエーションを事前ロード
    user_posts = posts.includes(:likes).order(created_at: :desc).limit(limit)
    user_groups = groups.includes(:users)

    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at,
      image_url: image_url,
      posts_count: posts_count,
      groups_count: groups_count,
      posts: user_posts.map do |post|
        {
          id: post.id,
          content: post.content,
          created_at: post.created_at,
          user_id: post.user_id,
          likes_count: post.likes.size
        }
      end,
      groups: user_groups.map do |group|
        {
          id: group.id,
          name: group.name,
          description: group.description,
          members_count: group.users.size
        }
      end,
      likes_count: user_posts.sum { |post| post.likes.size }
    }
  end
end
