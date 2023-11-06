class CreateItem < ActiveRecord::Migration[7.0]
  create_table :items do |t|
    t.string :name
    t.string :type

    t.timestamps
  end
end
