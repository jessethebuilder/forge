json.id order.id

json.order_items do
  json.array!(
    order.order_items,
    partial: "order_items/order_item",
    as: :order_item
  )
end

json.transactions do
  json.array!(
    order.transactions,
    partial: "transactions/transaction",
    as: :transaction
  )
end

json.extract!(
  order,
  :total,
  :subtotal,
  :tax,
  :tip,
  :data,
  :customer_id,
  :menu_id,
  :menu_name,
  :note,
  :seen_at,
  :delivered_at,
  :created_at,
  :updated_at
)
