# frozen_string_literal: true

# Modelo para representar los items que compra el usuario
class PurchasedItem < ActiveRecord::Base
  has_many :items
  has_many :users
end
