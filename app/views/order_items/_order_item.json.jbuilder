json.extract!(
  order_item,
  :id,
  :order_id,
  :amount,
  :created_at,
  :updated_at
)
product = order_item.product
json.menu_name product.menu.try(:name)
json.menu_id product.menu.try(:to_param)
json.group_name product.group.try(:name)
json.group_id product.group.try(:to_param)
json.product_name product.name
json.product_id product.to_param
