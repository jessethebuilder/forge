json.extract!(
  group,
  :id,
  :name,
  :description,
  :order,
  :menu_id,
  :menu_name,
  :data,
  :active,
  :archived,
  :created_at,
  :updated_at
)

if @deep
  json.products do
    json.array! group.products.send(@scope) do |product|
      json.partial! 'products/product', product: product
    end
  end
end
