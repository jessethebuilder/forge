class AccountOrderNotificationJob
  include Sidekiq::Worker

  def perform(order_id, sms_body)
    @order = Order.find(order_id)
    @account = @order.account
    # This should only be sent if the Order is not looked at. Probably beongs in
    # a seperate job: AccountOrderNotificationJob maybe.
    SmsNotificationJob.perform_async(@account.contact_sms, sms_body)
  end
end
