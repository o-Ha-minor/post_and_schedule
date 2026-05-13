class AddDefaultGroupIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :default_group_id, :integer
  end
end
