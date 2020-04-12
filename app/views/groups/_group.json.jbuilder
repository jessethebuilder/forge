json.id group.to_param

json.extract!(
  group,
  :name,
  :description,
  :order,
  :data,
  :reference,
  :active,
  :created_at,
  :updated_at
)

json.menu_id group.menu.to_param
