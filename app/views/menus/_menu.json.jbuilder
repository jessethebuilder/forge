json.id menu.to_param

json.extract!(
  menu,
  :name,
  :description,
  :data,
  :reference,
  :active,
  :created_at,
  :updated_at
)
