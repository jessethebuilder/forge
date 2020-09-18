describe GroupsController, type: :controller do
  before do
    setup_controller_spec
    @group = create(:group, account: @account)
    @product = create(:product, group: @group, account: @account)
  end

  describe 'Authorized User' do
    before do
      http_login
    end

    describe 'INDEX /groups' do
      describe '?scope' do
        before do
          @inactive_group = create(:group, account: @account, active: false)
        end

        it 'should assign only active Menus if nothing is passed' do
          get :index, format: :json
          assigns[:groups].should == [@group]
        end

        it 'should assign all if passed' do
          get :index, params: {scope: 'all'}, format: :json
          assigns[:groups].should == [@group, @inactive_group]
        end

        it 'should return active if a non-scope is passed' do
          get :index, params: {scope: 'destruction_script!'}, format: :json
          assigns[:groups].should == [@group]
        end
      end
    end
  end # Authorized User
end
