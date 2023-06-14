class User < ActiveRecord::Base  
  has_many :questions
  has_many :answers, through: :questions
  
  validates :username, presence: true
  validates :password, presence: true
  validates :email, presence: true
  validates :birthdate, presence: true
end