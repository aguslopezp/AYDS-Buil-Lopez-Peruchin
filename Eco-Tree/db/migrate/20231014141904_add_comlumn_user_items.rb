class AddComlumnUserItems < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :leaf_id, :integer
    add_column :users, :background_id, :integer
  end
end
