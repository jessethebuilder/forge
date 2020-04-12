json.id product.to_param

json.extract!(
  product,
  :name,
  :description,
  :order,
  :price,
  :data,
  :reference,
  :active,
  :created_at,
  :updated_at
)

json.menu_id product.menu.to_param
json.group_id product.group.to_param
