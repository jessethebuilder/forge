json.id customer.to_param

json.extract!(
  customer,
  :email,
  :name,
  :phone,
  :data,
  :reference,
  :created_at,
  :updated_at
)
