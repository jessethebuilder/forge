describe 'Group Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
      @menu = create(:menu, account: @account)
      @group = create(:group, menu: @menu, account: @account)
    end

    describe 'Creating a Group' do
      it 'should create a group with all attributes' do
        group_min

        fill_in 'Description', with: 'description'
        uncheck 'Active'

        expect{ click_button 'Create Group' }
              .to change{ Group.count }.by(1)

        group = Group.last
        group.name.should == 'name'
        group.description.should == 'description'
        group.active.should == false # defaults to true
      end

      it 'should redirect to /groups' do
        group_min
        click_button 'Create Group'
        page.current_path.should == '/groups'
      end

      describe 'Creating a Group from Group Menu' do
        before do
          visit "/menus/#{@menu.id}"
          click_link 'New Group'

          fill_in 'Name', with: 'name'
        end

        it 'should set :group if group_id is passed as param' do
          click_button 'Create Group'
          Group.last.menu.should == @menu
        end

        it 'should redirect_to @menu' do
          click_button 'Create Group'
          page.current_path.should == "/menus/#{@menu.id}"
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
      end # From Menu
    end # Creating

    describe 'Updating a Group' do
      before do
        @group = create(:group, account: @account)
      end

      it 'should change attributes' do
        new_name = @group.name + " something else"
        visit "/groups/#{@group.id}/edit"
        fill_in 'Name', with: new_name

        expect{ click_button 'Update Group' }
              .to change{ @group.reload.name }.to(new_name)
      end
    end # Updating
  end # As Account User

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
