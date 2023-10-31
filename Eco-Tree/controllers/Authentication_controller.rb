require 'bcrypt'
require 'mail'
require_relative '../methods'

class AuthenticationController < Sinatra::Application
  get '/register' do
    erb :register
  end


  post '/register' do

    #genera un codigo de 6 caracteres 
    code_random = generate_random_code(6)
    session[:code] = code_random
    session[:question_id] = 1

    # ya existe un jugador en la base de datos con ese usuario
    if !(User.find_by(username: params[:username]).nil?) 
      redirect '/register'
    end

    if params[:password] == params[:passwordTwo]
      passw = hash_password(params[:password])
      
      @user = User.create(username: params[:username], password: passw, email: params[:email], birthdate: params[:birthdate], leaf_id: 6, background_id: 10)
      session[:user_id] = @user.id
      if @user.save # se guardo correctamente ese nuevo usuario en la tabla
        #envia el email
        send_verificated_email(@user.email, session[:code])

        #setear arbol y hoja por defecto
        PurchasedItem.create(user_id: @user.id, item_id: 6)
        PurchasedItem.create(user_id: @user.id, item_id: 10)
        
        session[:hoja] = Item.find_by(id: 6).name
        session[:fondo] = Item.find_by(id: 10).name

        redirect '/validate'
      else
        redirect '/register'
      end
    else 
      redirect '/register'
    end
  end 

  get '/login' do
    erb :login
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    input_password = params[:password]
    if @user && @user.compare_password(@user.password, input_password)
      session[:user_id] = @user.id

      session[:hoja] = Item.find_by(id: 6).name
      session[:fondo] = Item.find_by(id: 10).name
      redirect '/menu'
    elsif @user 
        @password_error = "*contraseña incorrecta"
        erb :login
    else
      @password_error = "*datos ingresados no pertenecen a ninguna cuenta"
      erb :login
    end
  end 

  get '/logout' do
    session.clear
    redirect '/'
  end 

  get '/validate' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    erb :validate
  end

  post '/validate' do    
    if session[:code] == params[:codigo]
      user = User.find(session[:user_id])
      user.update_column(:valid_email, true)
    end
    redirect '/menu'
  end
end