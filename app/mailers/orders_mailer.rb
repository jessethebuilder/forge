class OrdersMailer < ApplicationMailer
  def new_order_for_account(to, order_id)
    @order = Order.find(order_id)
    @menu = @order.menu
    @account = @order.account
    mail(to: to, subject: "New Order from The Forge")
  end

  def new_order_for_customer(order_id, message)
    @message = message
    mail(to: to, subject: "New Order from #{@account.name}")
  end
end
