class Group < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true

  has_many :products
end
