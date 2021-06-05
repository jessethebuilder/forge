describe 'OrderItem Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @order = create(:order, account: @account, menu: @menu, customer: @customer)
    @product = create(:product)
    @item = create(:order_item, order: @order, product: @product)
  end

  # describe

  context 'Via an Order' do
    specify 'Order should have Items' do
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body, object_class: OpenStruct)['order_items'][0]
      item.amount.should == @product.price
      item.product_id.should == @product.id
      item.product_name.should == @product.name
    end

    it 'should return multiple items' do
      create(:order_item, order: @order)
      get "/orders/#{@order.to_param}", headers: test_api_headers
      JSON.parse(response.body)['order_items'].count.should == 2
    end

    it 'should provide Menu info' do
      menu = create(:menu, account: @account)
      menu.products << @product
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body)['order_items'][0]
      item['menu_name'] = menu.name
      item['menu_id'] = menu.id
    end

    it 'should provide Group info' do
      group = create(:group, account: @account)
      group.products << @product
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body)['order_items'][0]
      item['group_name'] = group.name
      item['group_id'] = group.id
    end
  end # via an Order
end
