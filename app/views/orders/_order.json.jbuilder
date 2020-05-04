json.id order.id

json.items do
  json.array!(
    order.order_items,
    partial: "order_items/order_item",
    as: :order_item
  )
end

json.extract!(
  order,
  :total,
  :subtotal,
  :tax,
  :tip,
  :data,
  :reference,
  :created_at,
  :updated_at,
  :customer_id,
  :menu_id
)
