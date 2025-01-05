class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.text :content
      t.id :id
      t.timestamps
      t.user_id
    end
  end
end
