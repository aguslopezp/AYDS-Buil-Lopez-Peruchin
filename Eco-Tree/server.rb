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

  get '/game/:id/:user_id' do
    @total_questions = Question.count # Numero total de preguntas en el juego
    @id = params[:id].to_i  # id de la pregunta a preguntar
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
    if @id <= @total_questions
      @question = Question.find(@id)  # pregunta de la bd con ese id
      @options = @question.options    # arreglo de opciones que pertenecen a esta @question con ese id
      erb :game
    else  # el juego se termino
      erb :game_finished
    end
  end 

  post '/game/:question_id/:user_id' do
    # Obtener la opción seleccionada de la base de datos a traves de los parametros
    selected_option = Option.find(params[:selected_option_id])
    next_question = params[:question_id].to_i + 1

    # Verificar si la opción seleccionada es correcta o no
    option_result = selected_option.isCorrect ? 'true' : 'false'
    
    if option_result 
      user = User.find(params[:user_id])
      if user.points.nil?
        user.update(points: 10)
      else 
        newPoints = user.points + 10
        user.update(points: newPoints)
      end
    end
    redirect "/game/#{next_question}/#{params[:user_id]}?option_result=#{option_result}"
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
      redirect '/'
    else
      redirect '/register'
    end
  end

  
  get '/register' do
    erb :register
  end


  post '/register' do
    @user = User.new(username: params[:username], password: params[:password], email: params[:email], birthdate: params[:birthdate])
    
    if @user.save
      redirect '/menu'
    else
      redirect '/register'
    end
  end 


  get '/menu' do 
    user_id = session[:user_id]
    erb :menu, :locals => {:user_id => user_id}
  end 
  
end

