class CreateQuestions < ActiveRecord::Migration[7.0]
  create_table :questions do |t|
    t.string :description
    t.time :time
    t.boolean :asked

    t.timestamps
  end
end
