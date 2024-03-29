# frozen_string_literal: true

# Clase que representa al modelo Option
class Option < ActiveRecord::Base
  belongs_to :question

  validates :description, presence: true
  validate :correct_boolean_value

  def self.find(option_id)
    Option.find_by(id: option_id)
  end

  def self.incorrect_options(id)
    Option.where(question_id: id, isCorrect: false).pluck(:id)
  end

  def self.find_correct_option(question_id)
    Option.find_by(isCorrect: 1, question_id: question_id)&.description
  end

  private

  def correct_boolean_value
    errors.add(:isCorrect, 'isCorrect must be true or false') unless [true, false].include?(isCorrect)
  end
end
