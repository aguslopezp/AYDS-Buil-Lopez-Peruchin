class RemoveColumnRankingPosition < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :ranking_position, :integer
  end
end
