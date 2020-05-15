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
    return if @account.contact_sms.blank? || @account.contact_sms_after_unseen.blank?
    SmsNotificationJob.perform_async(@account.contact_sms, @order.new_order_sms_body)
  end

  def notify_email
    return if @account.contact_email.blank? || @account.contact_email_after_unseen.blank?
    OrdersMailer.new_order(@account.contact_email, @order.id).deliver_now
  end
end
