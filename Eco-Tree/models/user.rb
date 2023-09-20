class User < ActiveRecord::Base  
  has_many :questions
  has_many :answers, through: :questions
  
  validates :username, presence: true, length: { minimum: 3, message: "username must be at least 3 characters"  }
  validates :password, presence: true, length: { minimum: 6, message: "password must be at least 6 characters" } 
  validates :email, presence: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "invalid email format" }
  validates :birthdate, presence: true
  validates :points, presence: true
  validate :points_non_negative

  
  
  def suma_points
    self.points += 1  
    save
  end

  #desencripta password y la compara con la ingresada
  def compare_password(hash_pass, password)
    return BCrypt::Password.new(hash_pass) == password
  end

  private

  def points_non_negative
    if points.nil? || points < 0
      errors.add(:points, "must be greater than or equal to 0")
    end
  end
  
end
  


