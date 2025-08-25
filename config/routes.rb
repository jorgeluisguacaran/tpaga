Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    resources :bancos, only: [:create, :show] do
      collection do
        get :cercano
      end
    end
    
    # Documentación de la API
    get 'documentacion', to: 'documentacion#index'
    get 'documentacion/estadisticas', to: 'documentacion#estadisticas'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
