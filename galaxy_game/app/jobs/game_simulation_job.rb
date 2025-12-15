# app/jobs/game_simulation_job.rb

# ==============================================================================
# MODIFIED: GameSimulationJob - Better integration
# ==============================================================================

class GameSimulationJob
  include Sidekiq::Job
  queue_as :simulation

  def perform
    game_state = GameState.first_or_create

    # Only run if the game is running
    return unless game_state.running

    # Calculate elapsed real time since last update
    elapsed_seconds = Time.current - game_state.last_updated_at
    days_to_simulate = (elapsed_seconds / game_state.seconds_per_game_day).to_i

    return if days_to_simulate <= 0

    # Run the simulation
    game = Game.new(game_state: game_state)
    game.advance_by_days(days_to_simulate)

    # OPTIONAL: Simulate idle bodies occasionally (less frequently)
    # This is for bodies that aren't in active play but should still evolve
    if rand < 0.1 # 10% chance each tick (reduced from 20%)
      body = find_random_idle_body
      if body
        simulator = TerraSim::Simulator.new(body)
        # Idle bodies get minimal simulation (1 day)
        simulator.calc_current(1)
        body.update_column(:last_simulated_at, Time.current)
      end
    end

    # Schedule the next run
    GameSimulationJob.perform_in(1.minute)
  end
  
  private
  
  def find_random_idle_body
    cutoff = Time.current - 1.hour
    CelestialBodies::CelestialBody
      .where("last_simulated_at IS NULL OR last_simulated_at < ?", cutoff)
      .where.not(id: active_body_ids)
      .sample
  end
  
  def active_body_ids
    # Override this with logic for which bodies are currently in active play
    # For now, just an empty array (all bodies are potentially idle)
    []
  end
end