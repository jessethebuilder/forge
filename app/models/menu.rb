class Menu < ApplicationRecord
  include StatusScoped

  belongs_to :account

  has_many :orders
  has_many :groups
  has_many :products

  validates :name, presence: true

  private
end
