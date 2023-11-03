class AskedQuestion < ActiveRecord::Base  
    has_many :questions
    has_many :users

    def self.asked_question(user_id, question_id)
       record = AskedQuestion.find_by(user_id: user_id, question_id: question_id)
       return !record.nil? # True si encontró, False si no
    end
end