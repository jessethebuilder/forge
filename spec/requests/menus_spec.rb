describe 'Menu Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @menu_name = Faker::Lorem.word
    @menu = create(:menu, account: @account, name: @menu_name)
  end

  describe 'GET /menus' do
    it 'should return an array of Menus' do
      get '/menus.json', headers: test_api_headers
      response.body.should == [ menu_response(@menu) ].to_json
    end

    it 'it SHOULD NOT return other accounts Menus' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)
      get '/menus.json', headers: test_api_headers
      response.body.should == [ menu_response(@menu) ].to_json
    end
  end # Index

  describe 'GET /menus/:id' do
    it 'should return Menu data' do
      get "/menus/#{@menu.id}.json", headers: test_api_headers

      response.body.should == menu_response(@menu, deep: true).to_json
    end

    specify 'Only Menus of this Account may be fetched' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      get "/menus/#{new_menu.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end

    describe 'Groups and Product' do
      # TODO Clean this up by following the Products section of requests/groups_spec,
      # which uses innactive/archived Products to test scope.
      before do
        @group1 = create(:group, menu: @menu, account: @account)
        @product1 = create(:product, group: @group1, account: @account, menu: @menu)
        @product2 = create(:product, group: @group1, account: @account, menu: @menu)
        @group2 = create(:group, account: @account, menu: @menu)
        @product3 = create(:product, group: @group2, account: @account, menu: @menu)
      end

      it 'should return Groups belonging to Menu' do
        get "/menus/#{@menu.id}.json",
            params: {deep: true},
            headers: test_api_headers

        groups_data = JSON.parse(response.body)['groups']
        groups_data.first['id'].should == @group1.id
        groups_data.last['id'].should == @group2.id
      end

      it 'should return Product data as well' do
        get "/menus/#{@menu.id}.json",
            params: {deep: true},
            headers: test_api_headers

        products_data = JSON.parse(response.body)['groups'].first['products']
        products_data.first['id'].should == @product1.id
        products_data.last['id'].should == @product2.id
      end

      describe 'With Inacive associated records' do
        before do
          @group2.update(active: false)
        end

        it 'should show only active records if scope is :active (default)' do
          get "/menus/#{@menu.id}.json",
              params: {deep: true},
              headers: test_api_headers
          data = JSON.parse(response.body)['groups']
          data.count.should == 1
          data.first['id'].should == @group1.id
        end

        it 'should show only active records if scope is :all' do
          get "/menus/#{@menu.id}.json",
              params: {deep: true, scope: :all},
              headers: test_api_headers
          data = JSON.parse(response.body)['groups']
          data.count.should == 2
        end
      end

      describe 'With inactive products' do
        before do
          @product1.update(active: false)
        end

        it 'should show only active records if scope is :active (default)' do
          get "/menus/#{@menu.id}.json",
              params: {deep: true},
              headers: test_api_headers
          data = JSON.parse(response.body)['groups'].first['products']
          data.count.should == 1
          data.first['id'].should == @product2.id
        end

        it 'should show only active records if scope is :all' do
          get "/menus/#{@menu.id}.json",
              params: {deep: true, scope: :all},
              headers: test_api_headers
          data = JSON.parse(response.body)['groups'].first['products']
          data.count.should == 2
        end
      end
    end # Groups and Product
  end # Show

  describe 'POST /menus' do
    before do
      @create_params = {
        menu: attributes_for(:menu, name: Faker::Lorem.word)
                             .merge({name: 'name',})
      }
    end

    it 'should create a Menu' do
      expect{ post '/menus.json', params: @create_params, headers: test_api_headers }
            .to change{ Menu.count }.by(1)
    end

    it 'should return Menu data' do
      post '/menus.json', params: @create_params, headers: test_api_headers
      created_menu = Menu.last

      response.body.should == menu_response(created_menu).to_json
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
    context 'Bad Params' do
      before do
        @create_params[:menu].delete(:name) # Now they are BAD!!
        @create_params[:menu][:description] = 'arbitrary'
      end

      it 'should return an error' do
        post '/menus.json', params: @create_params, headers: test_api_headers
        response.body.should == {
          name: ["can't be blank"]
        }.to_json
      end

      it 'should return code ' do
        post '/menus.json', params: @create_params, headers: test_api_headers
        response.status.should == 422
      end
    end
  end # Create

  describe 'PUT /menus/:id' do
    before do
      @update_params = {
        menu: {name: "A New Name"}
      }
    end

    it 'should update @menu' do
      expect{
        put "/menus/#{@menu.id}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @menu.reload.name }
        .to(@update_params[:menu][:name])
    end

    it 'should return Menu data' do
      put "/menus/#{@menu.id}.json",
          params: @update_params,
          headers: test_api_headers

      response.body.should == menu_response(
        @menu.reload,
        updates: {name: 'A New Name'}
      ).to_json
    end

    it 'should return code ' do
      put "/menus/#{@menu.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Menus of this Account may be updated' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      put "/menus/#{new_menu.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end

    context 'BAD Params' do
      before do
        @update_params[:menu].delete(:name) # Now they are BAD!!
        @update_params[:menu][:description] = 'arbitrary' # Strong Params doesn't like empty params
      end

      it 'should return an error' do
        post '/menus.json', params: @update_params, headers: test_api_headers
        response.body.should == {
          name: ["can't be blank"]
        }.to_json
      end

      it 'should return code 422' do
        post '/menus.json', params: @update_params, headers: test_api_headers
        response.status.should == 422
      end
    end # Bad Params
  end # Update

  describe 'DELETE /menus/:id' do
    it 'should destroy a Menu' do
      expect{ delete "/menus/#{@menu.id}.json", headers: test_api_headers }
            .to change{ Menu.count }.by(-1)
      Menu.find_by(id: @menu.id).should == nil
    end

    it 'should return a code' do
      delete "/menus/#{@menu.id}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Menus of this Account may be destroyed' do
      new_account = create(:account)
      new_menu = create(:menu, account: new_account)

      delete "/menus/#{new_menu.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Menu')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
