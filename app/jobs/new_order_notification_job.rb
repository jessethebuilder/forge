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
    unless @account.sms_after_unseen.blank? || @account.sms.blank?
      AccountOrderNotificationJob.perform_in(
        @account.sms_after_unseen.seconds,
        :sms,
        @order.id
      )
    end

    unless @account.email_after_unseen.blank? || @account.email.blank?
      AccountOrderNotificationJob.perform_in(
        @account.email_after_unseen.seconds,
        :email,
        @order.id
      )
    end
  end
end
