# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'bundler/setup'
require 'logger'
require 'sinatra/activerecord'
require 'sinatra/cookies'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

require './controllers/authentication_controller.rb'
require './controllers/game_controller'
require './controllers/store_controller'
require './controllers/menu_controller'

require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/option'
require_relative 'models/asked_question'
require_relative 'models/answer'
require_relative 'models/item'
require_relative 'models/purchased_item'

# Clase principal para definir la aplicacion de Sinatra
class App < Sinatra::Application
  use AuthenticationController
  use GameController
  use MenuController
  use StoreController

  enable :sessions
  # Configuracion de la clave secreta de sesion
  set :root, File.dirname(__FILE__)
  set :session_secret, 'la_pelota_no_se_mancha'
  set :public_folder, File.dirname(__FILE__) + '/public'

  def initialize(_app = nil)
    super()
  end

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

  get '/' do
    erb :start
  end
end
