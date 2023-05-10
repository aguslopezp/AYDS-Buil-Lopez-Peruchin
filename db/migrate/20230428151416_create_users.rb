class CreateUsers < ActiveRecord::Migration[7.0]
  create_table :users do |t|
    t.string :name

    t.timestamps
  end
end
