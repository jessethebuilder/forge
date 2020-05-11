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
    SmsNotificationJob.perform_async(@menu.contact_sms, sms_body)    
    unless @menu.contact_email.blank?
      OrdersMailer.new_order(@menu.contact_email, @order.id).deliver_now
    end
  end

  def notify_account
    # broadcast_to_account

    unless @account.contact_sms.blank? || @account.contact_after.blank?
      # This job includes a delay, so @accounts are only notified of a new Order
      # after a certain number of minutes, as defined @account.contact_after.
      AccountOrderNotificationJob.perform_in(
        @account.contact_after.minutes,
        @order.id,
        sms_body
      )
    end

    unless @account.contact_email.blank?
      OrdersMailer.new_order(@account.contact_email, @order.id).deliver_now
    end
  end

  def sms_body
    text = ["---- New Order ----"]
    text << "for #{@menu.name}" if @menu
    text << "Created: #{@order.created_at}"
    text << "\n-- ITEMS --\n"
    @order.order_items.each_with_index do |item, i|
      product = item.product
      group = product.group
      text << "Group: #{group.name}" unless group.blank?
      text << "Product: #{product.name}"
      text << "NOTE: #{item.note}" unless item.note.blank?
      text << "--------\n"
    end

    text.join("\n")
  end
end
