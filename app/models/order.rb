class Order < ApplicationRecord
  belongs_to :account
  belongs_to :customer, optional: true
  belongs_to :menu, optional: true

  has_many :order_items
  accepts_nested_attributes_for :order_items

  has_many :transactions

  def total
    order_items.map(&:amount).sum
  end

  def refund_total
    transactions.refunds.map(&:amount).sum
  end
end
