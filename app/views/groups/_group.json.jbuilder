json.extract!(
  group,
  :id,
  :name,
  :description,
  :order,
  :data,
  :active,
  :created_at,
  :updated_at,
  :menu_id
)

if @deep
  json.products do
    json.array! group.products.send(@scope) do |product|
      json.partial! 'products/product', product: product
    end
  end
end
