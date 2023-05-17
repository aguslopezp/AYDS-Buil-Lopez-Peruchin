require 'sinatra'
require 'sinatra/base'
require 'bundler/setup'
require 'logger'
require 'sinatra/activerecord'
require 'sinatra/reloader' if Sinatra::Base.environment == :development


require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/option'

class App < Sinatra::Application
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
    @total_questions = 30 # Numero total de preguntas en el juego
    @id = params[:id].to_i  # id de la pregunta a preguntar
    user_id = params[:user_id]
    @user = User.find(user_id)
    if @id <= @total_questions
      @question = Question.find(@id)  # pregunta de la bd con ese id
      @options = @question.options    # arreglo de opciones que pertenecen a esta @question con ese id
      erb :game
    else  # el juego se termino
      erb :game_finished
    end
  end 

  post '/game' do
    # Obtener la respuesta seleccionada por el usuario
    selected_option_id = params[:selected_option_id]
  
    # Obtener la opción seleccionada de la base de datos
    selected_option = Option.find(selected_option_id)

    # Verificar si la opción seleccionada es correcta o no
    if selected_option.isCorrect
      # La respuesta es correcta
      @option_result = "¡Respuesta correcta! :)"
    else
      # La respuesta es incorrecta
      @option_result = "Respuesta incorrecta! :("
    end
  end

  
  get '/' do
    erb :login  
  end


  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.password == params[:password]
      user = User.find_by(username: params[:username])
      redirect "/game/1/#{user.id}"
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
      redirect "/game/1/#{user.id}"
    else
      redirect '/register'
    end
  end 


  get '/users' do
    @users = User.all
    erb :users
  end

  
end

