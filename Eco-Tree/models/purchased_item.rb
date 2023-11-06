# frozen_string_literal: true

class PurchasedItem < ActiveRecord::Base
  has_many :items
  has_many :users
end
