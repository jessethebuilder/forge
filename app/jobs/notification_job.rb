class NotificationJob # TODO spec!
  include Sidekiq::Worker
  include SmsHelper

  def perform(order_notification_id)
    @order_notification = Notification.find(order_notification_id)
    @message = @order_notification.message
    @order = @order_notification.order
    @account = @order.account
    @menu = @order.menu
    @customer = @order.customer

    send(@order_notification.notification_type)
  end

  private

  def new_order
    notify_account_of_new_order
    notify_menu_of_new_order if @menu
    # notify_customer_of_new_order if @customer
  end

  def update_customer
    if @customer.email.exists?
      OrdersMailer.notify_customer_of_new_order(@order.id, @message).deliver_now
    end

    if @customer.phone.exists?
      message = ["You have placed your order with #{@account.name}\n\n"]
      message << new_order_sms_body(@order)
      message << "\n\n#{@message}" if @message

      SmsNotificationJob.perform_async(@customer.phone, message.join(''))
    end
  end

  def notify_customer_of_new_order
    if @customer.email.exists?
      OrdersMailer.notify_customer_of_new_order(@order.id, @message).deliver_now
    end

    if @customer.phone.exists?
      message = ["You have placed your order with #{@account.name}\n\n"]
      message << new_order_sms_body(@order)
      message << "\n\n#{@message}" if @message

      SmsNotificationJob.perform_async(@customer.phone, message.join(''))
    end
  end

  def notify_customer_of_new_order
    unless @customer.email.blank?
      OrdersMailer.new_order_for_customer(@order.id, @message).deliver_now
    end

    if @cuostomer.can_sms? && @customer.phone.exists?
      message = new_order_sms_body(@order)
      message += "\n\n#{@message}" if @message
      SmsNotificationJob.perform_async(@customer.phone, message)
    end
  end

  def notify_menu_of_new_order
    unless @menu.email.blank?
      OrdersMailer.new_order_for_account(@menu.email, @order.id).deliver_now
    end

    unless @menu.sms.blank?
      SmsNotificationJob.perform_async(@menu.sms, new_order_sms_body(@order))
    end
  end

  def notify_account_of_new_order
    OrdersMailer.new_order_for_account(@account.email, @order.id).deliver_now

    unless @account.sms.blank?
      SmsNotificationJob.perform_async(@account.sms, new_order_sms_body(@order))
    end
  end
end
