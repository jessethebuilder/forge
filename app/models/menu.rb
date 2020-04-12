class Menu < ApplicationRecord
  belongs_to :account

  has_many :orders
  has_many :groups
  has_many :products
end
