class RmcolumnCreateAskedquestions < ActiveRecord::Migration[7.0]
  def change
    remove_column :questions, :asked, :boolean

    create_table :asked_questions do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :question, index: true, foreign_key: true
    end
  end
end
