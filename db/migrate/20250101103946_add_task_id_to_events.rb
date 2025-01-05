class AddTaskIdToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :task_id, :integer
  end
end
