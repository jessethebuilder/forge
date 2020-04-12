def dual_routes_for(*resource_list)
  resource_list.each do |resource_name|
    resources resource_name, only: [:edit, :new], constraints: lambda { |req| req.format == :html }
    resources resource_name, except: [:edit, :new]
  end
end

Rails.application.routes.draw do
  dual_routes_for(
    :products,
    :groups,
    :menus,
    :customers,
    :orders
  )

  resources :order_items, only: [] do
    member do
      # Future home of a refund endopoint
    end
  end
end
