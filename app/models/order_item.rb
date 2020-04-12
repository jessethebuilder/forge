class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :amount, presence: true, numericality: {greater_than_or_equal_to: 0}

  # A created OrderItem must have a product that is acive and the same price as amount.
  validate :product_is_available, on: :create
  validate :product_price_is_amount, on: :create

  private

  def product_is_available
    return unless product
    errors.add(:product, "#{product.id} is no longer available") unless product.active?
  end

  def product_price_is_amount
    return unless product
    errors.add(:product, "#{product.id} price has changed") unless product.price == amount
  end
end
