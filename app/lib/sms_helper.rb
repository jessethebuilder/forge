module SmsHelper
  def new_order_sms_body(order)
    menu = order.menu

    text = ["---- New Order ----"]
    text << "for #{menu.name}" if menu
    text << "Created: #{order.created_at}"
    text << "\n-- ITEMS --\n"
    order.order_items.each_with_index do |order_item, i|
      product = order_item.product
      group = product.group
      text << "Group: #{group.name}" unless group.blank?
      text << "Product: #{product.name}"
      text << "NOTE: #{order_item.note}" unless order_item.note.blank?
      text << "--------\n"
    end

    return text.join("\n")
  end
end
