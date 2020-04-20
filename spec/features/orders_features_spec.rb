describe 'Group Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
      @menu = create(:menu, account: @account)
      @group = create(:group, menu: @menu, account: @account)
      @product = create(:product, group: @group, menu: @menu, account: @account)
      @order_item = build(:order_item, product: @product)
      @order = create(:order, account: @account, order_items: [@order_item])
    end

    describe 'INDEX /orders' do
      
    end # INDEX
  end # /w login

  context 'Without Login' do
    it 'should not redirect all to login' do
      visit '/orders'
      page.current_path.should == '/users/sign_in'

      visit '/orders/new'
      page.current_path.should == '/users/sign_in'

      visit '/orders/edit'
      page.current_path.should == '/users/sign_in'

      visit '/orders/order_id'
      page.current_path.should == '/users/sign_in'
    end
  end # Without Login
end
