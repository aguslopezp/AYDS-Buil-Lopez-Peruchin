class StoreController < Sinatra::Application
  get '/store' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    erb :store
  end

  get '/buySkin' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    @item = Item.where(section: 'hoja')
    @leaf_id = User.find(user_id).leaf_id
   
  
    purchased_item_ids = PurchasedItem.where(user_id: user_id).pluck(:item_id) #busca los items que compro el usuario
    
    @item_comprados = {}  #inicializa el hash
    @item_price = {}
    @item.each do |item|
      @item_comprados[item.id] = purchased_item_ids.include?(item.id) #mete true si el id de los items esta en los comprados por el usuario
      @item_price[item.id] = item.price 
    end
    
    erb :buySkin
  end
  

  post '/buySkin' do
    request_body = JSON.parse(request.body.read)
    name = request_body['name'] #json

    user_id = session[:user_id]
    item_id = Item.find_by(name: name).id
    user = User.find_by(id: user_id)
    item_price = Item.find_by(name: name).price

    #Si no lo compro lo agrega
    if PurchasedItem.find_by(item_id: item_id, user_id: user_id).nil?
      PurchasedItem.create(user_id: user_id, item_id: item_id)
      
      if (item_price <= user.coin)
        user.discount_coins(item_price)
      end

    end
    #setea la nueva hoja elegida por el usuario, este comprada o no
    user.update_column(:leaf_id, item_id)
  end

  get '/buyFondo' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    @item = Item.where(section: 'fondo')
    @background_id = User.find(user_id).background_id


    purchased_item_ids = PurchasedItem.where(user_id: user_id).pluck(:item_id) #busca los items que compro el usuario
    
    @item_comprados = {}  #inicializa el hash
    @item_price = {}
    @item.each do |item|
      @item_comprados[item.id] = purchased_item_ids.include?(item.id) #mete true si el id de los items esta en los comprados por el usuario
      @item_price[item.id] = item.price 
    end
    
    erb :buyFondo
  end

  post '/buyFondo' do
    request_body = JSON.parse(request.body.read)
    name = request_body['name']
    user_id = session[:user_id]
    item_id = Item.find_by(name: name).id
    user = User.find_by(id: user_id)
    item_price = Item.find_by(name: name).price

    
    if PurchasedItem.find_by(item_id: item_id, user_id: user_id).nil?
      PurchasedItem.create(user_id: user_id, item_id: item_id)

      if (item_price <= user.coin)
        user.discount_coins(item_price)
      end

    end
    #setea el nuevo fondo elegido por el usuario
    user.update_column(:background_id, item_id)
  end
end