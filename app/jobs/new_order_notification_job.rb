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
    SmsNotificationJob.perform_async(@menu.contact_sms, @order.new_order_sms_body)
    unless @menu.contact_email.blank?
      OrdersMailer.new_order(@menu.contact_email, @order.id).deliver_now
    end
  end

  def notify_account
    unless @account.contact_sms_after_unseen.blank?
      AccountOrderNotificationJob.perform_in(
        @account.contact_sms_after_unseen.minutes,
        :sms,
        @order.id
      )
    end

    unless @account.contact_email_after_unseen.blank?
      AccountOrderNotificationJob.perform_in(
        @account.contact_email_after_unseen.minutes,
        :email,
        @order.id
      )
    end
  end
end
