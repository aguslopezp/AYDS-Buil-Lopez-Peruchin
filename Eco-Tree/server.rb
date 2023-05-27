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
  set :session_secret, 'la_mano_de_dios'
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
    # Obtener la opción seleccionada de la base de datos a traves de los parametros
    selected_option = Option.find(params[:selected_option_id])
    user_id = session[:user_id]
    # Verificar si la opción seleccionada es correcta o no
    option_result = selected_option.isCorrect ? 'true' : 'false'
    
    # Calculo puntos del usuario
    if option_result == 'true'
      user = User.find(user_id)
      if user.points.nil?
        user.update(points: 10)
      else 
        newPoints = user.points + 10
        user.update(points: newPoints)
      end
    end

    # Guardo en la tabla answers la respuesta del usuario
    Answer.create(user_id: user_id, option_id: params[:selected_option_id])

    # Respuesta preguntada se marcara como preguntada para no volver a preguntarse
    AskedQuestion.create(user_id: user_id, question_id: params[:question_id])
    
    redirect "/asked/#{params[:question_id]}/#{option_result}"
  end


  get '/asked/:question_id/:option_result' do
    @question = Question.find(params[:question_id])
    @user = User.find(session[:user_id])
    @result = params[:option_result]
    @answer = params[:selected_option]
    if @result == 'true'
      @respuesta = 'Respuesta correcta! :)'
    else
      @respuesta = 'Respuesta incorrecta! :('
    end
    erb :asked
  end
  
  
  post '/asked/:question_id' do
    #user_id = session[:user_id]
    next_question = params[:question_id].to_i + 1
    redirect "/game/#{next_question}"
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
        redirect '/login'
    else
      redirect '/register'
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
    user_id = session[:user_id]
    @user = User.find(user_id)
    erb :menu, :locals => {:user_id => user_id}
  end 


  get '/profile' do
    @user = User.find(session[:user_id])
    erb :profile
  end

end

