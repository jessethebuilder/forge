describe ProductsController, type: :controller do
  before do
    setup_controller_spec
    @product = create(:product, account: @account)
  end

  describe 'INDEX /products' do
    describe '?scope' do
      before do
        @account.update(schema: 'product')
        @inactive_product = create(:product, account: @account, active: false)
      end

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
  end

  describe 'DELETE /products/:id' do
    it 'should delete a product' do
      expect{ delete :destroy, params: {id: @product.id} }
            .to change{ Product.count }.by(-1)
    end
  end # Destroy
end
