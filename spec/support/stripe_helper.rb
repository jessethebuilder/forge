module StripeHelper
  def stub_stripe_client
    allow_any_instance_of(StripeClient)
        .to receive(:create_charge)
        .and_return(double(id: 'charge_stripe_id'))
    allow_any_instance_of(StripeClient)
        .to receive(:create_refund)
        .and_return(double(id: 'refund_stripe_id'))
    allow_any_instance_of(StripeClient)
        .to receive(:create_customer)
        .and_return(double(id: 'customer_stripe_id'))
  end
end
