require 'sinatra'
require 'sinatra/base'
require 'bundler/setup'
require 'logger'
require 'sinatra/activerecord'
require 'sinatra/cookies'
require 'bcrypt'
require 'mail' 
require 'sinatra/reloader' if Sinatra::Base.environment == :development

require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/option'
require_relative 'models/asked_question'
require_relative 'models/answer'
require_relative 'models/item'
require_relative 'models/purchased_item'
require_relative 'methods'

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
    session[:tree] = true #de arbol vuelve a game
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @total_questions = Question.count # Numero total de preguntas en el juego
    @id_question = params[:id_question].to_i  # id de la pregunta a preguntar
    @level_selected = params[:level].to_i # este parámetro level viene de el post /levels

    user_id = session[:user_id] 
    @user = User.find(user_id)

    # consultamos si esa pregunta habia sido preguntada
    asked_question = AskedQuestion.find_by(user_id: user_id, question_id: @id_question)

    # Es un id de pregunta valido y nunca fue preguntada a ese usuario
    if @id_question  <= @total_questions && asked_question.nil?
      @question = Question.find_by(id: @id_question)  # pregunta de la bd con ese id
      @options = Option.where(question_id: @question.id) # arreglo de opciones que pertenecen a esta @question con ese id
      level_question = @question.level
      # controlo para ver si las preguntas de el nivel seleccionado fueron contestadas
      if @level_selected != level_question
        erb :level_finished
      else
        erb :game
      end
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
        session[:question_id] = @id_question
        @question = Question.find_by(id: @id_question)  
        @options = Option.where(question_id: @question.id)
        level_question = @question.level
        # controlo para ver si las preguntas de el nivel seleccionado fueron contestadas
        if @level_selected != level_question
          erb :level_finished
        else
          erb :game
        end
      end
    else  # el juego se termino
      erb :game_finished
    end
  end 
  

  post '/buyMoreTime' do
    user_id = session[:user_id]
    coins_to_decrement = 20

    user = User.find(user_id)
  
    if user.coin >= coins_to_decrement
      user.update(coin: user.coin - coins_to_decrement)
      content_type :json
      { success: true, updatedCoins: user.coin }.to_json
    else
      content_type :json
      { success: false }.to_json
    end
  end

  
  post '/incorrectOptions' do
    user_id = session[:user_id]
    coins_to_decrement = 10

    question_id = session[:question_id]  

    user = User.find(user_id)
  
    if user.coin >= coins_to_decrement
      user.update(coin: user.coin - coins_to_decrement)
      incorrect_options = Option.where(question_id: question_id, isCorrect: false).pluck(:id)
      content_type :json
      { success: true, updatedCoins: user.coin, incorrect_options: incorrect_options }.to_json
    else
      content_type :json
      { success: false }.to_json
    end
  end

  
  post '/game/:question_id' do
    user_id = session[:user_id]
    level = params[:level]
    if params[:selected_option_id].nil? && params[:timeout] == 'false'
      question_id = params[:question_id]
      redirect "/game/#{question_id}"
    end

    if params[:selected_option_id].nil? && params[:timeout] == 'true'

      # Respuesta preguntada se marcara como preguntada para no volver a preguntarse
      AskedQuestion.create(user_id: user_id, question_id: params[:question_id])
      option_result = 'nil'
      selected_option_id = 999999

      # Guardo en la tabla answers la respuesta del usuario, la cual fue nil. No lo crea
      #Answer.create(user_id: user_id, option_id: nil)

      redirect "/asked/#{params[:question_id]}/#{option_result}/#{selected_option_id}?level=#{level}"
    end
    # Obtener la opción seleccionada de la base de datos a traves de los parametros
    selected_option = Option.find(params[:selected_option_id])
    # Verificar si la opción seleccionada es correcta o no
    option_result = selected_option.isCorrect ? 'true' : 'false'
    
    # Calculo puntos del usuario
    user = User.find(user_id)
    if AskedQuestion.find_by(user_id: user_id, question_id: params[:question_id]).nil?
      if option_result == 'true'
        user.sum_points
        user.sum_streak
        user.sum_10_coins
        if (user.streak % 3) == 0
          user.add_streak_to_points(user.streak / 3)
          user.add_coins_from_streak((user.streak / 3) * 10)
        end
      else
        user.reset_streak
      end

      # Guardo en la tabla answers la respuesta del usuario
      Answer.create(user_id: user_id, option_id: params[:selected_option_id])
      
      # Respuesta preguntada se marcara como preguntada para no volver a preguntarse (para no ser preguntada nuevamente, en una nueva ocasion)
      AskedQuestion.create(user_id: user_id, question_id: params[:question_id])

    end
    
    redirect "/asked/#{params[:question_id]}/#{option_result}/#{params[:selected_option_id]}?level=#{level}"
  end
  
  get '/levels' do
    user_id = session[:user_id]
    user = User.find(user_id)
    @disabled_level = params[:disabled_level]
    @reset = params[:reset]
    @points = user.points
    @levels = Question.distinct.pluck(:level)
    erb :levels
  end

  post '/levels' do
    user_id = session[:user_id]
    level = params[:levelSelected]
    question = Question.where(level: level).first()
    # obtengo la última pregunta del nivel anterior
    previous_question = question.id - 1
    if previous_question <= 0
      redirect "/game/#{question.id}?level=#{level}"
    end
    disabled_level = true
    response = AskedQuestion.find_by(user_id: user_id, question_id: previous_question).nil?

    # contro si puede acceder al nivel
    if response # response tiene true porque no encontró respuesta
      redirect "/levels?disabled_level=#{disabled_level}"
    else
      disabled_level = false
      redirect "/game/#{question.id}?level=#{level}"
    end
  end

  get '/asked/:question_id/:option_result/:selected_option_id' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    @question = Question.find(params[:question_id])
    @user = User.find(session[:user_id])
    @result = params[:option_result]
    @level = params[:level]
    if @result == 'nil'
      @answer = 'Respuesta no contestada'
    else
      selected_option = Option.find(params[:selected_option_id])
      @answer = selected_option.description
    end
    
    @streak = @user.streak

    @correct = Option.find_by(isCorrect: 1, question_id: params[:question_id])&.description
    if @result == 'true'
      @respuesta = 'RESPUESTA CORRECTA'
    elsif @result == 'false'
      @respuesta = 'RESPUESTA INCORRECTA'
    else 
      @respuesta = 'SE AGOTO EL TIEMPO'
    end
    erb :asked
  end
  
  
  post '/asked/:question_id' do
    #user_id = session[:user_id]
    next_question = params[:question_id].to_i + 1
    level = params[:level]
    session[:question_id] = next_question
    redirect "/game/#{next_question}?level=#{level}"
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
    input_password = params[:password]
    if @user && @user.compare_password(@user.password, input_password)
      session[:user_id] = @user.id

      session[:hoja] = Item.find_by(id: 6).name
      session[:fondo] = Item.find_by(id: 10).name
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

    #genera un codigo de 6 caracteres 
    code_random = generate_random_code(6)
    session[:code] = code_random
    session[:question_id] = 1

    # ya existe un jugador en la base de datos con ese usuario
    if !(User.find_by(username: params[:username]).nil?) 
      redirect '/register'
    end

    if params[:password] == params[:passwordTwo]
      passw = hash_password(params[:password])
      
      @user = User.create(username: params[:username], password: passw, email: params[:email], birthdate: params[:birthdate], leaf_id: 6, background_id: 10)
      session[:user_id] = @user.id
      if @user.save # se guardo correctamente ese nuevo usuario en la tabla
        #envia el email
        send_verificated_email(@user.email, session[:code])

        #setear arbol y hoja por defecto
        PurchasedItem.create(user_id: @user.id, item_id: 6)
        PurchasedItem.create(user_id: @user.id, item_id: 10)
        
        session[:hoja] = Item.find_by(id: 6).name
        session[:fondo] = Item.find_by(id: 10).name

        redirect '/validate'
      else
        redirect '/register'
      end
    else 
      redirect '/register'
    end
  end 




  get '/menu' do 
    session[:tree] = false
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
    @verificated = @user.valid_email
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
    hoja_id = @user.leaf_id #Busco el id de la actual compra del usuario
    fondo_id = @user.background_id 
    @tree = session[:tree]
    @hoja = Item.find_by(id: hoja_id).name  #con ese id busco en los items y paso el nombre
    @fondo = Item.find_by(id: fondo_id).name
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

    @user.reset_streak
    
    i = 1
    while i <= @total_questions
      asked_question = AskedQuestion.find_by(user_id: user_id, question_id: i)
      if asked_question
        asked_question.destroy
      end
      i += 1
    end
    reset = true
    redirect "/levels?reset=#{reset}"
  end

  get '/store' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    erb :store
  end

  get '/validate' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    erb :validate
  end

  post '/validate' do    
    if session[:code] == params[:codigo]
      user = User.find(session[:user_id])
      user.update_column(:valid_email, true)
    end
    redirect '/menu'
  end

  get '/buySkin' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    @item = Item.where(section: 'hoja')
    @leaf_id = User.find(user_id).leaf_id
   
  
    purchased_item_ids = PurchasedItem.where(user_id: user_id).pluck(:item_id) #busca los items que compro el usuario
    
    @item_comprados = {}  #inicializa el hash
    @item_price = {}
    @item.each do |item|
      @item_comprados[item.id] = purchased_item_ids.include?(item.id) #mete true si el id de los items esta en los comprados por el usuario
      @item_price[item.id] = item.price 
    end
    
    erb :buySkin
  end
  

  post '/buySkin' do
    request_body = JSON.parse(request.body.read)
    name = request_body['name'] #json

    user_id = session[:user_id]
    item_id = Item.find_by(name: name).id
    user = User.find_by(id: user_id)
    item_price = Item.find_by(name: name).price

    #Si no lo compro lo agrega
    if PurchasedItem.find_by(item_id: item_id, user_id: user_id).nil?
      PurchasedItem.create(user_id: user_id, item_id: item_id)
      
      if (item_price <= user.coin)
        user.discount_coins(item_price)
      end

    end
    #setea la nueva hoja elegida por el usuario, este comprada o no
    user.update_column(:leaf_id, item_id)
  end

  get '/buyFondo' do
    if session[:user_id].nil?
      redirect '/' # Redirigir al inicio de sesión si la sesión no está activa
    end
    
    user_id = session[:user_id]
    @user = User.find(user_id)
    @coin = @user.coin
    @item = Item.where(section: 'fondo')
    @background_id = User.find(user_id).background_id


    purchased_item_ids = PurchasedItem.where(user_id: user_id).pluck(:item_id) #busca los items que compro el usuario
    
    @item_comprados = {}  #inicializa el hash
    @item_price = {}
    @item.each do |item|
      @item_comprados[item.id] = purchased_item_ids.include?(item.id) #mete true si el id de los items esta en los comprados por el usuario
      @item_price[item.id] = item.price 
    end
    
    erb :buyFondo
  end

  post '/buyFondo' do
    request_body = JSON.parse(request.body.read)
    name = request_body['name']
    user_id = session[:user_id]
    item_id = Item.find_by(name: name).id
    user = User.find_by(id: user_id)
    item_price = Item.find_by(name: name).price

    
    if PurchasedItem.find_by(item_id: item_id, user_id: user_id).nil?
      PurchasedItem.create(user_id: user_id, item_id: item_id)

      if (item_price <= user.coin)
        user.discount_coins(item_price)
      end

    end
    #setea el nuevo fondo elegido por el usuario
    user.update_column(:background_id, item_id)
  end

end