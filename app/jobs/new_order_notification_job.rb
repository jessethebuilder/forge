class NewOrderNotificationJob
  include Sidekiq::Worker

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
      SmsNotificationJob.perform_async(@menu.sms, @order.new_order_sms_body)
    end
  end

  def notify_account
    OrdersMailer.new_order(@account.email, @order.id).deliver_now

    unless @account.sms.blank?
      SmsNotificationJob.perform_async(@account.sms, @order.new_order_sms_body)
    end
  end
end
