class AddStreak < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :streak, :integer
    change_column_default :users, :streak, 0
  end
end
