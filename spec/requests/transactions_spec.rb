describe 'Transaction Requests', type: :request, api: true do
  before do
    stub_stripe_client
    @account = create(:account, :with_stripe_credentials)
    @credential = create(:credential, account: @account)

    @order = create(:order, :with_items, account: @account)
  end

  describe 'Creating a Transaction' do
    before do
      @transaction_params = {transaction: {}}
    end

    describe 'Creating a Charge' do
      before do
        @transaction_params[:transaction] = {
          stripe_token: 'sample_token',
          amount: @order.total
        }
      end

      def create_charge
        post(
          "/orders/#{@order.to_param}/transactions.json",
          params: @transaction_params,
          headers: test_api_headers
        )

        return Transaction.last
      end

      it 'should create a Transaction' do
        expect{ create_charge }.to change{ Transaction.count }.by(1)
      end

      it 'should return a Transaction Object' do
        created_transaction = create_charge
        response.body.should == transaction_response(created_transaction).to_json
      end

      it 'should call StripeClient to create a Charge' do
        expect_any_instance_of(StripeClient).to receive(:create_charge)
        create_charge
      end

      it 'should NOT call StripeClient to create a Customer' do
        expect_any_instance_of(StripeClient).not_to receive(:create_customer)
        create_charge
      end

      describe 'With a Customer' do
        before do
          @name = Faker::Name.name
          @customer = create(:customer, account: @account, orders: [@order], name: @name)
        end

        it 'should call StripeClient to create a Customer' do
          expect_any_instance_of(StripeClient).to receive(:create_customer).with(
            name: @name, email: nil, phone: nil, source: 'sample_token'
          )

          create_charge
        end

        it 'should update Customer with stripe_id' do
          customer_id = Faker::Lorem.word
          allow_any_instance_of(StripeClient)
              .to receive(:create_customer)
              .and_return(double(id: customer_id))
          expect{ create_charge }.to change{ @customer.reload.stripe_id }
              .from(nil).to(customer_id)
        end

        it 'should NOT create a Stripe Customer if Custmer has a Stripe ID' do
          @customer.update(stripe_id: 'sample_stripe_id')
          expect_any_instance_of(StripeClient).not_to receive(:create_customer)
          create_charge
        end
      end
    end # Creating a Charge

    describe 'Creating a Refund' do
      before do
        create(:charge, order: @order)

        @transaction_params[:transaction] = {
          amount: -@order.total
        }
      end

      it 'should create a Transaction' do
        expect{
          post(
            "/orders/#{@order.to_param}/transactions.json",
            params: @transaction_params,
            headers: test_api_headers
          )
        }.to change{ Transaction.count }.by(1)
      end

      it 'should return a Transaction Object' do
        post(
          "/orders/#{@order.to_param}/transactions.json",
          params: @transaction_params,
          headers: test_api_headers
        )

        created_transaction = Transaction.last

        response.body.should == transaction_response(created_transaction).to_json
      end
    end # Creating a Refund
  end # Creating a Transaction
end
