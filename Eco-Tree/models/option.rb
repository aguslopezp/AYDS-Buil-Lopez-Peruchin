class Option < ActiveRecord::Base
  belongs_to :question

  validates :description, presence: true
  validates :isCorrect, presence: true
end