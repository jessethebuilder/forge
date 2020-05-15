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

  def complete?
    transactions.first.try(:amount) == self.total ? true : false
  end

  def new_order_sms_body
    text = ["---- New Order ----"]
    text << "for #{menu.name}" if menu
    text << "Created: #{created_at}"
    text << "\n-- ITEMS --\n"
    order_items.each_with_index do |item, i|
      product = item.product
      group = product.group
      text << "Group: #{group.name}" unless group.blank?
      text << "Product: #{product.name}"
      text << "NOTE: #{item.note}" unless item.note.blank?
      text << "--------\n"
    end

    text.join("\n")
  end

  scope :active, -> { where(active: true) }
end
