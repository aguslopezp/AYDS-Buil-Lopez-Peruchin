class AddColumnsUser < ActiveRecord::Migration[7.0]
  add_column :users, :password, :string
  add_column :users, :username, :string
  add_column :users, :birthdate, :date
  add_column :users, :email, :string
  add_column :users, :points, :integer
  add_column :users, :ranking_position, :integer
end
