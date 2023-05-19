class AskedQuestion < ActiveRecord::Base  
    has_many :questions
    has_many :users
end