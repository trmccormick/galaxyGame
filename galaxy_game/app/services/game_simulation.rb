# ==============================================================================
# GAME CLASS - Orchestrates time advancement and simulations
# ==============================================================================

# ==============================================================================
# OPTION B: Use a Game class (cleaner separation of concerns)
# ==============================================================================
# This is the pattern from your game.rb.old, modernized
# ==============================================================================

class GameSimulation
  attr_reader :game_state
  
  def initialize(game_state:)
    @game_state = game_state
  end
  
  def advance_by_days(days)
    return if days <= 0
    
    puts "===================="
    puts "Advancing game by #{days} days"
    puts "Current: Year #{@game_state.year}, Day #{@game_state.day.round(1)}"
    puts "===================="
    
    # Update the game state time
    update_game_time(days)
    
    # Process all game systems
    process_celestial_bodies(days)
    # Future: process_settlements(days)
    # Future: process_units(days)
    # Future: process_economy(days)
    
    puts "New time: Year #{@game_state.year}, Day #{@game_state.day.round(1)}"
  end
  
  private
  
  def update_game_time(days)
    @game_state.day += days
    
    while @game_state.day >= 365
      @game_state.year += 1
      @game_state.day -= 365
    end
    
    @game_state.last_updated_at = Time.current
    @game_state.save!
  end
  
  def process_celestial_bodies(days_elapsed)
    CelestialBodies::CelestialBody.find_each do |body|
      next unless body.should_simulate?
      
      begin
        puts "  Simulating: #{body.name}"
        simulate_body(body, days_elapsed)
        body.update_column(:last_simulated_at, Time.current)
      rescue => e
        Rails.logger.error "Error simulating #{body.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      end
    end
  end
  
  def simulate_body(body, days_elapsed)
    simulator = TerraSim::Simulator.new(body)
    simulator.calc_current(days_elapsed)
  end
  
  # Future expansion points:
  # def process_settlements(days_elapsed)
  #   Settlement.find_each do |settlement|
  #     settlement.consume_resources(days_elapsed)
  #     settlement.produce_resources(days_elapsed)
  #   end
  # end
  #
  # def process_units(days_elapsed)
  #   Unit.find_each do |unit|
  #     unit.operate(days_elapsed)
  #   end
  # end
end