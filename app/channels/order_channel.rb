class OrderChannel < ApplicationCable::Channel
  def subscribed
    stream_from "orders_for_account_#{params[:account_id]}"
  end

  def receive(data)
    puts '.....................>'
    puts '.....................>'
    puts '.....................>'
    puts '.....................>'
    puts '.....................>'
    puts '.....................>'
    puts '.....................>'
  end
end
