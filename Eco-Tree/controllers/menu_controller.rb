# frozen_string_literal: true

# MenuController is responsible for handling menu-related routes and actions.
# It provides routes for viewing the menu, practicing, ranking, and managing user profiles.
class MenuController < Sinatra::Application
  before do
    redirect '/' if session[:user_id].nil? && request.path_info != '/'
    @user = User.current_user(:id, session[:user_id]) unless session[:user_id].nil?
  end

  get '/menu' do
    session[:tree] = false
    user_id = session[:user_id]
    erb :menu, locals: { user_id: user_id }
  end

  get '/practicar' do
    user_id = session[:user_id]
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
    @question_index = session[:question_index].to_i + 1
    session[:question_index] = @question_index
    @questions_asked = session[:questions_asked]
    erb :practice
  end

  get '/ranking' do
    @users = User.order(points: :desc).limit(10) # arreglo de usuarios ordenados de manera descendente
    @position = User.order(points: :desc).pluck(:id).find_index(session[:user_id]) + 1

    erb :ranking, locals: { user: @user }
  end

  get '/profile' do
    @verificated = @user.valid_email
    erb :profile
  end

  get '/profile_change' do
    erb :profile_change
  end

  post '/profile_change' do
    new_username = params[:new_username]
    current_password = params[:current_password]
    new_password = params[:new_password]
    new_email = params[:new_email]

    if (new_username != '' && !User.find_by(username: new_username).nil?) ||
       (new_password != '' && !current_password.nil? && (current_password != @user.password)) ||
       (new_email != '' && !User.find_by(email: new_email).nil?)
      redirect '/profile_change'
    end

    @user.update_column(:username, new_username) if new_username != ''

    @user.update_column(:password, new_password) if new_password != '' && current_password != ''

    @user.update_column(:email, new_email) if new_email != ''

    redirect '/menu' unless @user.save

    redirect '/profile'
  end

  get '/tree' do
    hoja_id = @user.leaf_id
    fondo_id = @user.background_id
    @hoja = Item.find_by(id: hoja_id).name
    @fondo = Item.find_by(id: fondo_id).name

    @tree = session[:tree]
    erb :tree
  end
end
