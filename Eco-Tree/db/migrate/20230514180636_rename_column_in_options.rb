class RenameColumnInOptions < ActiveRecord::Migration[7.0]
  change_table :options do |t|
    t.rename :type, :isCorrect
  end
end
