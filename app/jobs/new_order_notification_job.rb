require 'twilio-ruby'

class NewOrderNotificationJob
  include Sidekiq::Worker

  def perform(order_id)
    @order = Order.find(order_id)
    @account = @order.account
    @menu = @order.menu

    notify_menu if @menu
    notify_account
  end

  private

  def broadcast_to_account
    ActionCable.server.broadcast(
      "orders_for_account_#{@account.id}",
      {
        action: 'new_order',
        data: {
          order_id: @order.id
        }
      }
    )
  end

  def notify_menu
    notify_menu_via_sms unless @menu.contact_sms.blank?
    unless @menu.contact_email.blank?
      OrdersMailer.new_order(@menu.contact_email, @order.id).deliver_now
    end
  end

  def notify_account
    broadcast_to_account

    unless @account.contact_sms.blank? || @account.contact_after.blank?
      notify_account_via_sms
    end

    unless @account.contact_email.blank?
      OrdersMailer.new_order(@account.contact_email, @order.id).deliver_now
    end
  end

  def notify_menu_via_sms
    SmsNotificationJob.perform_async(@menu.contact_sms, sms_body)
  end

  def notify_account_via_sms
    SmsNotificationJob.perform_in(
      @account.contact_after.minutes,
      @account.contact_sms,
      sms_body
    )
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
