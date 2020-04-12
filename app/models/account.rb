class Account < ApplicationRecord
  has_many :menus
  has_many :products
  has_many :groups
  has_many :orders
  has_many :customers
end
