class Question < ActiveRecord::Base
  has_many :options
  has_many :users

  validates :description, presence: true
  validates :detail, presence: true

  # Returns the total number of questions.
  def self.total_questions
    return Question.count
  end

  def self.find_question(id)
    Question.find_by(id: id)
  end

  def self.find_options(id)
    Option.where(question_id: id)
  end

  def self.get_question_with_options(id)
    question = Question.find_question(id)
    options = Question.find_options(id)
    { question: question, options: options }
  end

  def self.find_next_question(current_question_id, user_id, total_questions)
    next_question_id = current_question_id + 1
    while next_question_id <= total_questions 
      if !AskedQuestion.asked_question(user_id, next_question_id)
        return next_question_id
      end
      next_question_id += 1
    end
    return nil
  end

end