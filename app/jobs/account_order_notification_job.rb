class AccountOrderNotificationJob
  include Sidekiq::Worker

  def perform(action, order_id, params = {})
    @order = Order.find(order_id)

    return if @order.seen?

    @account = @order.account
    @param = params

    send("notify_#{action}")
  end

  private

  def notify_sms
    return if @account.sms.blank? || @account.sms_after_unseen.blank?
    SmsNotificationJob.perform_async(@account.sms, @order.new_order_sms_body)
  end

  def notify_email
    return if @account.email.blank? || @account.email_after_unseen.blank?
    OrdersMailer.new_order(@account.email, @order.id).deliver_now
  end
end
