describe 'Customer Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)
    @customer_name = Faker::Name.name # Arbitrary attribute so not empty, and can pass Strong Params
    @customer = create(:customer, account: @account, name: @customer_name)
  end

  describe 'GET /customers' do
    it 'should return an array of Customers' do
      get '/customers.json', headers: test_api_headers
      response.body.should == [ customer_response(@customer) ].to_json
    end

    it 'it SHOULD NOT return other accounts Customers' do
      new_account = create(:account)
      new_customer = create(:customer, account: new_account)
      get '/customers.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @customer.id
    end
  end # Index

  describe 'GET /customers/:id' do
    it 'should return Customer data' do
      @customer.update(name: 'Jeff McTesterson')

      get "/customers/#{@customer.id}.json", headers: test_api_headers

      response.body.should == customer_response(
        @customer.reload,
        updates: {name: 'Jeff McTesterson'}
      ).to_json
    end

    specify 'Only Customers of this Account may be fetched' do
      new_account = create(:account)
      new_customer = create(:customer, account: new_account)

      get "/customers/#{new_customer.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Customer')
      }.to_json

      response.status.should == 401
    end
  end # Show

  describe 'POST /customers' do
    before do
      @create_params = {
        customer: attributes_for(:customer, name: Faker::Lorem.word)
                             .merge({name: 'Big Jeff'})
      }
    end

    it 'should create a Customer' do
      expect{ post '/customers.json', params: @create_params, headers: test_api_headers }
            .to change{ Customer.count }.by(1)
    end

    it 'should return Customer data' do
      post '/customers.json', params: @create_params, headers: test_api_headers
      created_customer = Customer.last

      response.body.should == customer_response(
        created_customer,
        updates: {name: 'Big Jeff'}
      ).to_json
    end

    it 'should save :data' do
      @create_params[:customer][:data] = {hello: 'world'}.to_json
      post '/customers.json', params: @create_params, headers: test_api_headers
      Customer.last.data.should == {hello: 'world'}.to_json
    end

    it 'should set @customer.account to @account' do
      post '/customers.json', params: @create_params, headers: test_api_headers
      Customer.last.account.should == @account
    end
  end # Create

  describe 'PUT /customers/:id' do
    before do
      @update_params = {
        customer: {
          name: "Super Jeff"
        }
      }
    end

    it 'should update @customer' do
      expect{
        put "/customers/#{@customer.id}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @customer.reload.name }
        .to(@update_params[:customer][:name])
    end

    it 'should return Customer data' do
      put "/customers/#{@customer.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == customer_response(
        @customer.reload,
        updates: {name: 'Super Jeff'}
      ).to_json
    end

    it 'should return code ' do
      put "/customers/#{@customer.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Customers of this Account may be updated' do
      new_account = create(:account)
      new_customer = create(:customer, account: new_account)

      put "/customers/#{new_customer.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Customer')
      }.to_json

      response.status.should == 401
    end
  end # Update

  describe 'DELETE /customers/:id' do
    it 'should destroy a Customer' do
      expect{ delete "/customers/#{@customer.id}.json", headers: test_api_headers }
            .to change{ Customer.count }.by(-1)
      Customer.find_by(id: @customer.id).should == nil
    end

    it 'should return a code' do
      delete "/customers/#{@customer.id}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Customers of this Account may be destroyed' do
      new_account = create(:account)
      new_customer = create(:customer, account: new_account)

      delete "/customers/#{new_customer.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Customer')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
