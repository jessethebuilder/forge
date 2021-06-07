class OrderNotificationJob # TODO spec!
  include Sidekiq::Worker
  include SmsHelper

  def perform(order_notification_id)
    @order_notification = OrderNotification.find(order_notification_id)

    send("perform_#{}")
  end

  private
end
