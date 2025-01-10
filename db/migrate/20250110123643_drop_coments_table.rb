class DropCommentsTable < ActiveRecord::Migration[8.0]
    def change
      drop_table :comemnts, if_exists: true
    end
end
