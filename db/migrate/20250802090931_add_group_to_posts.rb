class AddGroupToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :group, foreign_key: true
  end
end
