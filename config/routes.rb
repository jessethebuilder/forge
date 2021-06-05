Rails.application.routes.draw do
  resources :orders, except: [:new, :edit, :update] do
    member do
      resources :transactions, only: [:create]
    end
  end

  resources :menus, except: [:new, :edit]
  resources :products, except: [:new, :edit]
  resources :groups, except: [:new, :edit]
  resources :customers, except: [:new, :edit]

  resource :account

  root to: 'account#new'
end
