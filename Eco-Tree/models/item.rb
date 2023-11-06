# frozen_string_literal: true

class Item < ActiveRecord::Base
  # Metodo para establecer una hoja y un fondo por defecto.
  def set_item_default
    session[:hoja] = Item.find_by(id: 6).name
    session[:fondo] = Item.find_by(id: 10).name
  end

end
