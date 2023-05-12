class CreateQuestion < ActiveRecord::Migration[7.0]
  create_table :question do |t|
    t.string :descr_question
    t.integer :time
    t.boolean :asked

    t.timestamps
  end
end
