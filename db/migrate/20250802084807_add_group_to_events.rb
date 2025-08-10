class AddGroupToEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :group, foreign_key: true
  end
end
