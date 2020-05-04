class Order < ApplicationRecord
  belongs_to :account
  belongs_to :customer, optional: true
  belongs_to :menu, optional: true

  has_many :order_items, dependent: :destroy #spec
  accepts_nested_attributes_for :order_items

  has_many :transactions

  def charge
    Stripe::Charge.create({
      amount: (self.total * 100).to_i,
      # https://stripe.com/docs/api/charges/create
    })
  end

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

  scope :active, -> { where(active: true) }

  after_commit :send_new_order_notifications, on: :create

  private

  def send_new_order_notifications
    NewOrderNotificationJob.perform_async(self.id)
  end
end
