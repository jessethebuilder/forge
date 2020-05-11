describe 'OrderItem (or Item) Requests', type: :request, api: true do
  # Items via the API is an association on Order called OrderItems.
  # Here, and throughout the app, Items and OrderItems are more or less interchaneable.
  # The justification is "Item" is too vague for a Rails model (because there may be)
  # other types of items, such as LineItems someday. But, as we are generating,
  # menus, Items in the wild, is more obvious, and less obnoxious than an :order_items
  # param on the API.
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @order = create(:order, account: @account, menu: @menu, customer: @customer)
    @product = create(:product)
    @item = create(:order_item, order: @order, product: @product)
  end

  context 'Via an Order' do
    specify 'Order should have Items' do
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body, object_class: OpenStruct)['items'][0]
      item.amount.should == @product.price
      item.product_id.should == @product.to_param
      item.product_name.should == @product.name
    end

    it 'should return multiple items' do
      create(:order_item, order: @order)
      get "/orders/#{@order.to_param}", headers: test_api_headers
      JSON.parse(response.body)['items'].count.should == 2
    end

    it 'should provide Menu info' do
      menu = create(:menu, account: @account)
      menu.products << @product
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body)['items'][0]
      item['menu_name'] = menu.name
      item['menu_id'] = menu.id
    end

    it 'should provide Group info' do
      group = create(:group, account: @account)
      group.products << @product
      get "/orders/#{@order.to_param}", headers: test_api_headers
      item = JSON.parse(response.body)['items'][0]
      item['group_name'] = group.name
      item['group_id'] = group.id
    end
  end # via Order

  context 'Direct CRUD' do
    # Not implemented. Potentionally, at least deleting a single OrderItem would,
    # be sensible. In the checkout app require an order be complete, and Items
    # cannot be changed or removed after successful submission.
  end
end
