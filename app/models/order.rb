class Order < ApplicationRecord
  belongs_to :account
  belongs_to :customer, optional: true
  belongs_to :menu, optional: true

  has_many :order_items, dependent: :destroy #spec
  accepts_nested_attributes_for :order_items

  has_many :transactions
  accepts_nested_attributes_for :transactions

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
