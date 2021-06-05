describe 'Transaction Requests', type: :request, api: true do
  before do
    @account = create(:account)
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
