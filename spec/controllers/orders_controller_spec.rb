describe OrdersController, type: :controller do
  before do
    setup_controller_spec
    @order = create(:order, account: @account)
  end

  describe 'Authorized User' do
    before do
      http_login
    end

    describe 'INDEX /orders' do
      describe '?scope' do
        before do
          @inactive_order = create(:order, account: @account, active: false)
        end

        it 'should assign only active Menus if nothing is passed' do
          get :index, format: :json
          assigns[:orders].should == [@order]
        end

        it 'should assign all if passed' do
          get :index, params: {scope: 'all'}, format: :json
          assigns[:orders].should == [@inactive_order, @order]
        end

        it 'should return active if a non-scope is passed' do
          get :index, params: {scope: 'destruction_script!'}, format: :json
          assigns[:orders].should == [@order]
        end
      end
    end # INDEX

    describe 'CREATE /orders' do
    end # CREATE
  end
end
