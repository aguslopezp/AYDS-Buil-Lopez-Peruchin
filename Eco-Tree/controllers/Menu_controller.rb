class MenuController < Sinatra::Application
  
  # Hacer before

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


end