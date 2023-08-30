class Option < ActiveRecord::Base
  belongs_to :question

  validates :description, presence: true
  validates :isCorrect, presence: true

  private
    def isCorrect_boolean_value
      unless [true,false].include?(isCorrect)
        errors.add(:isCorrect, "isCorrect must be true or false")
      end
    end
end