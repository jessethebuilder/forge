class Account < ApplicationRecord
  has_many :menus, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :customers, dependent: :destroy

  has_many :credentials, dependent: :destroy
  accepts_nested_attributes_for :credentials

  has_many :users, dependent: :destroy
  accepts_nested_attributes_for :users
end
