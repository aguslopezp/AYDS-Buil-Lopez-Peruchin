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


  get '/game/:id_question/:user_id' do
    @total_questions = Question.count # Numero total de preguntas en el juego
    @id_question = params[:id_question].to_i  # id de la pregunta a preguntar
    @option_result = params[:option_result]
    @result = ' '
    if @option_result.nil?
      @result = ' '
    else
      if @option_result == 'true'
        @result = 'Respuesta correcta'
      else
        @result = 'Respuesta incorrecta'
      end
    end
    
    user_id = session[:user_id] 
    @user = User.find(user_id)
    if @id_question  <= @total_questions
      @question = Question.find(@id_question)  # pregunta de la bd con ese id
      @options = @question.options    # arreglo de opciones que pertenecen a esta @question con ese id
      erb :game
    else  # el juego se termino
      erb :game_finished
    end
  end 


  post '/game/:question_id/:user_id' do
    # Obtener la opción seleccionada de la base de datos a traves de los parametros
    selected_option = Option.find(params[:selected_option_id])

    # Verificar si la opción seleccionada es correcta o no
    option_result = selected_option.isCorrect ? 'true' : 'false'
    
    if option_result == 'true'
      user = User.find(params[:user_id])
      if user.points.nil?
        user.update(points: 10)
      else 
        newPoints = user.points + 10
        user.update(points: newPoints)
      end
    end
    redirect "/asked/#{params[:question_id]}/#{params[:user_id]}/#{option_result}"
  end


  get '/asked/:question_id/:user_id/:option_result' do
    @question = Question.find(params[:question_id])
    @user = User.find(params[:user_id])
    @result = params[:option_result]
    if @result == 'true'
      @respuesta = 'Respuesta correcta! :)'
    else
      @respuesta = 'Respuesta incorrecta! :('
    end
    erb :asked
  end
  
  
  post '/asked/:question_id/:user_id' do
    #user_id = session[:user_id]
    next_question = params[:question_id].to_i + 1 

    redirect "/game/#{next_question}/#{params[:user_id]}"
  end
  

  get '/' do
    erb :start
  end


  get '/login' do
    erb :login
  end


  post '/login' do
    @user = User.find_by(username: params[:username])
    
    @confPass = (@user.password == params[:passwordTwo])

    if  @confPass 
      if @user && @user.password == params[:password]
        session[:user_id] = @user.id
        redirect '/menu'
      elsif @user 
        redirect '/'
      else
        redirect '/register'
      end

    else
      redirect '/login'
    end
  end

  
  get '/register' do
    erb :register
  end


  post '/register' do
    @user = User.new(username: params[:username], password: params[:password], email: params[:email], birthdate: params[:birthdate])
    
    if @user.save # se guardo correctamente ese nuevo usuario a la tabla
      redirect '/menu'
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
    erb :profile
  end

end

