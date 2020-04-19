describe 'Group Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @group_name = Faker::Lorem.word
    @menu = create(:menu, account: @account)
    @group = create(:group, account: @account, name: @group_name, menu: @menu)
  end

  describe 'GET /groups' do
    it 'should return an array of Groups' do
      get '/groups.json', headers: test_api_headers
      response.body.should == [
        {
          id: @group.id,
          name: @group_name,
          description: nil,
          order: nil,
          data: {},
          reference: nil,
          active: true,
          created_at: @group.created_at,
          updated_at: @group.updated_at,
          menu_id: @menu.id,
        }
      ].to_json
    end

    it 'it SHOULD NOT return other accounts Groups' do
      new_account = create(:account)
      new_group = create(:group, account: new_account)
      get '/groups.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @group.id
    end

    describe 'Depth' do
      before do
        @product1 = create(:product, group: @group, account: @account)
        @product2 = create(:product, group: @group, account: @account)
      end

      it 'should return Products belonging to Group' do
        get "/groups.json",
            params: {deep: true},
            headers: test_api_headers

        products_data = JSON.parse(response.body).first['products']
        products_data.first['id'].should == @product1.id
        products_data.last['id'].should == @product2.id
      end

      describe 'With Inacive associated records' do
        before do
          @product1.update(active: false)
        end

        it 'should show only active records if scope is :active (default)' do
          get "/groups.json",
              params: {deep: true},
              headers: test_api_headers
          data = JSON.parse(response.body).first['products']
          data.count.should == 1
          data.first['id'].should == @product2.id
        end

        it 'should show only active records if scope is :all' do
          get "/groups.json",
              params: {deep: true, scope: :all},
              headers: test_api_headers
          data = JSON.parse(response.body).first['products']
          data.count.should == 2
        end
      end
    end # Depth
  end # Index

  describe 'GET /groups/:id' do
    it 'should return Group data' do
      @group.update(
        name: 'name',
        description: 'description',
        order: 15,
        data: {hello: 'world'},
        reference: 'reference'
      )

      get "/groups/#{@group.id}.json", headers: test_api_headers

      response.body.should == {
        id: @group.id,
        name: 'name',
        description: 'description',
        order: 15,
        data: {hello: 'world'},
        reference: 'reference',
        active: true,
        created_at: @group.created_at,
        updated_at: @group.updated_at,
        menu_id: @menu.id
      }.to_json
    end

    specify 'Only Groups of this Account may be fetched' do
      new_account = create(:account)
      new_group = create(:group, account: new_account)

      get "/groups/#{new_group.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Group')
      }.to_json

      response.status.should == 401
    end

    describe 'Depth' do
      before do
        @product1 = create(:product, group: @group, account: @account)
        @product2 = create(:product, group: @group, account: @account)
      end

      it 'should return Products belonging to Group' do
        get "/groups.json",
            params: {deep: true},
            headers: test_api_headers

        products_data = JSON.parse(response.body).first['products']
        products_data.first['id'].should == @product1.id
        products_data.last['id'].should == @product2.id
      end

      describe 'With Inacive associated records' do
        before do
          @product1.update(active: false)
        end

        it 'should show only active records if scope is :active (default)' do
          get "/groups/#{@group.id}.json",
              params: {deep: true},
              headers: test_api_headers
          data = JSON.parse(response.body)['products']
          data.count.should == 1
          data.first['id'].should == @product2.id
        end

        it 'should show only active records if scope is :all' do
          get "/groups/#{@group.id}.json",
              params: {deep: true, scope: :all},
              headers: test_api_headers
          data = JSON.parse(response.body)['products']
          data.count.should == 2
        end
      end
    end # Depth
  end # Show

  describe 'POST /groups' do
    before do
      @create_params = {
        group: attributes_for(:group, name: Faker::Lorem.word)
                             .merge(
                               {name: 'name',
                                description: 'description',
                                order: 15,
                                reference: 'reference',
                                active: false})
      }
    end

    it 'should create a Group' do
      expect{ post '/groups.json', params: @create_params, headers: test_api_headers }
            .to change{ Group.count }.by(1)
    end

    it 'should return Group data' do
      post '/groups.json', params: @create_params, headers: test_api_headers
      created_group = Group.order(created_at: :desc).first

      response.body.should == {
        id: created_group.id,
        name: 'name',
        description: 'description',
        order: 15,
        data: {},
        reference: 'reference',
        active: false,
        created_at: created_group.created_at,
        updated_at: created_group.updated_at,
        menu_id: nil
      }.to_json
    end

    it 'should accept menu_id as a param' do
      menu = create(:menu, account: @account)
      post '/groups.json',
           params: {group: attributes_for(:group, menu_id: menu.id)},
           headers: test_api_headers
      Group.order(created_at: :desc).first.menu.should == menu
    end

    it 'should save :data' do
      @create_params[:group][:data] = {hello: 'world'}.to_json
      post '/groups.json', params: @create_params, headers: test_api_headers
      Group.order(created_at: :desc).first.data.should == {hello: 'world'}.to_json
    end

    it 'should set @group.account to @account' do
      post '/groups.json', params: @create_params, headers: test_api_headers
      Group.last.account.should == @account
    end

    context 'Bad Params' do
      before do
        @create_params[:group].delete(:name) # Now they are BAD!!
        @create_params[:group][:description] = 'arbitrary'
      end

      it 'should return an error' do
        post '/groups.json', params: @create_params, headers: test_api_headers
        response.body.should == {
          name: ["can't be blank"]
        }.to_json
      end

      it 'should return code ' do
        post '/groups.json', params: @create_params, headers: test_api_headers
        response.status.should == 422
      end
    end
  end # Create

  describe 'PUT /groups/:id' do
    before do
      @update_params = {
        group: {
          name: @group.name.to_s + " the Third!"
        }
      }
    end

    it 'should update @group' do
      expect{
        put "/groups/#{@group.id}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @group.reload.name }
        .to(@update_params[:group][:name])
    end

    it 'should return Group data' do
      put "/groups/#{@group.id}.json",
          params: @update_params,
          headers: test_api_headers

      response.body.should == {
        id: @group.reload.id,
        name: "#{@group_name} the Third!",
        description: nil,
        order: nil,
        data: {},
        reference: nil,
        active: true,
        created_at: @group.created_at,
        updated_at: @group.updated_at,
        menu_id: @menu.id
      }.to_json
    end

    it 'should return code ' do
      put "/groups/#{@group.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Groups of this Account may be updated' do
      new_account = create(:account)
      new_group = create(:group, account: new_account)

      put "/groups/#{new_group.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Group')
      }.to_json

      response.status.should == 401
    end

    context 'BAD Params' do
      before do
        @update_params[:group].delete(:name) # Now they are BAD!!
        @update_params[:group][:description] = 'arbitrary' # Strong Params doesn't like empty params
      end

      it 'should return an error' do
        post '/groups.json', params: @update_params, headers: test_api_headers
        response.body.should == {
          name: ["can't be blank"]
        }.to_json
      end

      it 'should return code 422' do
        post '/groups.json', params: @update_params, headers: test_api_headers
        response.status.should == 422
      end
    end # Bad Params
  end # Update

  describe 'DELETE /groups/:id' do
    it 'should destroy a Group' do
      expect{ delete "/groups/#{@group.id}.json", headers: test_api_headers }
            .to change{ Group.count }.by(-1)
      Group.find_by(id: @group.id).should == nil
    end

    it 'should return a code' do
      delete "/groups/#{@group.id}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Groups of this Account may be destroyed' do
      new_account = create(:account)
      new_group = create(:group, account: new_account)

      delete "/groups/#{new_group.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Group')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
