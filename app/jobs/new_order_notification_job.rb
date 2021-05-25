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
    unless @menu.sms.blank?
      SmsNotificationJob.perform_async(@menu.sms, @order.new_order_sms_body)
    end

    unless @menu.email.blank?
      OrdersMailer.new_order(@menu.email, @order.id).deliver_now
    end
  end

  def notify_account
    unless @account.sms.blank?
      AccountOrderNotificationJob.perform_async(:sms, @order.id)
    end

    unless @account.email.blank?
      AccountOrderNotificationJob.perform_async(:email, @order.id)
    end
  end
end
