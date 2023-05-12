class CreateAnswers < ActiveRecord::Migration[7.0]
  create_table :answers do |t|
    t.integer :id_answer 
  end
end
