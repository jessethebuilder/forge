module ProductsHelper
  def product_back_path(product)
    return group_path(product.group) if product.group
    return products_path
  end
end
