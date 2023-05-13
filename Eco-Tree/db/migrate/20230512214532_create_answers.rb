class CreateAnswers < ActiveRecord::Migration[7.0]
  create_table :answers do |t|
    t.belongs_to :user, index: true, foreign_key: true
    t.belongs_to :option, index: true, foreign_key: true
  end
end
