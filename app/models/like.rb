class Like < ApplicationRecord
  belongs_to :user
  belongs_to :comment, optional: true
  belongs_to :post, optional: true
  validates :user_id, uniqueness: { scope: :post_id, message: "はこの投稿に対してすでにいいねしています" }
end
