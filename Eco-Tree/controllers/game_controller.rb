# frozen_string_literal: true

# Este controlador contiene todos los endpoints correspondientes al juego
class GameController < Sinatra::Application
  before do
    redirect '/' if session[:user_id].nil? && request.path_info != '/'
    @user = User.current_user(:id, session[:user_id]) unless session[:user_id].nil?
  end

  get '/game/:id_question' do
    session[:tree] = true
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
    level = params[:level]
    selected_option_id = params[:selected_option_id]
    question_id = params[:question_id].to_i
    if selected_option_id.nil? && params[:timeout] == 'true'
      AskedQuestion.createAskedQuestion(@user.id, question_id)
      redirect "/asked/#{question_id}/nil/nil?level=#{level}"
    end
    selected_option = Option.find(selected_option_id)
    # Calculo puntos del usuario si no la respondio nunca
    unless AskedQuestion.asked_question(@user.id, question_id)
      selected_option.isCorrect ? @user.update_points : @user.reset_streak
      Answer.createAnswer(@user.id, selected_option_id)
      AskedQuestion.createAskedQuestion(@user.id, question_id)
    end
    redirect "/asked/#{question_id}/#{selected_option.isCorrect}/#{selected_option_id}?level=#{level}"
  end

  get '/levels' do
    @disabled_level = params[:disabled_level]
    @reset = params[:reset]
    @points = @user.points
    @levels = Question.all_levels
    erb :levels
  end

  post '/levels' do
    level = params[:level_selected]
    question = Question.first_question_level(level)
    puts "level: #{level}, question_id: #{question.id}"
    previous_question_id = question.id - 1
    redirect "/game/#{question.id}?level=#{level}" if previous_question_id <= 0
    response = AskedQuestion.asked_question(@user.id, previous_question_id)
    response ? (redirect "/game/#{question.id}?level=#{level}") : (redirect '/levels?disabled_level=true')
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
    @question = Question.find_question(params[:question_id])
    @result = params[:option_result]
    @level = params[:level]
    if @result == 'true'
      @respuesta = 'RESPUESTA CORRECTA'
      @user_answer = Option.find(params[:selected_option_id]).description
    elsif @result == 'false'
      @respuesta = 'RESPUESTA INCORRECTA'
      @user_answer = Option.find(params[:selected_option_id]).description
    else
      @user_answer = 'Pregunta no contestada'
      @respuesta = 'SE AGOTO EL TIEMPO'
    end
    @user = User.current_user(:id, session[:user_id])
    @streak = @user.streak
    @correct_answer = Option.find_correct_option(@question.id)
    erb :asked
  end

  post '/asked/:question_id' do
    next_question = params[:question_id].to_i
    level = params[:level]
    session[:question_id] = next_question
    redirect "/game/#{next_question}?level=#{level}"
  end

  get '/play' do
    @user.reset_progress
    redirect '/levels?reset=true'
  end
end
