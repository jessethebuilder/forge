describe 'Product Requests', type: :request, api: true do
  before do
    @account = create(:account)
    @credential = create(:credential, account: @account)

    @menu = create(:menu)
    @group = create(:group)
    @product = create(:product, account: @account, menu: @menu, group: @group)
  end

  describe 'GET /products' do
    it 'should return an array of Products' do
      get '/products.json', headers: test_api_headers
      response.body.should == [
        {
          id: @product.id,
          name: @product.name,
          description: nil,
          order: nil,
          price: @product.price,
          data: {},
          reference: nil,
          active: true,
          created_at: @product.created_at,
          updated_at: @product.updated_at,
          menu_id: @menu.id,
          group_id: @group.id
        }
      ].to_json
    end

    it 'it SHOULD NOT return other accounts Products' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)
      get '/products.json', headers: test_api_headers
      response_data = JSON.parse(response.body)
      response_data.count.should == 1
      response_data.first['id'].should == @product.id
    end
  end # Index

  describe 'GET /products/:id' do
    it 'should return Product data' do
      @product.update(
        name: 'name',
        description: 'description',
        order: 15,
        data: {hello: 'world'},
        reference: 'reference'
      )

      get "/products/#{@product.id}.json", headers: test_api_headers

      response.body.should == {
        id: @product.id,
        name: 'name',
        description: 'description',
        order: 15,
        price: @product.price,
        data: {hello: 'world'},
        reference: 'reference',
        active: true,
        created_at: @product.created_at,
        updated_at: @product.updated_at,
        menu_id: @menu.id,
        group_id: @group.id
      }.to_json
    end

    specify 'Only Products of this Account may be fetched' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      get "/products/#{new_product.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end
  end # Show

  describe 'POST /products' do
    before do
      @create_params = {
        product: attributes_for(:product).merge({
          name: 'name',
          description: 'description',
          order: 15,
          reference: 'reference',
          price: 10.22,
          active: false})
        }
      end


    it 'should create a Product' do
      expect{ post '/products.json', params: @create_params, headers: test_api_headers }
            .to change{ Product.count }.by(1)
    end

    it 'should return Product data' do
      post '/products.json', params: @create_params, headers: test_api_headers
      created_product = Product.last

      response.body.should == {
        id: created_product.id,
        name: 'name',
        description: 'description',
        order: 15,
        price: 10.22,
        data: {},
        reference: 'reference',
        active: false,
        created_at: created_product.created_at,
        updated_at: created_product.updated_at,
        menu_id: nil,
        group_id: nil,
      }.to_json
    end

    it 'should set menu_id' do
      new_menu = create(:menu)
      @create_params[:product][:menu_id] = new_menu.id
      post '/products.json', params: @create_params, headers: test_api_headers
      Product.last.menu.should == new_menu
    end

    it 'should set group_id' do
      new_group = create(:group)
      @create_params[:product][:group_id] = new_group.id
      post '/products.json', params: @create_params, headers: test_api_headers
      Product.last.group.should == new_group
    end

    it 'should save :data' do
      @create_params[:product][:data] = {hello: 'world'}.to_json
      post '/products.json', params: @create_params, headers: test_api_headers
      Product.last.data.should == {hello: 'world'}.to_json
    end

    it 'should set @product.account to @account' do
      post '/products.json', params: @create_params, headers: test_api_headers
      Product.last.account.should == @account
    end

    context 'Bad Params' do
      before do
        @create_params[:product].delete(:price) # Now they are BAD!!
     end

      it 'should return an error' do
        post '/products.json', params: @create_params, headers: test_api_headers
        response.body.should == {
          price: [
            "can't be blank",
            'is not a number'
          ]
        }.to_json
      end

      it 'should return code ' do
        post '/products.json', params: @create_params, headers: test_api_headers
        response.status.should == 422
      end
    end # Bad Params
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
        put "/products/#{@product.id}.json",
            params: @update_params,
            headers: test_api_headers
       }.to change{ @product.reload.price }
        .to(@update_params[:product][:price])
    end

    it 'should return Product data' do
      put "/products/#{@product.id}.json",
          params: @update_params,
          headers: test_api_headers

      response.body.should == {
        id: @product.reload.id,
        name: @product.name,
        description: nil,
        order: nil,
        price: @update_params[:product][:price],
        data: {},
        reference: nil,
        active: true,
        created_at: @product.created_at,
        updated_at: @product.updated_at,
        menu_id: @menu.id,
        group_id: @group.id
      }.to_json
    end

    it 'should return code ' do
      put "/products/#{@product.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.status.should == 200
    end

    specify 'Only Products of this Account may be updated' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      put "/products/#{new_product.id}.json",
          params: @update_params,
          headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end

    context 'BAD Params' do
      before do
        @update_params[:product].delete(:price) # Now they are BAD!!
        @update_params[:product][:name] = 'a name' # Strong Params doesn't like empty params
      end

      it 'should return an error' do
        post '/products.json', params: @update_params, headers: test_api_headers
        response.body.should == {
          price: [
            "can't be blank",
            'is not a number'
          ]
        }.to_json
      end

      it 'should return code 422' do
        post '/products.json', params: @update_params, headers: test_api_headers
        response.status.should == 422
      end
    end # Bad Params
  end # Update

  describe 'DELETE /products/:id' do
    it 'should destroy a Product' do
      expect{ delete "/products/#{@product.id}.json", headers: test_api_headers }
            .to change{ Product.count }.by(-1)
      Product.find_by(id: @product.id).should == nil
    end

    it 'should return a code' do
      delete "/products/#{@product.id}.json", headers: test_api_headers
      response.status.should == 204
    end

    specify 'Only Products of this Account may be destroyed' do
      new_account = create(:account)
      new_product = create(:product, account: new_account)

      delete "/products/#{new_product.id}.json", headers: test_api_headers
      response.body.should == {
        error: I18n.t('errors.no_auth.resource', resource_type: 'Product')
      }.to_json

      response.status.should == 401
    end
  end # Destroy
end
