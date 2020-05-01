describe 'Account Features', type: :feature do
  describe 'Root Path' do
    context 'With Login' do
      before do
        setup_feature_spec
      end

      # describe 'Editing Menus', js: true do
      #   before do
      #     @menu = create(:menu, account: @account)
      #   end
      #
      #   describe 'Active?' do
      #     it 'should deactive on check' do
      #       visit "/"
      #       within('#menus') do
      #         expect{ find("#menu_#{@menu.id}_active").uncheck }
      #               .to change{ @menu.reload.active }.from(true).to(false)
      #       end
      #     end
      #
      #     it 'should re-active on check' do
      #       @menu.update(active: false)
      #       visit "/"
      #       within('#menus') do
      #         expect{ find("#menu_#{@menu.id}_active").check }
      #               .to change{ @menu.reload.active }.from(false).to(true)
      #       end
      #     end
      #   end
      # end
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
