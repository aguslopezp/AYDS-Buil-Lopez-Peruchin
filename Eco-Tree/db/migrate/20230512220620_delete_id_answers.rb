class DeleteIdAnswers < ActiveRecord::Migration[7.0]
  remove_column :answers, :id_answer
end
