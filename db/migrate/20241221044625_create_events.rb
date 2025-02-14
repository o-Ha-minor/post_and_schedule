class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
