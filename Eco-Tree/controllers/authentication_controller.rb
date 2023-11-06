# frozen_string_literal: true

require 'bcrypt'
require 'mail'
require_relative '../methods'

# Esta es la clase maneja la autenticacion de usuarios,
# incluyendo el inicio de sesion, registro, validaciln de correo electronico
# y gestion de sesiones de usuario.
class AuthenticationController < Sinatra::Application
  # Ruta para mostrar la pagina de inicio de sesion.
  get '/login' do
    erb :login
  end

  # Maneja la solicitud POST de inicio de sesion.
  post '/login' do
    @user = User.current_user(:username, params[:username])
    check_user(@user)
  end

  # Ruta para mostrar la pagina de registro de usuario.
  get '/register' do
    erb :register
  end

  # Maneja la solicitud POST de registro de usuario.
  post '/register' do
    session[:code] = generate_random_code(6)
    session[:question_id] = 1

    redirect '/register' unless User.find_by(username: params[:username]).nil?
    create_user
  end

  # Ruta para cerrar sesion.
  get '/logout' do
    session.clear
    redirect '/'
  end

  # Ruta para mostrar la pagina de validacion de correo electronico.
  get '/validate' do
    erb :validate
  end

  # Maneja la solicitud POST de validacion de correo electronico.
  post '/validate' do
    if session[:code] == params[:codigo]
      user = User.current_user(:id, session[:user_id])
      user.update_column(:valid_email, true)
    end
    redirect '/menu'
  end


  # Metodo para iniciar sesion.
  def check_user(user)
    if user&.compare_password(user.password, params[:password])
      session[:user_id] = user.id
      Item.set_item_default(session)
      redirect '/menu'
    elsif user
      @password_error = '*contraseña incorrecta'
      erb :login
    else
      @password_error = '*datos ingresados no pertenecen a ninguna cuenta'
      erb :login
    end
  end

  # Metodo para registrar un usuario.
  def create_user
    if passwords_match?
      user_attributes = {
        username: params[:username],
        password: hash_password(params[:password]),
        email: params[:email],
        birthdate: params[:birthdate],
        leaf_id: 6,
        background_id: 10
      }

      @user = User.create(user_attributes)
      if @user.save
        initialize_user_settings(@user)
        redirect '/validate'
      else
        redirect '/register'
      end
    else
      redirect '/register'
    end
  end

  # Verifica si las contrasenias coinciden
  def passwords_match?
    params[:password] == params[:passwordTwo]
  end

  # Inicializa las configuraciones del usuario
  def initialize_user_settings(user)
    session[:user_id] = user.id
    send_verificated_email(user.email, session[:code])
    PurchasedItem.create(user_id: user.id, item_id: 6)
    PurchasedItem.create(user_id: user.id, item_id: 10)
    Item.set_item_default(session)
  end
end
