# app/models/game.rb
class Game
    attr_accessor :speed_setting, :running, :elapsed_time
  
    SPEEDS = {
      fast: 0.1,    # years per second
      moderate: 0.05, # years per second
      slow: 0.01,   # years per second
      pause: 0      # no time progression
    }.freeze
  
    def initialize
      @speed_setting = :moderate
      @running = false
      @elapsed_time = 0.0
    end
  
    # Start the game simulation
    def start
      @running = true
      run_simulation
    end
  
    # Pause the game simulation
    def pause
      @running = false
    end
  
    # Change the speed setting of the simulation
    def change_speed(new_speed)
      if SPEEDS.key?(new_speed)
        @speed_setting = new_speed
      else
        raise ArgumentError, "Invalid speed setting"
      end
    end
  
    # Main simulation loop
    def run_simulation
      while @running
        sleep(1)  # Control the update frequency (e.g., every second)
        update_game_state
      end
    end
  
    # Update the game state based on the elapsed time
    def update_game_state
      @elapsed_time += SPEEDS[@speed_setting]
  
      # Process settlements and units
      process_settlements
      process_units
  
      puts "Elapsed Time: #{@elapsed_time.round(2)} years"
    end
  
    private
  
    # Process each settlement and check resource needs
    def process_settlements
        Settlement.all.each do |settlement|
        needs = settlement.resource_needs
        if settlement.sufficient_resources?
            puts "#{settlement.name} has sufficient resources."
        else
            puts "#{settlement.name} is running low on resources!"
        end
        end
    end
  
    # Process units within settlements
    def process_units
        Unit.all.each do |unit|
            unit.operate  # Call the operate method to simulate daily operations
        end
    end
  end
  
  