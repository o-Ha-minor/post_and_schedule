class ChangeColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :user_id, :bigint
    add_column :users, :password_digest, :string
    add_column :users, :image_name, :string
    remove_column :users, :password, :string
  end
end
