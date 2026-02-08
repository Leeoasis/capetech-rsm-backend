Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post :login
        post :refresh
        post :logout
        get :me
      end

      resources :customers do
        member do
          get :devices
          get :repair_tickets
        end
      end

      resources :devices

      resources :repair_tickets do
        member do
          post :update_status
          get :timeline
          get :payments
        end
        collection do
          get :kanban
        end
      end

      resources :payments, only: [:index, :show, :create]
      resources :activity_logs, only: [:index, :show]
      resources :users, only: [:index, :show, :create, :update]

      namespace :pos do
        post :create_invoice
        post :process_payment
        get 'receipt/:id', action: :receipt
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
