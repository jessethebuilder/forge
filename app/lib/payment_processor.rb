class PaymentProcessor
  def charge(order)
    # Set Funded_at if this comes back true.
  end

  def refund_order(order, amount)
    # Set reFunded_at if this comes back true.

  end

  private

  def client
    @client ||= StripeClient.new
  end
end
