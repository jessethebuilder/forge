class OrderChannel < ApplicationCable::Channel
  def subscribed
    stream_from "orders_for_account_#{params[:account_id]}"
  end
end
