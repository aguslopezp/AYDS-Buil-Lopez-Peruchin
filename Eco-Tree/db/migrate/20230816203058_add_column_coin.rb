class AddColumnCoin < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :coin, :integer
    change_column_default :users, :coin, 50
  end
end
