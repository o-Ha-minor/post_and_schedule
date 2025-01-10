class DropCommentsTable < ActiveRecord::Migration[8.0]
    def change
      drop_table :comments, if_exists: true
    end
end
