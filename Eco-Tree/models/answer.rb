class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :option

  validates :option_id, presence: true
  validates :user_id, presence: true
end