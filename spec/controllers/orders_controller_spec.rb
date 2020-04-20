describe OrdersController, type: :controller do
  before do
    setup_controller_spec
    @order = create(:order, account: @account)
  end

  describe 'INDEX /orders' do
    describe '?scope' do
      before do
        @inactive_order = create(:order, account: @account, active: false)
      end

      it 'should assign only active Menus if nothing is passed' do
        get :index
        assigns[:orders].should == [@order]
      end

      it 'should assign all if passed' do
        get :index, params: {scope: 'all'}
        assigns[:orders].should == [@order, @inactive_order]
      end

      it 'should return active if a non-scope is passed' do
        get :index, params: {scope: 'destruction_script!'}
        assigns[:orders].should == [@order]
      end
    end
  end
end
