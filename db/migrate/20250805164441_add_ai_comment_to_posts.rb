class AddAiCommentToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :ai_comment, :text
  end
end
