class Task < ApplicationRecord
    validates :title, { presence: true, length: { maximum: 30 } }
    belongs_to :user
    validates :user_id, presence: true
    has_one :event
end
