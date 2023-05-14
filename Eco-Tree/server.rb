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


  get '/game' do
    logger.info 'USANDO LOGGER INFO EN GAME PATH'
    @descriptions = Question.pluck(:description)  # arreglo con las descripciones de todos los registros de la tabla
    @question1 = @descriptions[0] # me guardo la descripcion de la primera pregunta
    @options = Option.where(question_id: '1')
    erb :game
  end
  

  get '/' do
    erb :login  
  end


  post '/login' do
    @user = User.find_by(username: params[:username])

    if @user && @user.password == params[:password]
      redirect '/game'
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
      redirect '/game'  
    else
      redirect '/register'
    end
  end 


  get '/users' do
    @users = User.all
    erb :users
  end
end

