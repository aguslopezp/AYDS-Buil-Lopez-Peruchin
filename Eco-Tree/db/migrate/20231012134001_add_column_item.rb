class AddColumnItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :description, :string
  end
end
