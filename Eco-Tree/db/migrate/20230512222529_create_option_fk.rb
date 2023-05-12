class CreateOptionFk < ActiveRecord::Migration[7.0]
  def change
    add_column(:options, :question_id, :integer)
    add_foreign_key(:options, :questions)
  end
end
