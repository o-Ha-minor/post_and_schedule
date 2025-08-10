class AddDetailsToTodos < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :completed_at, :datetime
    add_column :tasks, :status, :string
    add_column :tasks, :category, :string
    add_column :tasks, :priority, :integer
  end
end
