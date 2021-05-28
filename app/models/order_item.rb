class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :amount, presence: true, numericality: {greater_than_or_equal_to: 0}

  validate :product_is_active, on: :create
  validate :product_price_is_amount, on: :create

  def product_name
    product.name
  end

  def group
    product&.group
  end

  def group_name
    group&.name
  end

  private

  def product_is_active
    # should also validate that menu is and group is active. !!!!!!!!!!!!!!!!!!
    # maybe change the definition of product.active? to include inactive goups and menuss.
    return unless product
    errors.add(:product, "#{product.id} is no longer available") unless product.active?
  end

  def product_price_is_amount
    return unless product
    # An OrderItem :amount must be the same as the associated Product's :price to
    # prevent confusion between states.
    errors.add(:product, "#{product.id} price has changed") unless product.price == amount
  end
end
