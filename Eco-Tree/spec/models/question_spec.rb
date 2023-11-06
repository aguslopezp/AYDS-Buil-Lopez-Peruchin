# frozen_string_literal: true

require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'Question' do
  describe 'validations' do
    it 'requires a description' do
      question = Question.create(description: '', detail: 'detail test')
      expect(question.valid?).to eq(false)
    end

    it 'requires a detail' do
      question = Question.create(description: 'description test', detail: '')
      expect(question.valid?).to eq(false)
    end
  end
end
