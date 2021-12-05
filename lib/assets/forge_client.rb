# load 'lib/assets/forge_client.rb'

require 'rest-client'

class ForgeClient
  def self.test
    new('test_token', debug: true).get_group(Group.last.id)
  end

  def initialize(token, debug: false)
    @token = token
    @debug = debug
  end

  def get_orders
    make_request do
      RestClient.get(
        "#{url_base}/orders",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  def get_order(order_id)
    make_request do
      RestClient.get(
        "#{url_base}/orders/#{order_id}",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  def create_order(params)
    make_request do
      RestClient.post(
        "#{url_base}/orders",
        {order: params},
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  # def update_order(order_id, params)
  #   make_request do
  #     RestClient.put(
  #       "#{url_base}/orders/#{order_id}",
  #       {order: params},
  #       authorization: "Token #{@token}",
  #       accept: :json
  #     )
  #   end
  # end

  def delete_order(order_id)
    make_request do
      RestClient.delete(
        "#{url_base}/orders/#{order_id}",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  def get_products
    make_request do
      RestClient.get(
        "#{url_base}/products",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  def get_product(product_id)
    make_request do
      RestClient.get(
        "#{url_base}/products/#{product_id}",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  def get_group(group_id)
    make_request do
      RestClient.get(
        "#{url_base}/groups/#{group_id}",
        authorization: "Token #{@token}",
        accept: :json
      )
    end
  end

  private

  def make_request
    raw_response = yield
    puts "STATUS: #{raw_response.code}" if @debug

    return if raw_response.blank?

    response = JSON.parse(raw_response)

    puts JSON.pretty_generate(response) if @debug

    return response
  end

  def url_base
    if Rails.env.development?
      'http://localhost:3000'
    else
      'https://theforgeweb.com'
    end
  end
end
