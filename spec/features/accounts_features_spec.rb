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
          visit '/accounts/new'
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

    describe 'Creating an Account' do
      before do
        @account_params = attributes_for(:account)
      end

      it 'should create an Account if email is provided' do
        account_min(account_params: @account_params)
        expect{ click_button 'Create Account' }.to change{ Account.count }.by(1)

        account = Account.last
        account.contact_email.should == @account_params[:contact_email]
      end

      it 'should save contact_sms' do
        phone = Faker::PhoneNumber.phone_number
        account_min(account_params: @account_params)
        fill_in 'Phone', with: phone
        click_button 'Create Account'

        Account.last.contact_sms.should == phone
      end

      describe 'New Credential' do
        before do
          @credential_params = attributes_for(:credential)
          account_min(account_params: @account_params, credential_params: @credential_params)
          click_button 'Create Account'
          @account = Account.last
        end

        it 'should create a Credential for Account' do
          @account.credentials.count.should == 1
          @account.credentials.last.username = @credential_params[:username]
        end
      end

      describe 'New User' do
        before do
          @user_params = attributes_for(:user)
          account_min(account_params: @account_params, user_params: @user_params)
          click_button 'Create Account'
          @account = Account.last
        end

        it 'should create a User for Account' do
          @account.users.count.should == 1
        end

        specify 'New user should share email with Account' do
          @account.users.last.email.should == @account.contact_email
        end

        it 'should log new user in and redirect to /account' do
          current_path.should == '/account'
        end

        it 'should include relevant flash message' do
          within('#flash') do
            page.should have_content('Your Account has been created!')
          end
        end
      end
    end # Creating an Account
  end
end
