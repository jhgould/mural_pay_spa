Rails.application.routes.draw do
  resources :accounts, only: [:new, :create, :show]
  resources :payouts, only: [:new, :create, :index] do 
    post :execute, on: :member
  end 

  root to: "dashboards#index"
end
