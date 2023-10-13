class ChangeColumnItem < ActiveRecord::Migration[7.0]
  change_table :items do |t|
    t.rename :type, :section
  end
end
