class AddAiCharacterToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :ai_character, :string
    add_column :users, :ai_expression, :string
  end
end
