class CreateQuestions < ActiveRecord::Migration[7.0]
  create_table :questions do |t|
    t.string :description
    t.boolean :asked

    t.timestamps
  end
end
