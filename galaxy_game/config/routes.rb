Rails.application.routes.draw do
  #root 'game#index'

  resources :celestial_bodies, only: [:index, :show, :edit, :update]
  
  # Add other routes for simulations or other resources if needed
  # For example:
  # post 'simulations/run', to: 'simulations#run'
  # get 'simulations/status', to: 'simulations#status'
  # get 'simulations/show_all', to: 'simulations#show_all'

  root 'simulation#index'
  post 'run_simulation', to: 'simulation#run_simulation'
end
