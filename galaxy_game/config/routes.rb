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

  # Admin namespace for comprehensive monitoring and control
  namespace :admin do
    root 'dashboard#index'        # Admin dashboard home
    get 'dashboard', to: 'dashboard#index'
    
    # AI Manager routes
    get 'ai_manager/missions', to: 'ai_manager#missions', as: 'ai_manager_missions'
    get 'ai_manager/missions/:id', to: 'ai_manager#show_mission', as: 'ai_manager_mission'
    post 'ai_manager/missions/:id/advance_phase', to: 'ai_manager#advance_phase', as: 'ai_manager_advance_phase'
    post 'ai_manager/missions/:id/reset', to: 'ai_manager#reset_mission', as: 'ai_manager_reset_mission'
    get 'ai_manager/planner', to: 'ai_manager#planner', as: 'ai_manager_planner'
    post 'ai_manager/export_plan', to: 'ai_manager#export_plan', as: 'ai_manager_export_plan'
    get 'ai_manager/decisions', to: 'ai_manager#decisions', as: 'ai_manager_decisions'
    get 'ai_manager/patterns', to: 'ai_manager#patterns', as: 'ai_manager_patterns'
    get 'ai_manager/performance', to: 'ai_manager#performance', as: 'ai_manager_performance'
    
    # Celestial Bodies routes
    resources :celestial_bodies, only: [:index] do
      member do
        get :monitor                 # Main monitoring interface
        get :sphere_data            # JSON: Real-time sphere data
        get :mission_log            # JSON: AI mission activity
        post :run_ai_test           # Trigger AI Manager test
      end
    end
    
    # Organizations routes
    get 'organizations', to: 'organizations#index', as: 'organizations'
    get 'organizations/:id/operations', to: 'organizations#operations', as: 'organization_operations'
    get 'organizations/contracts', to: 'organizations#contracts', as: 'organization_contracts'
    
    # Settlements routes
    get 'settlements', to: 'settlements#index', as: 'settlements'
    get 'settlements/:id/details', to: 'settlements#details', as: 'settlement_details'
    get 'settlements/construction_jobs', to: 'settlements#construction_jobs', as: 'settlement_construction_jobs'
    
    # Resources & Economy routes
    get 'resources', to: 'resources#index', as: 'resources'
    get 'resources/flows', to: 'resources#flows', as: 'resource_flows'
    get 'resources/supply_chains', to: 'resources#supply_chains', as: 'resource_supply_chains'
    get 'resources/market', to: 'resources#market', as: 'resource_market'
    
    # Simulation Control routes
    get 'simulation', to: 'simulation#index', as: 'simulation'
    post 'simulation/run/:id', to: 'simulation#run', as: 'simulation_run'
    post 'simulation/run_all', to: 'simulation#run_all', as: 'simulation_run_all'
    get 'simulation/spheres', to: 'simulation#spheres', as: 'simulation_spheres'
    get 'simulation/time_control', to: 'simulation#time_control', as: 'simulation_time_control'
    get 'simulation/testing', to: 'simulation#testing', as: 'simulation_testing'
  end
end