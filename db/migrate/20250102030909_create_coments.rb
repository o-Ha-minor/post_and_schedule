class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.string :post
      t.string :references
      t.integer :parent_id
      t.integer :likes_count

      t.timestamps
    end

    add_column :posts, :likes_count, :integer
  end
end
