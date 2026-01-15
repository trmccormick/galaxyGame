require 'sidekiq/web'

Rails.application.routes.draw do
  # Root route
  root 'game#index'

  # Simulation routes
  get 'simulation', to: 'simulation#index'
  post 'simulation/run/:id', to: 'simulation#run', as: 'run_simulation'
  post 'simulation/run_all', to: 'simulation#run_all', as: 'run_all_simulation'

  # Game routes
  get 'game', to: 'game#index'  
  get 'game/simulation/:id', to: 'game#simulation', as: 'game_simulation'  # Add this line
  get 'game/celestial_body/:id', to: 'game#celestial_body_detail', as: 'celestial_body_detail'
  get 'game/time', to: 'game#get_time'
  post 'game/toggle_simulation', to: 'game#toggle_simulation'
  post 'game/fast_forward', to: 'game#fast_forward'

  # Game time control routes
  post 'game/toggle_running', to: 'game#toggle_running'
  post 'game/set_speed', to: 'game#set_speed'
  post 'game/jump_time', to: 'game#jump_time'
  get 'game/state', to: 'game#state'

  get 'materials/:name', to: 'materials#show'

  # Routes for celestial bodies with all CRUD actions
  resources :solar_systems, only: [:show, :index]
  resources :celestial_bodies do
    member do
      get :map                    # Planet map viewer
      get :geological_features    # API: Load geological features JSON
    end
  end
  resources :stars
  resources :terrestrial_planets

  # Add resourceful route for transactions
  resources :transactions, only: [:create]

  # Additional routes for simulations or other resources
  post 'run_simulation', to: 'simulation#run_simulation'

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => '/sidekiq'

  # Admin namespace for testing and monitoring
  namespace :admin do
    root 'dashboard#index'        # Admin dashboard home
    get 'dashboard', to: 'dashboard#index'
    
    resources :celestial_bodies, only: [] do
      member do
        get :monitor                 # Main monitoring interface
        get :sphere_data            # JSON: Real-time sphere data
        get :mission_log            # JSON: AI mission activity
        post :run_ai_test           # Trigger AI Manager test
      end
    end
  end
end