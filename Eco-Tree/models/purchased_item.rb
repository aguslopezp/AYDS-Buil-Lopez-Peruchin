class PurchasedItem < ActiveRecord::Base
  has_many :items
  has_many :users
end