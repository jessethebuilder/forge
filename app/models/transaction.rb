class Transaction < ApplicationRecord # Transaction should be an interface, with inheritors like StripeTransaction
  attr_accessor :card_number, :card_expiration, :card_ccv, # TODO pull this line
                :stripe_token

  belongs_to :order

  validates :amount, presence: true, numericality: true

  validate :validate_transaction

  delegate :account, to: :order
  delegate :customer, to: :order

  def charge! # TODO spec
    charge_stripe!
  end

  def refund!
    refund_stripe!
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

  before_validation :set_full_amount_if_first_transaction
  before_create :execute!

  scope :refunds, -> { where('amount < 0') }
  scope :charges, -> { where('amount > 0') }

  private

  def execute! # spec
    begin
      self.stripe_id = send("#{transaction_type}!")
    rescue Stripe::InvalidRequestError => invalid_request
      self.errors.add(self.transaction_type, invalid_request.message)
    end
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

  def charge_stripe!
    set_stripe_customer! if customer.present?

    stripe_client.create_charge(
      stripe_token,
      self.amount,
      customer: customer&.stripe_id,
      description: "Forge Transaction: #{self.id}"
    )
  end

  def set_stripe_customer!
    return customer.stripe_id if customer.stripe_id.present?

    customer_id = stripe_client.create_customer(
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      source: self.stripe_token
    ).id

    customer.update(stripe_id: customer_id)
  end

  def refund_stripe! # spec
    stripe_client.create_refund(amount, order.charge)
  end

  def stripe_client
    @stripe_client ||= StripeClient.new(account.stripe_secret)
  end
end
