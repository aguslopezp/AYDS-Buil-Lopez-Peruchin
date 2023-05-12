class CreateUsers < ActiveRecord::Migration[7.0]
  create_table :users do |t|
    t.string :username
    t.string :password
    t.string :email
    t.date :birthdate
    t.integer :points
    t.integer :ranking_position

    t.timestamps
  end
end
