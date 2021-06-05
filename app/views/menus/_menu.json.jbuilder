json.extract!(
  menu,
  :id,
  :name,
  :description,
  :data,
  :active,
  :archived,
  :created_at,
  :updated_at
)

if @deep
  json.groups do
    json.array! menu.groups.send(@scope) do |group|
      json.partial! 'groups/group', group: group
    end
  end

  json.products do
    # Only Products w/o a Group
    json.array! menu.products.send(@scope).where(group_id: nil) do |product|
      json.partial! 'products/product', product: product
    end
  end
end
