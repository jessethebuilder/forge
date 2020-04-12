describe ProductsController, type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)

    @menu = create(:menu)
    @group = create(:group)
    @product = create(:product, account: @account, menu: @menu, group: @group)
  end

  describe 'GET /products' do
    it 'should return an array of Products' do
      get '/products.json', headers: api_headers
      response.body.should == [
        {
          id: @product.to_param,
          account_id: @account.to_param,
          menu_id: @menu.to_param,
          group_id: @group.to_param,
          name: nil,
          description: nil,
          order: nil,
          price: @product.price,
          data: {},
          active: true,
          created_at: @product.created_at,
          updated_at: @product.updated_at
        }
      ].to_json
    end

    it 'it SHOULD NOT return other accounts Products' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)
      get '/products.json', headers: api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @product.to_param
    end
  end # Index

  describe 'GET /products/:id' do
    it 'should return Product data' do
      @product.update(
        name: 'name',
        description: 'description',
        order: 15,
        data: {hello: 'world'},
      )

      get "/products/#{@product.to_param}.json", headers: api_headers

      response.body.should == {
        id: @product.to_param,
        account_id: @account.to_param,
        menu_id: @menu.to_param,
        group_id: @group.to_param,
        name: 'name',
        description: 'description',
        order: 15,
        price: @product.price,
        data: {hello: 'world'},
        active: true,
        created_at: @product.created_at,
        updated_at: @product.updated_at
      }.to_json
    end

    specify 'Only Products of this Account may be fetched' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      get "/products/#{new_product.to_param}.json", headers: api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end
  end # Show

  describe 'POST /products' do
    before do
      @create_params = {product: attributes_for(:product)}
    end

    it 'should create a Product' do
      expect{ post '/products.json', params: @create_params, headers: api_headers }
            .to change{ Product.count }.by(1)
    end

    it 'should return Product data' do
      post '/products.json', params: @create_params, headers: api_headers
      created_product = Product.last

      response.body.should == {
        id: created_product.to_param,
        account_id: @account.to_param,
        menu_id: nil,
        group_id: nil,
        name: nil,
        description: nil,
        order: nil,
        price: created_product.price,
        data: {},
        active: true,
        created_at: created_product.created_at,
        updated_at: created_product.updated_at
      }.to_json
    end

    it 'should set @product.account to @account' do
      post '/products.json', params: @create_params, headers: api_headers
      Product.last.account.should == @account
    end

    context 'Bad Params' do
      before do
        @create_params[:product].delete(:price) # Now they are BAD!!
        @create_params[:product][:name] = 'a name' # Strong Params doesn't like empty params
      end

      it 'should return an error' do
        post '/products.json', params: @create_params, headers: api_headers
        response.body.should == {
          price: [
            "can't be blank",
            'is not a number'
          ]
        }.to_json
      end

      it 'should return code ' do
        post '/products.json', params: @create_params, headers: api_headers
        response.status.should == 422
      end
    end
  end # Create

  describe 'PUT /products/:id' do
    before do
      @update_params = {
        product: {
          price: @product.price + 1
        }
      }
    end

    it 'should update @product' do
      expect{
        put "/products/#{@product.to_param}.json",
            params: @update_params,
            headers: api_headers
       }.to change{ @product.reload.price }
        .to(@update_params[:product][:price])
    end

    it 'should return Product data' do
      put "/products/#{@product.to_param}.json",
          params: @update_params,
          headers: api_headers

      response.body.should == {
        id: @product.reload.to_param,
        account_id: @account.to_param,
        menu_id: @menu.to_param,
        group_id: @group.to_param,
        name: nil,
        description: nil,
        order: nil,
        price: @update_params[:product][:price],
        data: {},
        active: true,
        created_at: @product.created_at,
        updated_at: @product.updated_at
      }.to_json
    end

    it 'should return code ' do
      put "/products/#{@product.to_param}.json",
          params: @update_params,
          headers: api_headers
      response.status.should == 200
    end

    specify 'Only Products of this Account may be destroyed' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      put "/products/#{new_product.to_param}.json",
          params: @update_params,
          headers: api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end

    context 'Bad Params' do
      before do
        @update_params[:product].delete(:price) # Now they are BAD!!
        @update_params[:product][:name] = 'a name' # Strong Params doesn't like empty params
      end

      it 'should return an error' do
        post '/products.json', params: @update_params, headers: api_headers
        response.body.should == {
          price: [
            "can't be blank",
            'is not a number'
          ]
        }.to_json
      end

      it 'should return code 422' do
        post '/products.json', params: @update_params, headers: api_headers
        response.status.should == 422
      end
    end
  end # Update

  describe 'DELETE /products/:id' do
    it 'should destroy a Product' do
      expect{ delete "/products/#{@product.to_param}.json", headers: api_headers }
            .to change{ Product.count }.by(-1)
      Product.find_by(id: @product.id).should == nil
    end

    it 'should return a code' do
      delete "/products/#{@product.to_param}.json", headers: api_headers
      response.status.should == 204
    end

    specify 'Only Products of this Account may be destroyed' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      delete "/products/#{new_product.to_param}.json", headers: api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
