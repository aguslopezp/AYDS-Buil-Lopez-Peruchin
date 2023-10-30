class GameController < Sinatra::Application
  # Hacer before
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

  post '/buyMoreTime' do
    user_id = session[:user_id]
    coins_to_decrement = 30

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
end
