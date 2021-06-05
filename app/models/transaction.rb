class Transaction < ApplicationRecord
  attr_accessor :card_number, :card_expiration, :card_ccv, :stripe_token

  belongs_to :order

  validates :amount, presence: true, numericality: true

  scope :refunds, -> { where('amount < 0') }
  scope :charges, -> { where('amount > 0') }

  def charge!
  end

  def refund!

  end

  def charge?
    amount > 0
  end

  def refund?
    amount < 0
  end

  def transaction_type
    charge? ? 'charge' : 'refund'
  end

  validate :validate_transaction

  before_validation :set_full_amount_if_first_transaction
  # _validation :execute_transaction
  before_create :execute_transaction

  private

  def execute_transaction
    send("#{transaction_type}!")
  end

  def set_full_amount_if_first_transaction
    # To avoid API consumers from having to calculate a total.
    return if !amount.nil? || order.nil? || order.transactions.count > 0
    self.amount = order.total
  end

  def validate_transaction
    # There are 2 types of Transactions:
    # - Charges: which must be positive in the amount of the Order total.
    # - Refunds: which must be negative, and must be in an amount that is less
    #   than the total all all other negative transactions.
    return unless order && self.new_record?

    validate_amount

    charge? ? validate_charge : validate_refund
  end

  def validate_amount
    if amount.to_i.abs < 50
      errors.add(:amount, "#{self.transaction_type} must be 50 cents or more")
    end
  end

  def validate_refund
    validate_refund_is_not_first
    validate_refund_totals_are_no_less_than_order_total
  end

  def validate_refund_is_not_first
    # Refund cannot be the first Transaction added to Order.
    if order.transactions.empty?
      errors.add(:amount, 'a refund cannot be the first Transaction on an Order')
    end
  end

  def validate_refund_totals_are_no_less_than_order_total
    if (order.refund_total + amount) < -order.total
      # Absolute value of Refund must be less than Order total.
      errors.add(:amount, 'cannot be less than Order total')
    end
  end

  def validate_charge
    validate_payment_method
    validate_charge_is_first
    validate_amount_matches_order_total
  end

  def validate_payment_method
    return unless self.new_record?

    if (card_number.nil? && card_expiration.nil? && card_ccv.nil?) && stripe_token.nil?  
      errors.add(:charge, 'requires a valid payment method')
    end
  end

  def validate_charge_is_first
    # Only one Charge is allowed, and it must be the first Transaction
    return if order.transactions.count == 0
    errors.add(:charge, 'must be the first Transaction on an Order')
  end

  def validate_amount_matches_order_total
    # Charge must be the same amount as the Order total.
    errors.add(:amount, 'must equal Order total') unless amount == order.total
  end
end
