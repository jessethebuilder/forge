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
      response.body.should == [ group_response(@group) ].to_json
    end

    it 'it SHOULD NOT return other accounts Groups' do
      new_account = create(:account)
      new_group = create(:group, account: new_account)
      get '/groups.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @group.id
    end

    describe 'Scopes' do
      before do
        @inactive_group = create(:group, :inactive, account: @account)
        @archived_group = create(:group, :archived, account: @account)
      end

      it 'should return only active products, by default' do
        get '/groups.json', headers: test_api_headers
        json = JSON.parse(response.body)
        json.count.should == 1
        json.first['id'].should == @group.id
      end

      it 'should return only inactive products, if "inactive" is passed to :scope' do
        get '/groups.json?scope=inactive', headers: test_api_headers
        json = JSON.parse(response.body)
        json.count.should == 1
        json.first['id'].should == @inactive_group.id
      end

      it 'should return only archived products, if "archived" is passed to :scope' do
        get '/groups.json?scope=archived', headers: test_api_headers
        json = JSON.parse(response.body)
        json.count.should == 1
        json.first['id'].should == @archived_group.id
      end

      it 'should return ALL Products, if "all" is passed to :scope' do
        get '/groups.json?scope=all', headers: test_api_headers
        json = JSON.parse(response.body)
        json.count.should == @account.groups.count
      end

      it 'should return active Products, if an unrecognized scope is passed to :scope' do
        get '/groups.json?scope=some_mess', headers: test_api_headers
        json = JSON.parse(response.body)
        json.count.should == 1
        json.first['id'].should == @group.id
      end
    end # Scopes
  end # Index

  describe 'GET /groups/:id' do
    it 'should return Group data' do
      get "/groups/#{@group.id}.json", headers: test_api_headers

      response.body.should == group_response(@group, deep: true).to_json
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

    describe 'Products' do
      before do
        @product = create(:product, group: @group, account: @account)
        @inactive_product = create(:product, :inactive, group: @group, account: @account)
        @archived_product = create(:product, :archived, group: @group, account: @account)
      end

      it 'should return Products belonging to Group' do
        get "/groups/#{@group.to_param}.json", headers: test_api_headers

        response.body.should == group_response(
          @group,
          updates: {products: [ product_response(@product) ]}
        ).to_json
      end

      it 'should show only inactive Products if scope is :inactive' do
        get "/groups/#{@group.id}.json?scope=inactive", headers: test_api_headers
        response.body.should == group_response(
          @group,
          updates: {products: [ product_response(@inactive_product) ]}
        ).to_json
      end

      it 'should show only archived Products if scope is :archived' do
        get "/groups/#{@group.id}.json?scope=archived", headers: test_api_headers
        response.body.should == group_response(
          @group,
          updates: {products: [ product_response(@archived_product) ]}
        ).to_json
      end

      it 'should show only active records if scope is :all' do
        get "/groups/#{@group.id}.json?scope=all", headers: test_api_headers
        JSON.parse(response.body)['products'].count.should == 3
      end
    end # Products
  end # Show

  describe 'POST /groups' do
    before do
      @create_params = {
        group: attributes_for(:group, name: Faker::Lorem.word)
                             .merge(
                               {name: 'name',
                                description: 'description',
                                order: 15,
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

      response.body.should == group_response(created_group).to_json
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

      response.body.should == group_response(@group.reload).to_json
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
