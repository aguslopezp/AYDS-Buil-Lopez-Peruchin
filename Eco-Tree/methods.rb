# frozen_string_literal: true

# encripta la password
def hash_password(pass)
  salt = BCrypt::Engine.generate_salt
  hashed_password = BCrypt::Engine.hash_secret(pass, salt)
  hashed_password
end

# genera un codigo random
def generate_random_code(length)
  characters = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
  (0...length).map { characters[rand(characters.length)] }.join
end

# Constantes
OPTIONS = {
  address: 'smtp.gmail.com',
  port: 587,
  user_name: 'eco.treeOk@gmail.com',
  password: 'dcbr arax jeax jmpp',
  authentication: 'plain',
  enable_starttls_auto: true
}.freeze

MESSAGE = "Felicidades, eres parte de la familia Eco.\n
          Te enviamos el código para que ingreses, esto es necesario para validar tu email.\n
          Este es el código de seguridad, no lo compartas con nadie\n Código:"

# Metodo para enviar el correo de bienvenida
def send_verificated_email(email, code)
  Mail.defaults do
    delivery_method :smtp, OPTIONS
  end

  mail = Mail.new do
    from    'eco.treeOk@gmail.com'
    to      email
    subject 'Bienvenido a Eco-Tree'
    body MESSAGE + ' ' + code.to_s
  end
  mail.deliver
end
