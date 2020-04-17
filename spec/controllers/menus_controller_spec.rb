describe MenusController, type: :controller do
  before do
    setup_controller_spec
    @menu = create(:menu, account: @account)
    @group = create(:group, menu: @menu, account: @account)
    @product = create(:product, group: @group, menu: @menu, account: @account)
  end
 
  describe 'INDEX /menus' do
    describe '?scope' do
      before do
        @inactive_menu = create(:menu, account: @account, active: false)
      end

      it 'should assign only active Menus if nothing is passed' do
        get :index
        assigns[:menus].should == [@menu]
      end

      it 'should assign all if passed' do
        get :index, params: {scope: 'all'}
        assigns[:menus].should == [@menu, @inactive_menu]
      end

      it 'should return active if a non-scope is passed' do
        get :index, params: {scope: 'destruction_script!'}
        assigns[:menus].should == [@menu]
      end
    end
  end

  describe 'DELETE /menus/:id' do
    it 'should delete a Menu' do
      expect{ delete :destroy, params: {id: @menu.id} }
            .to change{ Menu.count }.by(-1)
    end

    specify 'it should NOT delete Products in Menu' do
      expect{ delete :destroy, params: {id: @menu.id} }
            .not_to change{ Product.count }
    end

    specify 'it should NOT delete Groups in Menu' do
      expect{ delete :destroy, params: {id: @menu.id} }
            .not_to change{ Group.count }
    end

    it 'should delete products if destroy_products is passed along as a param' do
      expect{ delete :destroy, params: {id: @menu.id, destroy_products: true} }
            .to change{ Product.count }.by(-1)
    end

    it 'should delete Groups if destroy_groups is passed along as a param' do
      expect{ delete :destroy, params: {id: @menu.id, destroy_groups: true} }
            .to change{ Group.count }.by(-1)
    end
  end # Destroy
end
