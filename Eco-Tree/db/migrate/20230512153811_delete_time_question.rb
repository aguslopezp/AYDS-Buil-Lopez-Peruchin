class DeleteTimeQuestion < ActiveRecord::Migration[7.0]
  remove_column :questions, :time
end
