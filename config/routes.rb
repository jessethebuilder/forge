Rails.application.routes.draw do
  resources :products, except: [:new, :edit] do
    collection do
      get :all_inactive
    end
  end

  resources :groups, except: [:new, :edit]
  resources :menus, except: [:new, :edit]
  resources :customers, except: [:new, :edit]
  resources :orders, except: [:new, :edit]

  resources :order_items, only: [] do
    member do
      # Future home of a refund endopoint
    end
  end

  resource :account

  root to: 'account#new'
end
