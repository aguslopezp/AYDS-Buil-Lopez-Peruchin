# frozen_string_literal: true

# Modelo para representar las preguntas respondidas por el usuario
class AskedQuestion < ActiveRecord::Base
  has_many :questions
  has_many :users

  def self.create_asked_question(user_id, question_id)
    AskedQuestion.create(user_id: user_id, question_id: question_id)
  end

  def self.asked_question(user_id, question_id)
    record = AskedQuestion.find_by(user_id: user_id, question_id: question_id)
    !record.nil? # True si se respondio, False si no
  end
end
