class Question < ActiveRecord::Base
  has_many :options
  has_many :users

  validates :description, presence: true
  validates :detail, presence: true
end