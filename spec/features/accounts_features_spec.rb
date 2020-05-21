describe 'Account Features', type: :feature do
  describe 'Root Path' do
    context 'With Login' do
      before do
        setup_feature_spec
      end

      describe 'Showing a Account' do
        it 'should show User their Account' do
          visit "/account"
          current_path.should == "/account"
        end

        it '/new should redirect to account page' do
          visit '/account/new'
          page.should have_css('#account')
        end
      end
    end # With Login

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
  end
end
