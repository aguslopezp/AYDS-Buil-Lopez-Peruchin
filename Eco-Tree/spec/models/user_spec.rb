require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'User' do
  describe 'valid' do
    describe 'when there is no name' do
      it 'should be invalid' do
        #Arrage
        u = User.new(username: 'usertest',
                     password: '123',
                     email:'usertest@email.test',
                     birthdate: 1999-12-12)
        #Assert
        expect(u.valid?).to eq(true)
      end
    end
  end
end

describe 'User' do
  describe 'valid' do
    describe 'when there is no name' do
      it 'should be invalid' do
        #Arrage
        u = User.new(username: ' ',
                     password: '123',
                     email:'usertest@email.test',
                     birthdate: 1999-12-12)
        #Assert
        expect(u.valid?).to eq(false)
      end
    end
  end
end

describe 'User' do
  describe 'valid' do
    describe 'when there is no name' do
      it 'should be invalid' do
        #Arrage
        u = User.new(points: 1)
        #Assert
        expect(u.valid?).to eq(false)
      end
    end
  end
end