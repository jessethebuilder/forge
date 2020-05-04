describe 'Order Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @menu = create(:menu, account: @account)
    @customer = create(:customer, account: @account)
    @order = create(:order, account: @account, menu: @menu, customer: @customer)
  end

  describe 'GET /orders' do
    it 'should return an array of Orders' do
      get '/orders.json', headers: test_api_headers
      response.body.should == [
        {
          id: @order.id,
          items: [],
          total: 0.0,
          subtotal: 0.0,
          tax: 0.0,
          tip: 0.0,
          data: {},
          reference: nil,
          created_at: @order.created_at,
          updated_at: @order.updated_at,
          customer_id: @customer.id,
          menu_id: @menu.id,
        }
      ].to_json
    end

    it 'it SHOULD NOT return other accounts Orders' do
      new_account = create(:account)
      new_order = create(:order, account: new_account)
      get '/orders.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @order.id
    end
  end # Index

  describe 'GET /orders/:id' do
    it 'should return Order data' do
      @order.update(
        data: {hello: 'world'},
        reference: 'reference'
      )

      get "/orders/#{@order.id}.json", headers: test_api_headers

      response.body.should == {
        id: @order.id,
        items: [],
        total: 0.0,
        subtotal: 0.0,
        tax: 0.0,
        tip: 0.0,
        data: {hello: 'world'},
        reference: 'reference',
        created_at: @order.created_at,
        updated_at: @order.updated_at,
        customer_id: @customer.id,
        menu_id: @menu.id,
      }.to_json
    end

    specify 'Only Orders of this Account may be fetched' do
      new_account = create(:account)
      new_order = create(:order, account: new_account)

      get "/orders/#{new_order.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Order')
      }.to_json

      response.status.should == 401
    end

    it 'should return :tip' do
      @order.update(tip: 10.0)
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['tip'].should == 10.0
    end

    it 'should return :tax' do
      @order.update(tax: 1.1)
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['tax'].should == 1.1
    end

    it 'should return subtotal' do
      @order.order_items << create(:order_item, product: create(:product, price: 10.0))
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['subtotal'].should == 10.0
    end

    it 'should return total' do
      @order.update(tax: 10.0, tip: 10.0)
      @order.order_items << create(:order_item, product: create(:product, price: 10.0))
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['total'].should == 30.0
    end
  end # Show

  describe 'POST /orders' do
    before do
      @create_params = {
        order: attributes_for(:order).merge({reference: 'reference'})}
    end

    it 'should create a Order' do
      expect{ post '/orders.json', params: @create_params, headers: test_api_headers }
            .to change{ Order.count }.by(1)
    end

    it 'should return Order data' do
      post '/orders.json', params: @create_params, headers: test_api_headers
      created_order = Order.last

      response.body.should == {
        id: created_order.id,
        items: [],
        total: 0.0,
        subtotal: 0.0,
        tax: 0.0,
        tip: 0.0,
        data: {},
        reference: 'reference',
        created_at: created_order.created_at,
        updated_at: created_order.updated_at,
        customer_id: nil,
        menu_id: nil,
      }.to_json
    end

    it 'should save :tip' do
      post '/orders.json', params: {order: {tip: 22.13}}, headers: test_api_headers
      Order.last.tip.should == 22.13
    end

    it 'should save :tax' do
      post '/orders.json', params: {order: {tax: 0.42}}, headers: test_api_headers
      Order.last.tax.should == 0.42
    end

    it 'should accept menu_id as a param' do
      menu = create(:menu)
      post '/orders.json', params: {order: {menu_id: menu.id}}, headers: test_api_headers
      Order.last.menu.should == menu
    end

    it 'should accept customer_id as a param' do
      customer = create(:customer)
      post '/orders.json', params: {order: {customer_id: customer.id}}, headers: test_api_headers
      Order.last.customer.should == customer
    end

    it 'should save :data' do
      @create_params[:order][:data] = {hello: 'world'}.to_json
      post '/orders.json', params: @create_params, headers: test_api_headers
      Order.last.data.should == {hello: 'world'}.to_json
    end

    it 'should set @order.account to @account' do
      post '/orders.json', params: @create_params, headers: test_api_headers
      Order.last.account.should == @account
    end

    it 'should call PaymentProcessor' do
      expect_any_instance_of(PaymentProcessor).to receive(:fund_order)
      post '/orders.json', params: @create_params, headers: test_api_headers
    end

    describe 'OrderItems' do
      before do
        @product = create(:product)
        @order_item_params = {product_id: @product.id, amount: @product.price}
        @create_params[:order][:items] = [@order_item_params]
        # @create_params[:order][:order_items_attributes] = [@order_item_params]
      end

      it 'should create a new OrderItem' do
        expect{ post '/orders.json', params: @create_params, headers: test_api_headers }
              .to change{ OrderItem.count }.by(1)
      end

      specify 'new OrderItem should be associated with new Order' do
        post '/orders.json', params: @create_params, headers: test_api_headers
        OrderItem.last.order.should == Order.last
      end

      specify 'new OrderItem should be associated with @product' do
        post '/orders.json', params: @create_params, headers: test_api_headers
        OrderItem.last.product.should == @product
      end

      describe 'Commerce Errors' do
        describe 'Deactivated Products' do
          before do
            @product.update(active: false)
            post '/orders.json', params: @create_params, headers: test_api_headers
          end

          specify 'if Product is no longer active, return error' do
            response.body.should == {
              'order_items.product' => ["#{@product.id} is no longer available"]
            }.to_json
          end

          it 'should raise an error status' do
            response.status.should == 422
          end
        end

        describe 'Products with price change' do
          before do
            @product.update(price: @product.price + 1)
            post '/orders.json', params: @create_params, headers: test_api_headers
          end

          specify 'if Product price changes, return error' do
            response.body.should == {
              'order_items.product' => ["#{@product.id} price has changed"]
            }.to_json
          end

          it 'should raise an error status' do
            response.status.should == 422
          end
        end
      end # Commerce Errors
    end
  end # Create

  describe 'PUT /orders/:id' do
    before do

      @update_params = {
        order: {
          reference: @order.reference.to_s + " the Third Reference!!"
        }
      }
    end

    it 'should update @order' do
      expect{
        put "/orders/#{@order.id}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @order.reload.reference }
        .to(@update_params[:order][:reference])
    end

    it  'should return Order data' do
      put "/orders/#{@order.id}.json",
          params: @update_params,
          headers: test_api_headers

      response.body.should == {
        id: @order.reload.id,
        items: [],
        total: 0.0,
        subtotal: 0.0,
        tax: 0.0,
        tip: 0.0,
        data: {},
        reference: @update_params[:order][:reference],
        created_at: @order.created_at,
        updated_at: @order.updated_at,
        customer_id: @customer.id,
        menu_id: @menu.id,
      }.to_json
    end

    it 'should return code ' do
      put "/orders/#{@order.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Orders of this Account may be updated' do
      new_account = create(:account)
      new_order = create(:order, account: new_account)

      put "/orders/#{new_order.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Order')
      }.to_json

      response.status.should == 401
    end
  end # Update

  describe 'DELETE /orders/:id' do
    it 'should destroy a Order' do
      expect{ delete "/orders/#{@order.id}.json", headers: test_api_headers }
            .to change{ Order.count }.by(-1)
      Order.find_by(id: @order.id).should == nil
    end

    it 'should return a code' do
      delete "/orders/#{@order.id}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Orders of this Account may be destroyed' do
      new_account = create(:account)
      new_order = create(:order, account: new_account)

      delete "/orders/#{new_order.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Order')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
