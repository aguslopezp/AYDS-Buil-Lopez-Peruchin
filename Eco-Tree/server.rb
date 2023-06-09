require 'sinatra'
require 'sinatra/base'
require 'bundler/setup'
require 'logger'
require 'sinatra/activerecord'
require 'sinatra/cookies'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/option'
require_relative 'models/asked_question'
require_relative 'models/answer'

class App < Sinatra::Application
  enable :sessions
  # Configuracion de la clave secreta de sesión
  set :session_secret, 'la_pelota_no_se_mancha'

  def initialize(app = nil)
    super()
  end
  set :root, File.dirname(__FILE__)
  set :views, Proc.new { File.join(root, 'views') }
  set :public_folder, File.dirname(__FILE__) + '/views'
  
  configure :production, :development do
    enable :logging

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end


  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
      logger.info 'Reloaded!!!'
    end
  end  


  get '/game/:id_question' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @total_questions = Question.count # Numero total de preguntas en el juego
    @id_question = params[:id_question].to_i  # id de la pregunta a preguntar

    
    user_id = session[:user_id] 
    @user = User.find(user_id)

    # consultamos si esa pregunta habia sido preguntada
    asked_question = AskedQuestion.find_by(user_id: user_id, question_id: @id_question)

    # Es un id de pregunta valido y nunca fue preguntada a ese usuario
    if @id_question  <= @total_questions && asked_question.nil?
      @question = Question.find_by(id: @id_question)  # pregunta de la bd con ese id
      @options = Option.where(question_id: @question.id) # arreglo de opciones que pertenecen a esta @question con ese id
      erb :game
    # Esa pregunta ya se le pregunto al usuario, buscamos la siguiente pregunta que no haya sido preguntada
    elsif @id_question <= @total_questions && !asked_question.nil?
      i = @id_question
      while i <= @total_questions && !asked_question.nil?
        i += 1
        asked_question = AskedQuestion.find_by(user_id: user_id, question_id: i)
      end
      if i > @total_questions # no hay mas preguntas para hacer, todas fueron preguntadas
        erb :game_finished
      else # encontramos una pregunta que no se le hizo nunca al usuario
        @id_question = i  # nueva pregunta a ser preguntada
        @question = Question.find_by(id: @id_question)  
        @options = Option.where(question_id: @question.id)
        erb :game
      end
    else  # el juego se termino
      erb :game_finished
    end
  end 

  
  post '/game/:question_id' do
    if params[:selected_option_id].nil?
      question_id = params[:question_id]
      redirect "/game/#{question_id}"
    end
    # Obtener la opción seleccionada de la base de datos a traves de los parametros
    selected_option = Option.find(params[:selected_option_id])
    user_id = session[:user_id]
    # Verificar si la opción seleccionada es correcta o no
    option_result = selected_option.isCorrect ? 'true' : 'false'
    
    # Calculo puntos del usuario
    if option_result == 'true'
      user = User.find(user_id)
      if user.points.nil? # este if ya no hace falta
        user.update(points: 1)
      else 
        newPoints = user.points + 1
        user.update(points: newPoints)
      end
    end

    # Guardo en la tabla answers la respuesta del usuario
    Answer.create(user_id: user_id, option_id: params[:selected_option_id])

    # Respuesta preguntada se marcara como preguntada para no volver a preguntarse (para no ser preguntada nuevamente, en una nueva ocasion)
    AskedQuestion.create(user_id: user_id, question_id: params[:question_id])
    
    redirect "/asked/#{params[:question_id]}/#{option_result}/#{params[:selected_option_id]}"
  end
  

  get '/asked/:question_id/:option_result/:selected_option_id' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @question = Question.find(params[:question_id])
    @user = User.find(session[:user_id])
    @result = params[:option_result]
    selected_option = Option.find(params[:selected_option_id])
    @answer = selected_option.description

    @correct = Option.find_by(isCorrect: 1, question_id: params[:question_id])&.description
    if @result == 'true'
      @respuesta = 'RESPUESTA CORRECTA'
    else
      @respuesta = 'RESPUESTA INCORRECTA'
    end
    erb :asked
  end
  
  
  post '/asked/:question_id' do
    #user_id = session[:user_id]
    next_question = params[:question_id].to_i + 1
    redirect "/game/#{next_question}"
  end
  
  get '/logout' do
    session.clear
    redirect '/'
  end 

  get '/' do
    erb :start
  end


  get '/login' do
    erb :login
  end


  post '/login' do
    @user = User.find_by(username: params[:username])
    
    if @user && @user.password == params[:password]
      session[:user_id] = @user.id
      redirect '/menu'
    elsif @user 
        @password_error = "*contraseña incorrecta"
        erb :login
    else
      @password_error = "*datos ingresados no pertenecen a ninguna cuenta"
      erb :login
    end
  end 
  

  get '/register' do
    erb :register
  end


  post '/register' do
    # ya existe un jugador en la base de datos con ese usuario
    if !User.find_by(username: params[:username]).nil? 
      redirect '/register'
    end
    if params[:password] == params[:passwordTwo]
      @user = User.create(username: params[:username], password: params[:password], email: params[:email], birthdate: params[:birthdate])
      session[:user_id] = @user.id
      if @user.save # se guardo correctamente ese nuevo usuario en la tabla
        redirect '/menu'
      else
        redirect '/register'
      end
    else 
      redirect '/register'
    end
  end 




  get '/menu' do 
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    user_id = session[:user_id]
    @user = User.find(user_id)
    erb :menu, :locals => {:user_id => user_id}
  end 


  get '/practicar' do
    user_id = session[:user_id]
    @user = User.find(user_id)
    
    # array de todas los id de las preguntas que se le hicieron al usuario
    @questions_asked = AskedQuestion.where(user_id: user_id).pluck(:question_id) 
    session[:questions_asked] = @questions_asked

    #indice de la current question a practicar
    @question_index = 0 
    session[:question_index] = @question_index
    erb :practice
  end


  post '/practicar' do
    user_id = session[:user_id]
    @user = User.find(user_id)
    @question_index = session[:question_index].to_i + 1
    session[:question_index] = @question_index
    @questions_asked = session[:questions_asked]
    erb :practice
  end


  get '/ranking' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @users = User.order(points: :desc).limit(10) # arreglo de usuarios ordenados de manera descendente
    user = User.find(session[:user_id])
    @position = User.order(points: :desc).pluck(:id).find_index(session[:user_id]) + 1
    
    erb :ranking, :locals => {:user => user}
  end

  
  get '/profile' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @user = User.find(session[:user_id])
    erb :profile
  end

  
  get '/profile_change' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @user = User.find(session[:user_id])
    erb :profile_change
  end


  post '/profile_change' do
    user_id = session[:user_id]
    user = User.find_by(id: user_id)

    newUsername = params[:newUsername]
    currentPassword = params[:currentPassword]
    newPassword = params[:newPassword]
    newEmail = params[:newEmail]

    
    if newUsername != "" && (!User.find_by(username: newUsername).nil?)
      redirect '/profile_change'
    end
    if newPassword != "" && !currentPassword.nil? && (currentPassword != user.password )
      redirect '/profile_change'
    end 
    if newEmail != "" && (!User.find_by(email: newEmail).nil?)
      redirect '/profile_change'
    end

    if newUsername != ""
      user.update_column(:username, newUsername)
    end

    if newPassword != "" && currentPassword != ""
      user.update_column(:password, newPassword)
    end

    if newEmail != ""
      user.update_column(:email, newEmail)
    end
   
    if !user.save
      redirect '/menu'
    end

    redirect '/profile'
  end


  get '/tree' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    user_id = session[:user_id]
    @user = User.find(user_id)
    erb :tree
  end


  get '/play' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
  
    user_id = session[:user_id]
    @user = User.find(user_id)
    
    @total_questions = Question.count # Numero total de preguntas en el juego
    @user.update(points: 0)
    
    i = 1
    while i <= @total_questions
      asked_question = AskedQuestion.find_by(user_id: user_id, question_id: i)
      if asked_question
        asked_question.destroy
      end
      i += 1
    end
  
    redirect '/game/1'
  end

end

