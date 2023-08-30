require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'Option' do
    describe 'validations' do
      it 'requires a description' do
        option = Option.new(description: '', isCorrect: true)
        expect(option.valid?).to eq(false)
      end

      it 'requires an isCorrect field' do
        option = Option.new(description: 'description test', isCorrect: nil)
        expect(option.valid?).to eq(false)
      end

    end
end
