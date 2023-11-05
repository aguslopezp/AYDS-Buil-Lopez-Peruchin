# frozen_string_literal: true

# Clase que representa al modelo Option
class Option < ActiveRecord::Base
  belongs_to :question

  validates :description, presence: true
  # validates :isCorrect, presence: true
  validate :isCorrect_boolean_value

  def self.find(option_id)
    Option.find_by(id: option_id)
  end

  def self.incorrect_options(id)
    return Option.where(question_id: id, isCorrect: false).pluck(:id)
  end

  private

    def isCorrect_boolean_value
      unless [true,false].include?(isCorrect)
        errors.add(:isCorrect, "isCorrect must be true or false")
      end
    end
end