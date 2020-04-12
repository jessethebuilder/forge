describe MenusController, type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @menu_name = Faker::Lorem.word # Arbitrary attribute so not empty, and can pass Strong Params
    @menu = create(:menu, account: @account, name: @menu_name)
  end

  describe 'GET /menus' do
    it 'should return an array of Menus' do
      get '/menus.json', headers: test_api_headers
      response.body.should == [
        {
          id: @menu.to_param,
          name: @menu_name,
          description: nil,
          data: {},
          reference: nil,
          active: true,
          created_at: @menu.created_at,
          updated_at: @menu.updated_at,
        }
      ].to_json
    end

    it 'it SHOULD NOT return other accounts Menus' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)
      get '/menus.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @menu.to_param
    end
  end # Index

  describe 'GET /menus/:id' do
    it 'should return Menu data' do
      @menu.update(
        name: 'name',
        description: 'description',
        data: {hello: 'world'},
        reference: 'reference'
      )

      get "/menus/#{@menu.to_param}.json", headers: test_api_headers

      response.body.should == {
        id: @menu.to_param,
        name: 'name',
        description: 'description',
        data: {hello: 'world'},
        reference: 'reference',
        active: true,
        created_at: @menu.created_at,
        updated_at: @menu.updated_at,
      }.to_json
    end

    specify 'Only Menus of this Account may be fetched' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      get "/menus/#{new_menu.to_param}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end
  end # Show

  describe 'POST /menus' do
    before do
      @create_params = {
        menu: attributes_for(:menu, name: Faker::Lorem.word)
                             .merge(
                               {name: 'name',
                                description: 'description',
                                reference: 'reference',
                                active: false})
      }
    end

    it 'should create a Menu' do
      expect{ post '/menus.json', params: @create_params, headers: test_api_headers }
            .to change{ Menu.count }.by(1)
    end

    it 'should return Menu data' do
      post '/menus.json', params: @create_params, headers: test_api_headers
      created_menu = Menu.last

      response.body.should == {
        id: created_menu.to_param,
        name: 'name',
        description: 'description',
        data: {},
        reference: 'reference',
        active: false,
        created_at: created_menu.created_at,
        updated_at: created_menu.updated_at,
      }.to_json
    end

    it 'should save :data' do
      @create_params[:menu][:data] = {hello: 'world'}.to_json
      post '/menus.json', params: @create_params, headers: test_api_headers
      Menu.last.data.should == {hello: 'world'}.to_json
    end

    it 'should set @menu.account to @account' do
      post '/menus.json', params: @create_params, headers: test_api_headers
      Menu.last.account.should == @account
    end
  end # Create

  describe 'PUT /menus/:id' do
    before do
      @update_params = {
        menu: {
          name: @menu.name.to_s + " the Third!"
        }
      }
    end

    it 'should update @menu' do
      expect{
        put "/menus/#{@menu.to_param}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @menu.reload.name }
        .to(@update_params[:menu][:name])
    end

    it 'should return Menu data' do
      put "/menus/#{@menu.to_param}.json",
          params: @update_params,
          headers: test_api_headers

      response.body.should == {
        id: @menu.reload.to_param,
        name: "#{@menu_name} the Third!",
        description: nil,
        data: {},
        reference: nil,
        active: true,
        created_at: @menu.created_at,
        updated_at: @menu.updated_at,
      }.to_json
    end

    it 'should return code ' do
      put "/menus/#{@menu.to_param}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Menus of this Account may be updated' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      put "/menus/#{new_menu.to_param}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end
  end # Update

  describe 'DELETE /menus/:id' do
    it 'should destroy a Menu' do
      expect{ delete "/menus/#{@menu.to_param}.json", headers: test_api_headers }
            .to change{ Menu.count }.by(-1)
      Menu.find_by(id: @menu.id).should == nil
    end

    it 'should return a code' do
      delete "/menus/#{@menu.to_param}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Menus of this Account may be destroyed' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      delete "/menus/#{new_menu.to_param}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
