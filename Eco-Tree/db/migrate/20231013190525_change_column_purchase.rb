class ChangeColumnPurchase < ActiveRecord::Migration[7.0]
  def change
    rename_column :purchased_items, :items_id, :item_id
  end
end
