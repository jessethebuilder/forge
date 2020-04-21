describe 'Menu Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
      @menu = create(:menu, account: @account)
    end

    describe 'Creating a Menu' do
      it 'should create a menu with all attributes' do
        menu_min

        uncheck 'Active'

        expect{ click_button 'Create Menu' }
              .to change{ Menu.count }.by(1)

        menu = Menu.last
        menu.name.should == 'name'
        menu.active.should == false # defaults to true
      end

      it 'should redirect to menus#edit' do
        menu_min
        click_button 'Create Menu'
        menu = Menu.order(created_at: :desc).first
        page.current_path.should == "/menus/#{menu.id}/edit"
      end
    end # Creating

    describe 'Updating a Menu' do
      before do
        @menu = create(:menu, account: @account)
      end

      it 'should change attributes' do
        new_name = @menu.name + " something else"
        visit "/menus/#{@menu.to_param}/edit"
        fill_in 'Name', with: new_name

        expect{ click_button 'Update Menu' }
              .to change{ @menu.reload.name }.to(new_name)
      end
    end # Updating

    describe 'Editing Groups', js: true do
      before do
        @group = create(:group, menu: @menu, account: @account)
      end

      describe 'Active?' do
        it 'should deactive on check' do
          visit "/menus/#{@menu.to_param}/edit"
          within('#groups') do
            expect{ find("#group_#{@group.id}_active").uncheck }
                  .to change{ @group.reload.active }.from(true).to(false)
          end
        end

        it 'should re-active on check' do
          @group.update(active: false)
          visit "/menus/#{@menu.to_param}/edit"
          within('#groups') do
            expect{ find("#group_#{@group.id}_active").check }
                  .to change{ @group.reload.active }.from(false).to(true)
          end
        end
      end
    end
  end # As Account User

  context 'Without Login' do
    it 'should not redirect all to login' do
      visit '/menus'
      page.current_path.should == '/users/sign_in'

      visit '/menus/new'
      page.current_path.should == '/users/sign_in'

      visit '/menus/edit'
      page.current_path.should == '/users/sign_in'

      visit '/menus/menu_id'
      page.current_path.should == '/users/sign_in'
    end
  end # Without Login
end
