class Event < ApplicationRecord
  validates :title, presence: true
  validates :start, presence: true
  belongs_to :user
  validates :user_id, presence: true
  belongs_to :task, optional: true
  belongs_to :group, optional: true

  alias_attribute :start_time, :start
  alias_attribute :end_time, :end
end
