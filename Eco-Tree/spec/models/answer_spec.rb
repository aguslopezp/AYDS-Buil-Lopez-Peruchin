# frozen_string_literal: true

require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'Answer' do
  describe 'validations' do
    it 'requires an option' do
      answer = Answer.new(user_id: '1', option_id: ' ')
      expect(answer.valid?).to eq(false)
    end

    it 'requires a user id' do
      answer = Answer.new(user_id: ' ', option_id: '2')
      expect(answer.valid?).to eq(false)
    end
  end
end
