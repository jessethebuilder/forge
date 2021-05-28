class Order < ApplicationRecord
  belongs_to :account
  belongs_to :customer, optional: true
  belongs_to :menu, optional: true

  has_many :order_items, dependent: :destroy #spec
  accepts_nested_attributes_for :order_items

  has_many :transactions

  def total
    subtotal + tip + tax
  end

  def subtotal
    order_items.map(&:amount).sum.to_f
  end

  def refund_total
    transactions.refunds.map(&:amount).sum
  end

  def funded?
    !self.funded_at.nil?
  end
  
  def seen?
    !self.seen_at.nil?
  end

  def menu_name
    menu&.name
  end
end
