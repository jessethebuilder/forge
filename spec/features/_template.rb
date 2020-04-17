describe 'Modlex Features', type: :feature do
  context 'As Account User' do
    before do
      setup_feature_spec
    end

    describe 'Creating a Modlex' do
      it 'should create a modlex with all attributes' do
        visit '/modlexs/new'
      end
    end
  end # As Account User

  context 'Without Login' do
    it 'should not redirect all to login' do
      visit '/modlexs'
      page.current_path.should == '/users/sign_in'

      visit '/modlexs/new'
      page.current_path.should == '/users/sign_in'

      visit '/modlexs/edit'
      page.current_path.should == '/users/sign_in'

      visit '/modlexs/modlex_id'
      page.current_path.should == '/users/sign_in'
    end
  end # Without Login
end
