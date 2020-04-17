class Product < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true
  belongs_to :group, optional: true

  has_many :order_items

  validates :price, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
