describe 'Account Features', type: :feature do
  describe 'Root Path' do
    context 'Without Login' do
      it 'should redirect to New Account Signup' do
        visit '/'
        page.should have_css('#new_account')
      end

      it 'should redirect to signin from /account' do
        visit '/account'
        page.current_path.should == '/users/sign_in'
      end
    end # Without Login

    context 'As Account User' do
      before do
        setup_feature_spec
      end

      it 'should show account page' do
        visit '/'
        page.should have_css('#account')
      end

      it '/new should redirect to account page' do
        visit '/account/new'
        page.should have_css('#account')
      end
    end
  end
end
