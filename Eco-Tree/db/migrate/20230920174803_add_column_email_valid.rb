class AddColumnEmailValid < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :valid_email, :boolean
    change_column_default :users, :valid_email, false
  end
end
