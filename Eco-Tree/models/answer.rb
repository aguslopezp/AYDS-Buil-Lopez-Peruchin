class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :option

  validates :option_id, presence: true
  validates :user_id, presence: true

  def self.createAnswer(user_id, option_id)
    Answer.create(user_id: user_id, option_id: option_id)
  end

end