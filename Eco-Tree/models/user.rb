# frozen_string_literal: true

# Modelo para representar un usuario en el sistema
class User < ActiveRecord::Base
  has_many :questions
  has_many :answers, through: :questions

  validates :username, presence: true, length: { minimum: 3, message: 'username must be at least 3 characters' }
  validates :password, presence: true, length: { minimum: 6, message: 'password must be at least 6 characters' }
  validates :email, presence: true,
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: 'invalid email format' }
  validates :birthdate, presence: true
  validates :points, presence: true
  validates :streak, presence: true
  validate :points_non_negative

  def self.current_user(id)
    User.find_by(id: id)
  end

  def sum_points
    self.points += 1
    save
  end

  def add_streak_to_points(streak)
    self.points += streak
    save
  end

  def sum_streak
    self.streak += 1
    save
  end

  # Actualiza puntos, racha, monedas cuando el usuario responde bien
  def update_points
    sum_points
    sum_streak
    sum_10_coins
    return unless (self.streak % 3).zero?

    add_streak_to_points(self.streak / 3)
    add_coins_from_streak((self.streak / 3) * 10)
  end

  def reset_streak
    self.streak = 0
    save
  end

  def reset_progress
    update(points: 0)
    reset_streak
    (1..Question.total_questions).each do |i|
      asked_question = AskedQuestion.find_by(user_id: self.id, question_id: i)
      asked_question&.destroy
    end
  end

  # descuenta las monedas que vale la compra
  def discount_coins(coins)
    self.coin -= coins
    save
  end

  def sum_10_coins
    self.coin += 10
    save
  end

  def add_coins_from_streak(coins)
    self.coin += coins
    save
  end

  # desencripta password y la compara con la ingresada
  def compare_password(hash_pass, password)
    BCrypt::Password.new(hash_pass) == password
  end

  private

  def points_non_negative
    errors.add(:points, 'must be greater than or equal to 0') if points.nil? || points.negative?
  end
end
