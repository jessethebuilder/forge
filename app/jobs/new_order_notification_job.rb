class NewOrderNotificationJob
  include Sidekiq::Worker
  include SmsHelper

  def perform(order_id)
    @order = Order.find(order_id)
    @account = @order.account
    @menu = @order.menu

    notify_account
    notify_menu if @menu
  end

  private

  def notify_menu
    unless @menu.email.blank?
      OrdersMailer.new_order(@menu.email, @order.id).deliver_now
    end

    unless @menu.sms.blank?
      SmsNotificationJob.perform_async(@menu.sms, new_order_sms_body(@order))
    end
  end

  def notify_account
    OrdersMailer.new_order(@account.email, @order.id).deliver_now

    unless @account.sms.blank?
      SmsNotificationJob.perform_async(@account.sms, new_order_sms_body(@order))
    end
  end
end
