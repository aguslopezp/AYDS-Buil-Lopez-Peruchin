#encripta la password
def hash_password(pass)
  salt = BCrypt::Engine.generate_salt
  hashed_password = BCrypt::Engine.hash_secret(pass, salt)
  return hashed_password
end


#genera un codigo random
def generate_random_code(length)
  characters = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
  code = (0...length).map { characters[rand(characters.length)] }.join
end


# Método para enviar el correo de bienvenida
def send_verificated_email(email, code)
  options = {
    address: 'smtp.gmail.com', 
    port: 587,
    user_name: 'eco.treeOk@gmail.com',
    password: password = 'dcbr arax jeax jmpp',
    authentication: 'plain',
    enable_starttls_auto: true
  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  mail = Mail.new do
    from    'eco.treeOk@gmail.com'
    to      email 
    subject 'Bienvenido a Eco-Tree'
    body    "Felicidades, eres parte de la familia Eco.\n
            Te enviamos el codigo para que ingreses, esto es necesario para validar tu email.\n
            Este es el código de seguridad, no lo compartas con nadie\n
            Código: #{code}" 
  end
  mail.deliver      
end