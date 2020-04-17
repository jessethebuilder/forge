class Transaction < ApplicationRecord
  belongs_to :order

  validates :amount, presence: true, numericality: true

  scope :refunds, -> { where('amount < 0') }
  scope :charges, -> { where('amount >= 0') }

  validate :validate_transaction

  private

  def validate_transaction
    # There are 2 types of Transactions:
    # - Charges: which must be positive in the amount of the Order total.
    # - Refunds: which must be negative, and must be in an amount that is less
    #   than the total all all other negative transactions.
    return unless order
    amount < 0 ? validate_refund : validate_charge
  end

  def validate_refund
    validate_refund_is_not_first
    validate_refund_totals_are_no_less_than_order_total
  end

  def validate_refund_is_not_first
    # Refund cannot be the first Transaction added to Order.
    if order.transactions.empty?
      errors.add(:refund, 'cannot be the first Transaction on an Order')
    end
  end

  def validate_refund_totals_are_no_less_than_order_total
    if (order.refund_total + amount) < -order.total
      # Absolute value of Refund must be less than Order total.
      errors.add(:amount, 'cannot be less than Order total')
    end
  end

  def validate_charge
    validate_charge_is_first
    validate_amount_matches_order_total
  end

  def validate_charge_is_first
    # Only one Charge is allowed, and it must be the first Transaction
    unless order.transactions.empty?
      errors.add(:charge, 'must be the first Transaction on an Order')
    end
  end

  def validate_amount_matches_order_total
    # Charge must be the same amount as the Order total.
    errors.add(:amount, 'must equal Order total') unless amount == order.total
  end
end
