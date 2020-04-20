class Order < ApplicationRecord
  belongs_to :account
  belongs_to :customer, optional: true
  belongs_to :menu, optional: true

  has_many :order_items, dependent: :destroy #spec
  accepts_nested_attributes_for :order_items

  has_many :transactions

  def total
    order_items.map(&:amount).sum
  end

  def refund_total
    transactions.refunds.map(&:amount).sum
  end

  def complete?
    transactions.first.try(:amount) == self.total ? true : false
  end

  scope :active, -> { where(active: true) }

  after_commit :broadcast_to_account, on: :create # spec!!!!!!!!!!!!!!!

  private

  def broadcast_to_account
    ActionCable.server.broadcast(
      "orders_for_account_#{account.id}",
      {
        action: 'new_order',
        data: {
          order_id: self.id
        }
      }
    )
  end
end
