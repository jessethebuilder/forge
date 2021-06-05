module RequestSpecHelper
  def test_api_headers
    {
      'ACCEPT' => 'application/json',
      'Authorization' => "Token token=#{@credential.token}"
    }
  end

  def menu_response(menu, deep: false, updates: {})
    base = {
      id: menu.id,
      name: menu.name,
      description: menu.description,
      data: menu.data,
      active: menu.active,
      archived: menu.archived,
      created_at: menu.created_at,
      updated_at: menu.updated_at
    }

    if deep
      if deep
        base[:groups] =  menu.groups.all.map{ |group| group_response(group, deep: true)}
        base[:products] = menu.products.map{ |product| product_response(product)}
      end
    end

    updates.each{ |k, v| base[k] = v }

    return base
  end


  def group_response(group, deep: false, updates: {})
    base = {
      id: group.id,
      name: group.name,
      description: group.description,
      order: group.order,
      menu_id: group.menu_id,
      menu_name: group.menu_name,
      data: group.data,
      active: group.active,
      archived: group.archived,
      created_at: group.created_at,
      updated_at: group.updated_at
    }

    if deep
      base[:products] = group.products.all.map{ |product| product_response(product)}
    end

    updates.each{ |k, v| base[k] = v }

    return base
  end

  def product_response(product, updates: [])
    base = {
      id: product.id,
      name: product.name,
      description: product.description,
      order: product.order,
      price: product.price,
      group_id: product.group_id,
      group_name: product.group_name,
      menu_id: product.menu_id,
      menu_name: product.menu_name,
      data: product.data,
      active: product.active,
      created_at: product.created_at,
      updated_at: product.updated_at,
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end

  def order_response(order, updates: {})
    base = {
      id: order.id,
      order_items: order.order_items,
      transactions: order.transactions,
      total: order.total,
      subtotal: order.subtotal,
      tax: order.tax,
      tip: order.tip,
      data: order.data,
      customer_id: order.customer&.id,
      menu_id: order.menu&.id,
      menu_name: order.menu_name,
      note: order.note,
      seen_at: order.seen_at,
      delivered_at: order.delivered_at,
      created_at: order.created_at,
      updated_at: order.updated_at
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end

  def order_item_response(order_item, updates: {})
    base = {
      id: order_item.id,
      amount: order_item.amount,
      note: order_item.note,
      data: order_item.data,
      order_id: order_item.order_id,
      product_id: order_item.product_id,
      product_name: order_item.product_name,
      group_id: order_item.group_id,
      group_name: order_item.group_name,
      menu_id: order_item.menu_id,
      menu_name: order_item.menu_name,
      created_at: order_item.created_at,
      updated_at: order_item.updated_at
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end

  def transaction_response(transaction, updates: {})
    base = {
      id: transaction.id,
      amount: transaction.amount,
      transaction_type: transaction.transaction_type,
      order_id: transaction.order_id,
      stripe_id: transaction.stripe_id,
      created_at: transaction.created_at,
      updated_at: transaction.updated_at
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end

  def customer_response(customer, updates: {})
    base = {
      id: customer.id,
      email: customer.email,
      name: customer.name,
      phone: customer.phone,
      data: customer.data,
      stripe_id: customer.stripe_id,
      created_at: customer.created_at,
      updated_at: customer.updated_at
    }

    updates.each{ |k, v| base[k] = v }

    return base
  end
end
