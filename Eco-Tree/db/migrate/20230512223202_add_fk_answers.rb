class AddFkAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column(:answers, :option_id, :integer)
    add_column(:answers, :user_id, :integer)

    add_foreign_key(:answers, :options)
    add_foreign_key(:answers, :users)
  end
end
