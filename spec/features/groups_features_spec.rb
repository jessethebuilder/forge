describe 'Group Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
      @menu = create(:menu, account: @account)
      @group = create(:group, menu: @menu, account: @account)
    end

    describe 'Creating a Group' do
      it 'should create a group with all attributes' do
        visit '/groups/new'

        fill_in 'Name', with: 'name'
        fill_in 'Description', with: 'description'
        uncheck 'Active'

        expect{ click_button 'Create Group' }
              .to change{ Group.count }.by(1)

        group = Group.order(:created_at).last
        group.name.should == 'name'
        group.description.should == 'description'
        group.active.should == false # defaults to true
      end

      before do
        visit "/menus/#{@menu.id}/edit"
        click_link 'New Group'

        fill_in 'Name', with: 'name'
      end

      it 'should create a group' do
        expect{ click_button 'Create Group' }
              .to change{ Group.count }.by(1)
      end

      it 'should set :menu' do
        click_button 'Create Group'
        Group.last.menu.should == @menu
      end

      it 'should redirect_to edit @group' do
        click_button 'Create Group'
        page.current_path.should == "/groups/#{Group.order(:created_at).last.to_param}/edit"
      end

      it 'should save menu_id, if first form submission is unsuccessful' do
        fill_in 'Name', with: ''
        click_button 'Create Group'
        # form fails to validate
        fill_in 'Name', with: 'A Name'

        expect{ click_button 'Create Group' }
              .to change{ Group.count }.by(1)

        Group.last.menu.should == @menu
      end

      describe 'Back button' do
        it 'should direct to menus#edit' do
          visit "/menus/#{@menu.id}/edit"
          click_link 'New Group'

          page.should have_link(@menu.name, href: "/menus/#{@menu.id}/edit")
        end
      end
    end # Creating

    describe 'Updating a Group' do
      it 'should change attributes' do
        new_name = @group.name + " something else"
        visit "/groups/#{@group.id}/edit"
        fill_in 'Name', with: new_name

        expect{ click_button 'Update Group' }
              .to change{ @group.reload.name }.to(new_name)
      end

      it 'should redirect to edit @group' do
        visit "/groups/#{@group.to_param}/edit"
        click_button 'Update Group'

        page.current_path.should == "/groups/#{@group.to_param}/edit"
      end

      describe 'Back button' do
        it 'should direct to edit @menu' do
          visit "/groups/#{@group.to_param}/edit"
          page.should have_link(@menu.name, href: "/menus/#{@menu.id}/edit")
        end
      end
    end # Updating
  end # As Account User
1
  context 'Without Login' do
    it 'should not redirect all to login' do
      visit '/groups'
      page.current_path.should == '/users/sign_in'

      visit '/groups/new'
      page.current_path.should == '/users/sign_in'

      visit '/groups/edit'
      page.current_path.should == '/users/sign_in'

      visit '/groups/group_id'
      page.current_path.should == '/users/sign_in'
    end
  end # Without Login
end
