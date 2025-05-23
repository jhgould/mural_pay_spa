Rails.application.routes.draw do
  resources :accounts, only: [:new, :create, :show]
  resources :payouts, only: [:new, :create]

  root to: "dashboards#index"
end
