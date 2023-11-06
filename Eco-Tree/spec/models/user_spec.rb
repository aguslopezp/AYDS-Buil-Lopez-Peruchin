# frozen_string_literal: true

require 'sinatra/activerecord'
require 'bcrypt'
require_relative '../../models/init.rb'
require_relative '../../methods'

describe 'User' do
  context 'validations' do
    it 'requires a username' do
      user = User.new(username: '', password: '123', email: 'test@example.com', birthdate: '1999-12-12', streak: 0)
      expect(user.valid?).to eq(false)
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'requires a password' do
      user = User.new(username: 'usertest', password: '', email: 'test@example.com', birthdate: '1999-12-12', streak: 0)
      expect(user.valid?).to eq(false)
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'requires a valid email format' do
      user = User.new(username: 'usertest', password: '123', email: 'invalid_email', birthdate: '1999-12-12', streak: 0)
      expect(user.valid?).to eq(false)
      expect(user.errors[:email]).to include('invalid email format')
    end

    it 'requires a minimum length for username and password' do
      user = User.new(username: 'ab', password: '123', email: 'test@example.com', birthdate: '1999-12-12', streak: 0)
      expect(user.valid?).to eq(false)
      expect(user.errors[:username]).to include('username must be at least 3 characters')
      expect(user.errors[:password]).to include('password must be at least 6 characters')
    end

    it 'requires a password with at least 6 characters' do
      user = User.new(username: 'usertest', password: 'abcde', email: 'test@example.com', birthdate: '1999-12-12')
      expect(user.valid?).to eq(false)
      expect(user.errors[:password]).to include('password must be at least 6 characters')
    end
  end

  context 'points and streak' do
    it 'when you win a point, only one point is gained' do
      user = User.new(username: 'usertest', password: 'abcde', email: 'test@example.com', birthdate: '1999-12-12', points: 5)
      user.sum_points
      expect(user.points).to eq(6)
    end

    it 'requires non-negative points' do
      user = User.new(username: 'usertest', password: '123', email: 'test@example.com', birthdate: '1999-12-12', points: -5, streak: 0)
      expect(user.valid?).to eq(false)
      expect(user.errors[:points]).to include('must be greater than or equal to 0')
    end

    it 'when the player answers well, add one to the streak' do
      user = User.new(username: 'usertest', password: 'abcde', email: 'test@example.com', birthdate: '1999-12-12', points: 5)
      user.sum_streak
      expect(user.streak).to eq(1)
    end

    it 'when the user gets three correct answers, an extra point is added to the total' do
      user = User.new(username: 'usertest', password: 'abcde', email: 'test@example.com', birthdate: '1999-12-12', points: 5)
      user.sum_streak
      user.sum_streak
      user.sum_streak
      user.add_streak_to_points(user.streak / 3)
      expect(user.streak).to eq(3)
      expect(user.points).to eq(6)
    end

    it 'when the user answers a question wrong, the streak returns to zero' do
      user = User.new(username: 'usertest', password: 'abcde', email: 'test@example.com', birthdate: '1999-12-12', points: 5, streak: 2)
      user.reset_streak
      expect(user.streak).to eq(0)
    end
  end

  context 'password hashing' do
    it 'when a user register, her password is hashed' do
      # hash the password
      password = '123456'
      hashed_password = hash_password(password)

      user = User.new(username: 'usertest', password: hashed_password, email: 'test@example.com', birthdate: '1999-12-12', points: 5)
      no_hash_pass = user.compare_password(user.password, password)
      expect(no_hash_pass).to eq(true)
    end

    it 'when a user login, her password is hashed' do
      # hash the password
      password = '123456'
      hashed_password = hash_password(password)

      user = User.new(username: 'usertest', password: hashed_password, email: 'test@example.com', birthdate: '1999-12-12', points: 5)
      no_hash_pass = (user.password == password)
      expect(no_hash_pass).to eq(false)
    end
  end
end
