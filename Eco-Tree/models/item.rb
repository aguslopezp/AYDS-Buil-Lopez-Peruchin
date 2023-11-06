# frozen_string_literal: true

# Modelo para representar los productos de la tienda
class Item < ActiveRecord::Base
  # Metodo para establecer una hoja y un fondo por defecto.
  def self.item_default(session)
    session[:hoja] = Item.find_by(id: 6).name
    session[:fondo] = Item.find_by(id: 10).name
  end
end
