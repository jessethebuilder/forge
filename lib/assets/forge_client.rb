# load 'lib/assets/forge_client.rb'

require 'rest-client'

class ForgeClient
  def initialize(token)
    @token = token
  end

  def get_orders
    RestClient.get(
      "#{url_base}/orders",
      authorization: "Token #{@token}",
      accept: :json
    )
  end

  def get_order(order_id)
    RestClient.get(
      "#{url_base}/orders/#{order_id}",
      authorization: "Token #{@token}",
      accept: :json
    )
  end

  private

  def url_base
    if Rails.env.development?
      'http://localhost:3000'
    else
      'https://theforgeweb.com'
    end
  end
end
