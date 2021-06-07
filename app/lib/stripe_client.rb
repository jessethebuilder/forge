# TODO spec

class StripeClient
  def initialize(secret_key, debug: false)
    @secret_key = secret_key
    @debug = debug
  end

  def self.test
    # --- keep ---
    client = self.new(ENV.fetch('STRIPE_SECRET'))
    customer = client.create_customer(email: "jeff_#{Time.now.to_i}@test.com", source: 'tok_visa')
    charge = client.create_charge(customer.default_source, 100, customer: customer)
    refund = client.create_refund(charge, 50)
    refund = client.create_refund(charge, 50)
    refund = client.create_refund(charge, 50)
  end

  def create_customer(name: nil, email: nil, phone: nil, source: nil)
    call_api do
      Stripe::Customer.create(
        {
          name: name,
          email: email,
          phone: phone,
          source: source
        },
        credentials
      )
    end
  end

  def create_charge(token, amount, customer: nil, description: nil)
    call_api do
      Stripe::Charge.create(
        {
          amount: amount,
          currency: 'usd',
          source: token,
          customer: customer,
          description: description
        },
        credentials
      )
    end
  end

  def create_refund(charge, amount)
    call_api do
      Stripe::Refund.create(
        {
          amount: amount,
          charge: charge
        },
        credentials
      )
    end
  end

  private

  def call_api
    response = yield

    byebug
  end

  def credentials
    {
      api_key: @secret_key
    }
  end
end
