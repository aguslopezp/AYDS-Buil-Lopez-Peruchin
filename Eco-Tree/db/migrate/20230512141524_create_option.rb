class CreateOption < ActiveRecord::Migration[7.0]
  create_table :option do |t|
    t.string :descr_option
    t.boolean :type

    t.timestamps
  end
end
