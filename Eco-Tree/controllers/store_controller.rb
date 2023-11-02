# frozen_string_literal: true

# Esta es la clase del controlador de la tienda.
# Maneja las rutas de la tienda y la compra de hojas/fondos denominados Items.
class StoreController < Sinatra::Application
  before ['/store', '/buyItem'] do
    # Verifica si el usuario ha iniciado sesion antes de acceder a ciertas rutas.
    redirect '/' if session[:user_id].nil?
  end

  # Ruta para mostrar la tienda.
  get '/store' do
    @user = current_user
    @coin = @user.coin
    erb :store
  end

  # Ruta para comprar un item de la tienda.
  get '/buyItem' do
    @user = current_user
    @coin = @user.coin
    @item_selected = params[:item]
    @item = Item.where(section: @item_selected)

    if @item_selected == 'hoja'
      @item_selected_id = @user.leaf_id
    elsif @item_selected == 'fondo'
      @item_selected_id = @user.background_id
    end

    purchased_item_ids = PurchasedItem.where(user_id: @user.id).pluck(:item_id)

    @item_comprados = {}
    @item_price = {}
    @item.each do |item|
      @item_comprados[item.id] = purchased_item_ids.include?(item.id)
      @item_price[item.id] = item.price
    end

    erb :buyItem
  end

  # Metodo POST para comprar un elemento de la tienda.
  post '/buyItem' do
    user = current_user

    request_body = JSON.parse(request.body.read)
    name = request_body['name']
    item = Item.find_by(name: name)

    user.buy_item(item.id, item.price)
    user.set_item_in_user(params[:item], item.id)
  end

  # Obtiene el usuario actual en la sesion.
  def current_user
    return User.find(session[:user_id]) if session[:user_id]
  end
end
