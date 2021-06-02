Rails.application.routes.draw do
  resources :orders, except: [:new, :edit, :update]

  resources :menus, except: [:new, :edit]
  resources :products, except: [:new, :edit]
  resources :groups, except: [:new, :edit]
  resources :customers, except: [:new, :edit]
  resources :transactions, except: [:new, :edit, :update, :destroy, :index]

  resource :account

  root to: 'account#new'
end
