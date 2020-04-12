json.id product.to_param
json.account_id product.account.to_param
json.menu_id product.menu.to_param
json.group_id product.group.to_param

json.extract!(
  product,
  :name,
  :description,
  :order,
  :price,
  :data,
  :active,
  :created_at,
  :updated_at
)
