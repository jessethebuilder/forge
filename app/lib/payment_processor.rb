class PaymentProcessor
  def charge(order)
    
  end

  def refund_order(order, amount)
  end

  private

  def client
    @client ||= StripeClient.new
  end
end
