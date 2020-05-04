class OrdersMailer < ApplicationMailer
  def new_order(to, order_id)
    @order = Order.find(order_id)
    @menu = @order.menu
    @account = @order.account
    mail(to: to, subject: "New Order from The Forge")
  end
end
