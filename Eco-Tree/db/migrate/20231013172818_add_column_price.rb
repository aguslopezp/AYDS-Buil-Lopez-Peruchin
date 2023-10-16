class AddColumnPrice < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :price, :integer
    change_column_default :items, :price, 0
  end
end
