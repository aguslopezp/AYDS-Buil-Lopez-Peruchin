require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'Option' do
    describe 'validations' do
      it 'requires a description' do
        option = Option.new(description: '', isCorrect: true)
        expect(option.valid?).to eq(false)
        #expect(optiom.errors[:description]).to include("description can't be blank")
      end

      it 'requires an isCorrect field' do
        option = Option.new(description: 'description test', isCorrect: nil)
        expect(option.valid?).to eq(false)
        #expect(optiom.errors[:isCorrect]).to include("the isCorrect field can't be blank")
      end

    end
end
