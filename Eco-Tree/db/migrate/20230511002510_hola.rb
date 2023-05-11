class Hola < ActiveRecord::Migration[7.0]
  create_table :prueba do |p|
    p.string :atributoDePrueba
  end
end
