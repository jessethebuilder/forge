describe GroupsController, type: :controller do
  before do
    setup_controller_spec
    @group = create(:group, account: @account)
    @product = create(:product, group: @group, account: @account)
  end

  describe 'INDEX /groups' do
    describe '?scope' do
      before do
        @account.update(schema: 'group')
        @inactive_group = create(:group, account: @account, active: false)
      end

      it 'should assign only active Menus if nothing is passed' do
        get :index
        assigns[:groups].should == [@group]
      end

      it 'should assign all if passed' do
        get :index, params: {scope: 'all'}
        assigns[:groups].should == [@group, @inactive_group]
      end

      it 'should return active if a non-scope is passed' do
        get :index, params: {scope: 'destruction_script!'}
        assigns[:groups].should == [@group]
      end
    end
  end

  describe 'DELETE /groups/:id' do
    it 'should delete a group' do
      expect{ delete :destroy, params: {id: @group.id} }
            .to change{ Group.count }.by(-1)
    end

    specify 'it should NOT delete Products in Group' do
      expect{ delete :destroy, params: {id: @group.id} }
            .not_to change{ Product.count }
    end

    it 'should delete products if destroy_products is passed along as a param' do
      expect{ delete :destroy, params: {id: @group.id, destroy_products: true} }
            .to change{ Product.count }.by(-1)
    end
  end # Destroy
end
