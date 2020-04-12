class PaymentProcessor
  def fund_order(order)
       4
  end

  def refund_order(order, amount)
  end

  private

  def client
    @client ||= StripeClient.new
  end
end
