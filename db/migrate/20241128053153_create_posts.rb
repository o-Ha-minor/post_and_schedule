class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.text :content
      t.timestamps
      t.integer :user_id, null: false
    end
  end
end
