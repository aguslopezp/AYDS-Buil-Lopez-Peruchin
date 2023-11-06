class AddColumnLevel < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :level, :integer
  end
end
