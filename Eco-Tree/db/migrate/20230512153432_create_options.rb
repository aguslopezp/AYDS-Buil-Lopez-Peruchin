class CreateOptions < ActiveRecord::Migration[7.0]
  create_table :options do |t|
    t.string :description
    t.boolean :type

    t.timestamps
  end
end
