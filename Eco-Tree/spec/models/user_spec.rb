require 'sinatra/activerecord'
require_relative '../../models/init.rb'

describe 'User' do
  describe 'valid' do
    describe 'when there is no name' do
      it 'should be invalid' do
        u = User.new
        expect(u.valid?).to eq(false)
      end
    end
  end
end