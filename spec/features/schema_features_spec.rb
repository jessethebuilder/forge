# Account::schema is the level at which the Web user interacts with the app.
# So, scheme = 'menu' means they can access menus, groups, and products. Products
# can only access Products. Schema also changes the pages a User returns to
# when they click "Back" or after they create a Record. After Record creation
# is handled in those Feature specs. The rest is speced here.

describe 'Schema Features', type: :feature do
  before do
    setup_feature_spec
  end

  describe '"product" schema' do
    before do
      @account.update(schema: 'product')
    end

    it 'should show link to "Products" on /account' do
      visit '/account'
      page.should have_link('Products')
    end


    it 'should not allow user to visit /groups' do
      # This should only occur if a user types a URL in by hand, which they may do.
      visit '/groups'
      page.current_path.should == '/account'
    end

    it 'should not allow user to visit /menus' do
      # This should only occur if a user types a URL in by hand, which they may do.
      visit '/menus'
      page.current_path.should == '/account'
    end
  end # product

  describe '"group" schema' do
    before do
      @account.update(schema: 'group')
    end

    it 'should show link to "Groups" on /account' do
      visit '/account'
      page.should have_link('Groups')
    end

    it 'should not allow user to visit /products' do
      # This should only occur if a user types a URL in by hand, which they may do.
      visit '/products'
      page.current_path.should == '/account'
    end

    it 'should not allow user to visit /menus' do
      # This should only occur if a user types a URL in by hand, which they may do.
      visit '/menus'
      page.current_path.should == '/account'
    end
  end # group
end
