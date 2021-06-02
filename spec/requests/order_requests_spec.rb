describe 'Order Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @menu = create(:menu, account: @account)
    @customer = create(:customer, account: @account)
    @order = create(:order, account: @account, menu: @menu, customer: @customer)
  end

  def order_response(order, updates = {})
    base = {
      id: order.id,
      order_items: order.order_items,
      transactions: order.transactions,
      total: order.total,
      subtotal: order.subtotal,
      tax: order.tax,
      tip: order.tip,
      data: order.data,
      customer_id: order.customer&.id,
      menu_id: order.menu&.id,
      menu_name: order.menu_name,
      note: order.note,
      seen_at: order.seen_at,
      delivered_at: order.delivered_at,
      created_at: order.created_at,
      updated_at: order.updated_at
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end

  describe 'GET /orders' do
    it 'should return an array of Orders' do
      get '/orders.json', headers: test_api_headers
      response.body.should == [
        order_response(@order)
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

    describe 'Querying' do
      describe 'created_after' do
        it 'should return orders created_after the provided datetime' do
          new_order = create(:order, account: @account)
          @order.update(created_at: Time.parse('2020-12-31'))

          get URI.encode("/orders.json?q[created_after]=2021-01-01"), headers: test_api_headers

          response_data = JSON.parse(response.body)
          response_data.count.should == 1
          response_data.first['id'].should == new_order.id
        end
      end # created_after

      describe 'created_before' do
        it 'should return orders created_before the provided datetime' do
          new_order = create(:order, account: @account)
          @order.update(created_at: Time.parse('2020-12-30'))

          get URI.encode("/orders.json?q[created_before]=2021-01-01"), headers: test_api_headers

          response_data = JSON.parse(response.body)
          response_data.count.should == 1
          response_data.first['id'].should == @order.id
        end
      end # created_before

      describe 'created_on' do
        it 'should return orders created_on the provided date' do
          date = Date.parse('2021-01-01')
          new_order = create(:order, account: @account)
          new_order.update(created_at: date + 1.day)
          old_order = create(:order, account: @account)
          old_order.update(created_at: date - 1.day)
          @order.update(created_at: date)

          get URI.encode("/orders.json?q[created_on]=2021-01-01"), headers: test_api_headers

          response_data = JSON.parse(response.body)
          response_data.count.should == 1
          response_data.first['id'].should == @order.id
        end
      end # created_on
    end # Querying

    describe 'Paginating' do
      it 'should return the number of records specified by the "per_page" param' do
        2.times{ create(:order, account:@account) }

        get URI.encode("/orders.json?page=1&per_page=2"), headers: test_api_headers
        JSON.parse(response.body).count.should == 2

        get URI.encode("/orders.json?page=2&per_page=2"), headers: test_api_headers
        JSON.parse(response.body).count.should == 1
      end
    end # Paginating
  end # Index

  describe 'GET /orders/:id' do
    it 'should return Order data' do
      @order.update(
        data: {hello: 'world'}
      )

      get "/orders/#{@order.id}.json", headers: test_api_headers

      response.body.should == order_response(@order, data: {hello: 'world'}).to_json
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
      @order.update(tax: 11)
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['tax'].should == 11
    end

    it 'should return subtotal' do
      @order.order_items << create(:order_item, product: create(:product, price: 10))
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['subtotal'].should == 10
    end

    it 'should return total' do
      @order.update(tax: 10, tip: 10)
      @order.order_items << create(:order_item, product: create(:product, price: 10))
      get "/orders/#{@order.id}.json", headers: test_api_headers
      JSON.parse(response.body)['total'].should == 30
    end
  end # Show

  describe 'POST /orders' do
    before do
      @note = Faker::Lorem.paragraph
      @create_params = {order: attributes_for(:order).merge({note: @note})}
    end

    it 'should create a Order' do
      expect{ post '/orders.json', params: @create_params, headers: test_api_headers }
            .to change{ Order.count }.by(1)
    end

    it 'should return Order data' do
      post '/orders.json', params: @create_params, headers: test_api_headers
      created_order = Order.last
      response.body.should == order_response(created_order).to_json
    end

    it 'should save :tip' do
      post '/orders.json', params: {order: {tip: 2213}}, headers: test_api_headers
      Order.last.tip.should == 2213
    end

    it 'should save :tax' do
      post '/orders.json', params: {order: {tax: 42}}, headers: test_api_headers
      Order.last.tax.should == 42
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

    it 'should start Notification Job IF notify is passed as a param' do
      allow(NewOrderNotificationJob).to receive(:perform_async)
      post '/orders.json', params: {order: {tip: 10}, notify: true}, headers: test_api_headers
      expect(NewOrderNotificationJob)
            .to have_received(:perform_async)
            .with(Order.order(created_at: :desc).first.id)
    end

    it 'should NOT start Notification Job IF notify is NOT passed as a param' do
      allow(NewOrderNotificationJob).to receive(:perform_async)
      post '/orders.json', params: {order: {tip: 10}}, headers: test_api_headers
      expect(NewOrderNotificationJob)
            .not_to have_received(:perform_async)
            .with(Order.order(created_at: :desc).first.id)
    end

    it 'should NOT start Notification Job IF notify param is false' do
      allow(NewOrderNotificationJob).to receive(:perform_async)
      post '/orders.json', params: {order: {tip: 10}, notify: false}, headers: test_api_headers
      expect(NewOrderNotificationJob)
            .not_to have_received(:perform_async)
            .with(Order.order(created_at: :desc).first.id)
    end

    describe 'see' do
      before do
        @time = Time.now
        allow(Time).to receive(:now).and_return(@time)
      end

      specify 'if see=true is passed as param, update @order seen_at to Now' do
        post '/orders.json', params: {order: {see: true}}, headers: test_api_headers
        Order.last.seen_at.strftime("%FT%T").should == @time.strftime("%FT%T")
      end
    end

    describe 'OrderItems' do
      before do
        @product = create(:product)
        @order_item_params = {product_id: @product.id, amount: @product.price}
        @create_params[:order][:order_items] = [@order_item_params]
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

      it 'should return Transaction data' do
        post '/orders.json', params: @create_params, headers: test_api_headers

        order = Order.last
        order_item = order.order_items.last

        response.body.should == order_response(
          order,
          order_items: [
            {
              id: order_item.id,
              amount: order_item.amount,
              note: nil,
              data: {},
              order_id: order.id,
              product_id: @product.id,
              product_name: @product.name,
              group_id: nil,
              group_name: nil,
              created_at: order_item.created_at,
              updated_at: order_item.updated_at
            }
          ]
        ).to_json
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
    end # :order_items

    describe ':transactions' do
      before do
        @product = create(:product)

        @order_item_params = {product_id: @product.id, amount: @product.price}
        @create_params[:order][:order_items] = [@order_item_params]

        @transaction_params = attributes_for(:charge, amount: nil)
        @create_params[:order][:transactions] = [@transaction_params]
      end

      it 'should return Transaction data' do
        post '/orders.json', params: @create_params, headers: test_api_headers

        order = Order.last
        transaction = order.transactions.last
        order_item = order.order_items.last

        response.body.should == order_response(
          order,
          order_items: [
            {
              id: order_item.id,
              amount: order_item.amount,
              note: nil,
              data: {},
              order_id: order.id,
              product_id: @product.id,
              product_name: @product.name,
              group_id: nil,
              group_name: nil,
              created_at: order_item.created_at,
              updated_at: order_item.updated_at
            }
          ],
          transactions: [
            {
              id: transaction.id,
              amount: transaction.amount,
              transaction_type: 'charge',
              order_id: order.id,
              stripe_id: nil,
              created_at: transaction.created_at,
              updated_at: transaction.updated_at
            }
          ]
        ).to_json
      end
    end # Transactions
  end # Create

  # describe 'PUT /orders/:id' do
  #   before do
  #     @note = Faker::Lorem.paragraph
  #     @update_params = {
  #       order: {
  #         note: @note
  #       }
  #     }
  #   end
  #
  #   it 'should update @order' do
  #     expect{
  #       put "/orders/#{@order.id}.json",
  #           params: @update_params,
  #           headers: test_api_headers
  #      }.to change{ @order.reload.note }
  #       .to(@update_params[:order][:note])
  #   end
  #
  #   it  'should return Order data' do
  #     put "/orders/#{@order.id}.json",
  #         params: @update_params,
  #         headers: test_api_headers
  #
  #     response.body.should == order_response(@order.reload).to_json
  #   end
  #
  #   it 'should return code ' do
  #     put "/orders/#{@order.id}.json",
  #         params: @update_params,
  #         headers: test_api_headers
  #     response.status.should == 200
  #   end
  #
  #   specify 'Only Orders of this Account may be updated' do
  #     new_account = create(:account)
  #     new_order = create(:order, account: new_account)
  #
  #     put "/orders/#{new_order.id}.json",
  #         params: @update_params,
  #         headers: test_api_headers
  #     response.body.should == {
  #       error: I18n.t('errors.no_auth.resource', resource_type: 'Order')
  #     }.to_json
  #
  #     response.status.should == 401
  #   end
  # end # Update

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
