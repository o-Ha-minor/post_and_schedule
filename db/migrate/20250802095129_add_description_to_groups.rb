class AddDescriptionToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :description, :string
  end
end
