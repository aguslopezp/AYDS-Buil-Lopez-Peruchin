# frozen_string_literal: true

# Esta es la clase del controlador de la tienda.
# Maneja las rutas de la tienda y la compra de hojas/fondos denominados Items.
class StoreController < Sinatra::Application
  before do
    redirect '/' if session[:user_id].nil? && request.path_info != '/'
    @user = User.current_user(:id, session[:user_id]) unless session[:user_id].nil?
  end

  # Ruta para mostrar la tienda.
  get '/store' do
    @coin = @user.coin
    erb :store
  end

  # Ruta para comprar un item de la tienda.
  get '/buyItem' do
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
    request_body = JSON.parse(request.body.read)
    name = request_body['name']
    item = Item.find_by(name: name)

    @user.buy_item(item.id, item.price)
    @user.set_item_in_user(params[:item], item.id)
  end
end
