class AddColumnsQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :detail, :string
    add_column :questions, :image, :string
  end
end
