describe 'Product Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
      @menu = create(:menu, account: @account)
      @group = create(:group, menu: @menu, account: @account)
    end

    describe 'Creating a Product' do
      it 'should create a product with all attributes' do
        product_min

        fill_in 'Description', with: 'description'
        uncheck 'Active'

        expect{ click_button 'Create Product' }
              .to change{ Product.count }.by(1)

        product = Product.last
        product.name.should == 'name'
        product.description.should == 'description'
        product.price.should == 13.22
        product.active.should == false # defaults to true
      end

      it 'should redirect to /products' do
        product_min
        click_button 'Create Product'
        page.current_path.should == '/products'
      end

      describe 'Creating a Product from Group' do
        before do
          visit "/groups/#{@group.id}"
          click_link 'New Product'

          fill_in 'Price', with: 13.22
          fill_in 'Name', with: 'name'
        end

        it 'should set :group if group_id is passed as param' do
          click_button 'Create Product'
          Product.last.group.should == @group
        end

        it 'should redirect_to @group' do
          click_button 'Create Product'
          page.current_path.should == "/groups/#{@group.id}"
        end

        it 'should save group_id, if first form submission is unsuccessful' do
          fill_in 'Name', with: ''
          click_button 'Create Product'
          # form fails to validate
          fill_in 'Name', with: 'A Name'

          expect{ click_button 'Create Product' }
                .to change{ Product.count }.by(1)

          Product.last.group.should == @group
        end
      end # From Menu
    end # Creating

    describe 'Updating a Product' do
      before do
        @product = create(:product, account: @account)
      end

      it 'should create a product with all attributes' do
        new_name = @product.name + " something else"
        visit "/products/#{@product.id}/edit"
        fill_in 'Name', with: new_name

        expect{ click_button 'Update Product' }
              .to change{ @product.reload.name }.to(new_name)
      end
    end # Updating
  end # As Account User

  context 'Without Login' do
    it 'should not redirect all to login' do
      visit '/products'
      page.current_path.should == '/users/sign_in'

      visit '/products/new'
      page.current_path.should == '/users/sign_in'

      visit '/products/edit'
      page.current_path.should == '/users/sign_in'

      visit '/products/product_id'
      page.current_path.should == '/users/sign_in'
    end
  end # Without Login
end
