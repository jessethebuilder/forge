class Account < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :credentials, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
