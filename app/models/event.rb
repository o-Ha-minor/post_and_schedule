class Event < ApplicationRecord
  validates :title, presence: true
  validates :start, presence: true
  belongs_to :user
  def start_time
    self.start
  end
  belongs_to :user
  validates :user_id, presence: true
  belongs_to :task, optional: true
  belongs_to :group
end
