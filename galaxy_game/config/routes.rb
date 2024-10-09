require 'sidekiq/web'

Rails.application.routes.draw do
  # Root route
  root 'simulation#index'

  get 'materials/:name', to: 'materials#show'

  # Routes for celestial bodies with all CRUD actions
  resources :celestial_bodies
  resources :stars
  resources :terrestrial_planets
  # resources :

  # Additional routes for simulations or other resources
  post 'run_simulation', to: 'simulation#run_simulation'
end
