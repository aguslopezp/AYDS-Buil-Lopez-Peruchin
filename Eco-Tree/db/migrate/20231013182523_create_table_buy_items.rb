class CreateTableBuyItems < ActiveRecord::Migration[7.0]
  def change
    create_table :purchased_items do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :items, index: true, foreign_key: true
    end
  end
end
