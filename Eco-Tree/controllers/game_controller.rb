# frozen_string_literal: true

# Este controlador contiene todos los endpoints correspondientes al juego
class GameController < Sinatra::Application
  get '/game/:id_question' do
    session[:tree] = true
    @user = User.current_user(session[:user_id])
    question_id = params[:id_question].to_i
    @level_selected = params[:level].to_i
    total_questions = Question.total_questions
    redirect '/levels' if question_id > total_questions
    new_question = Question.find_next_question(question_id, @user.id, total_questions)
    if new_question.nil?
      erb :game_finished
    else
      @question, @options = new_question.values_at(:question, :options)
      session[:question_id] = @question.id
      erb(@level_selected != @question.level ? :level_finished : :game)
    end
  end

  post '/game/:question_id' do
    user = User.current_user(session[:user_id])
    level = params[:level]
    selected_option_id = params[:selected_option_id]
    question_id = params[:question_id].to_i
    if selected_option_id.nil? && params[:timeout] == 'true'
      AskedQuestion.createAskedQuestion(user.id, question_id)
      redirect "/asked/#{question_id}/nil/nil?level=#{level}"
    end
    selected_option = Option.find(selected_option_id)
    # Calculo puntos del usuario si no la respondio nunca
    unless AskedQuestion.asked_question(user.id, question_id)
      if selected_option.isCorrect
        user.update_poins()
      else
        user.reset_streak
      end
      Answer.createAnswer(user.id, selected_option_id)
      AskedQuestion.createAskedQuestion(user.id, question_id)
    end
    redirect "/asked/#{question_id}/#{selected_option.isCorrect}/#{selected_option_id}?level=#{level}"
  end

  get '/levels' do
    user = User.current_user(session[:user_id])
    @disabled_level = params[:disabled_level]
    @reset = params[:reset]
    @points = user.points
    @levels = Question.distinct.pluck(:level)
    erb :levels
  end

  post '/levels' do
    user_id = session[:user_id]
    level = params[:levelSelected]
    question = Question.where(level: level).first
    previous_question = question.id - 1
    redirect "/game/#{question.id}?level=#{level}" if previous_question <= 0
    response = AskedQuestion.find_by(user_id: user_id, question_id: previous_question).nil?
    if response
      redirect '/levels?disabled_level=true'
    else
      redirect "/game/#{question.id}?level=#{level}"
    end
  end

  post '/buyMoreTime' do
    coins_to_decrement = 30
    if @user.coin >= coins_to_decrement
      @user.discount_coins(coins_to_decrement)
      content_type :json
      { success: true, updatedCoins: @user.coin }.to_json
    else
      content_type :json
      { success: false }.to_json
    end
  end

  post '/incorrectOptions' do
    coins_to_decrement = 10
    question_id = session[:question_id]

    if @user.coin >= coins_to_decrement
      @user.discount_coins(coins_to_decrement)
      incorrect_options = Option.incorrect_options(question_id)
      content_type :json
      { success: true, updatedCoins: @user.coin, incorrect_options: incorrect_options }.to_json
    else
      content_type :json
      { success: false }.to_json
    end
  end

  get '/asked/:question_id/:option_result/:selected_option_id' do
    redirect '/' if session[:user_id].nil?
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
    @respuesta = if @result == 'true'
                   'RESPUESTA CORRECTA'
                 elsif @result == 'false'
                   'RESPUESTA INCORRECTA'
                 else
                   'SE AGOTO EL TIEMPO'
                 end
    erb :asked
  end

  post '/asked/:question_id' do
    # user_id = session[:user_id]
    next_question = params[:question_id].to_i
    level = params[:level]
    session[:question_id] = next_question
    redirect "/game/#{next_question}?level=#{level}"
  end

  get '/play' do
    redirect '/' if session[:user_id].nil?

    user_id = session[:user_id]
    @user = User.find(user_id)

    @total_questions = Question.count
    @user.update(points: 0)

    @user.reset_streak

    i = 1
    while i <= @total_questions
      asked_question = AskedQuestion.find_by(user_id: user_id, question_id: i)
      asked_question&.destroy
      i += 1
    end
    reset = true
    redirect "/levels?reset=#{reset}"
  end
end
