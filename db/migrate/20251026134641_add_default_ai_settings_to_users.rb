class AddDefaultAiSettingsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :ai_character, from: nil, to: 'tanuki'
    change_column_default :users, :ai_expression, from: nil, to: 'neutral'
  end
end
