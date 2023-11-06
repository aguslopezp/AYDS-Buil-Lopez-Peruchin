# frozen_string_literal: true

# Modelo de pregunta
class Question < ActiveRecord::Base
  has_many :options
  has_many :users

  validates :description, presence: true
  validates :detail, presence: true

  # Returns the total number of questions.
  def self.total_questions
    Question.count
  end

  def self.first_question_level(level)
    Question.where(level: level).first
  end

  def self.all_levels
    Question.distinct.pluck(:level)
  end

  def self.find_question(id)
    Question.find_by(id: id)
  end

  def self.find_options(id)
    Option.where(question_id: id)
  end

  def self.find_next_question(current_question_id, user_id, total_questions)
    next_question_id = current_question_id
    while next_question_id <= total_questions
      unless AskedQuestion.asked_question(user_id, next_question_id)
        question = Question.find_question(next_question_id)
        options = Question.find_options(next_question_id)
        return { question: question, options: options }
      end
      next_question_id += 1
    end
    nil
  end
end
