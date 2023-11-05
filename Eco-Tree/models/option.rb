class Option < ActiveRecord::Base
  belongs_to :question

  validates :description, presence: true
  #validates :isCorrect, presence: true
  validate :isCorrect_boolean_value

  def self.find(option_id)
    Option.find_by(id: option_id)
  end

  def self.find_correct_option(question_id)
    Option.find_by(isCorrect: 1, question_id: question_id)&.description
  end

  private
    def isCorrect_boolean_value
      unless [true,false].include?(isCorrect)
        errors.add(:isCorrect, "isCorrect must be true or false")
      end
    end
end