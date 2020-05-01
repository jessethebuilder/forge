describe ProductsController, type: :controller do
  before do
    setup_controller_spec
    @product = create(:product, account: @account)
    @inactive_product = create(:product, account: @account, active: false)
  end

  describe ':index' do
    describe '?scope' do
      it 'should assign only active Menus if nothing is passed' do
        get :index
        assigns[:products].should == [@product]
      end

      it 'should assign all if passed' do
        get :index, params: {scope: 'all'}
        assigns[:products].should == [@product, @inactive_product]
      end

      it 'should return active if a non-scope is passed' do
        get :index, params: {scope: 'destruction_script!'}
        assigns[:products].should == [@product]
      end
    end
  end # :index

  describe ':all_inactive' do
    it 'should return inactive products' do
      get :all_inactive
      assigns[:products].should == [@inactive_product]
    end

    it 'should return active Products in inactive Groups' do
      new_group = create(:group, account: @account, active: false)
      new_product = create(:product, account: @account, group: new_group)
      get :all_inactive
      assigns[:products].should == [@inactive_product, new_product]
    end

    it 'should return active Products in inactive Menus' do
      new_menu = create(:menu, account: @account, active: false)
      new_product = create(:product, account: @account, menu: new_menu)
      get :all_inactive
      assigns[:products].should == [@inactive_product, new_product]
    end
  end
end
