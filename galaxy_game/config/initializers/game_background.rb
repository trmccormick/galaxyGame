# In config/initializers/game_background.rb
Rails.application.config.after_initialize do
  unless Rails.env.test? || defined?(Rails::Console)
    # Start the game simulation job
    GameSimulationJob.perform_in(10.seconds)
  end
end