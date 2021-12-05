class Order < ApplicationRecord
  belongs_to :account
  belongs_to :menu, optional: true

  belongs_to :customer, optional: true # TODO request spec for customer data on order_response
  accepts_nested_attributes_for :customer

  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  has_many :transactions, dependent: :destroy
  accepts_nested_attributes_for :transactions

  has_many :notifications

  def charge
    transactions.charges.first
  end

  def refunds
    transactions.refunds
  end

  def total
    subtotal + tip + tax
  end

  def subtotal
    order_items.map(&:amount).sum
  end

  def refund_total
    transactions.refunds.map(&:amount).sum
  end

  def funded?
    transactions.charges.count == 1
  end

  def seen?
    !seen_at.nil?
  end

  def see
    self.seen_at = Time.now
  end

  def unsee
    self.seen_at = nil
  end

  def see=(boolean)
    boolean ? see : unsee
  end

  def menu_name
    menu&.name
  end
end
