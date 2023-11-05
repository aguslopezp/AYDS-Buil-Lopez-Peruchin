# frozen_string_literal: true

# MenuController is responsible for handling menu-related routes and actions.
# It provides routes for viewing the menu, practicing, ranking, and managing user profiles.
class MenuController < Sinatra::Application
  def check_session
    redirect '/' if session[:user_id].nil?
  end

  def current_user
    return User.find(session[:user_id]) if session[:user_id]
  end

  get '/menu' do
    session[:tree] = false
    check_session
    user_id = session[:user_id]
    @user = current_user
    erb :menu, locals: { user_id: user_id }
  end

  get '/practicar' do
    redirect '/' if session[:user_id].nil? # Redirigir al inicio de sesion si la sesion no esta activa

    user_id = session[:user_id]
    @user = current_user
    setup_practice_data(user_id)
    erb :practice
  end

  def setup_practice_data(user_id)
    # array de todas los id de las preguntas que se le hicieron al usuario
    @questions_asked = AskedQuestion.where(user_id: user_id).pluck(:question_id)
    session[:questions_asked] = @questions_asked

    # indice de la current question a practicar
    @question_index = 0
    session[:question_index] = @question_index
  end

  post '/practicar' do
    @user = current_user
    @question_index = session[:question_index].to_i + 1
    session[:question_index] = @question_index
    @questions_asked = session[:questions_asked]
    erb :practice
  end

  get '/ranking' do
    redirect '/' if session[:user_id].nil? # Redirigir al inicio de sesion si la sesion no esta activa

    @users = User.order(points: :desc).limit(10) # arreglo de usuarios ordenados de manera descendente
    user = current_user
    @position = User.order(points: :desc).pluck(:id).find_index(session[:user_id]) + 1

    erb :ranking, locals: { user: user }
  end

  get '/profile' do
    redirect '/' if session[:user_id].nil? # Redirigir al inicio de sesion si la sesion no esta activa

    @user = current_user
    @verificated = @user.valid_email
    erb :profile
  end

  get '/profile_change' do
    redirect '/' if session[:user_id].nil? # Redirigir al inicio de sesion si la sesion no esta activa

    @user = current_user
    erb :profile_change
  end

  post '/profile_change' do
    user = current_user

    new_username = params[:new_username]
    current_password = params[:current_password]
    new_password = params[:new_password]
    new_email = params[:new_email]

    if (new_username != '' && !User.find_by(username: new_username).nil?) ||
       (new_password != '' && !current_password.nil? && (current_password != user.password)) ||
       (new_email != '' && !User.find_by(email: new_email).nil?)
      redirect '/profile_change'
    end

    user.update_column(:username, new_username) if new_username != ''

    user.update_column(:password, new_password) if new_password != '' && current_password != ''

    user.update_column(:email, new_email) if new_email != ''

    redirect '/menu' unless user.save

    redirect '/profile'
  end

  get '/tree' do
    redirect '/' if session[:user_id].nil? # Redirigir al inicio de sesion si la sesion no esta activa
    @user = current_user

    hoja_id = @user.leaf_id # Busco el id de la actual compra del usuario
    fondo_id = @user.background_id
    @hoja = Item.find_by(id: hoja_id).name  # con ese id busco en los items y paso el nombre
    @fondo = Item.find_by(id: fondo_id).name

    @tree = session[:tree]
    erb :tree
  end
end
