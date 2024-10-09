module Units
    class LunarRegolithProcessor < BaseUnit
    attr_accessor :energy_consumption, :output_resources
  
    def initialize
      super()                                        # Initialize as a BaseUnit
      @energy_consumption = 200                      # Energy required to operate
      @output_resources = { oxygen: 0 }              # Initialize output resources
      @regolith_input = 0                            # Initialize regolith input
    end
  
    def process_regolith(amount)
      if amount <= 0
        puts "Invalid amount of regolith."
        return
      end
  
      oxygen_produced = (amount / 2.0).floor        # For every 2 kg of regolith, produce 1 kg of oxygen
      @output_resources[:oxygen] += oxygen_produced  # Accumulate produced oxygen
      @regolith_input += amount                      # Track input regolith
      puts "Processed #{amount} kg of regolith. Produced #{oxygen_produced} kg of oxygen."
    end
  
    def activate(energy_available)
      # Check if there is enough excess energy to operate
      if energy_available >= @energy_consumption
        puts "Lunar Regolith Processor activated."
        # Process a certain amount of regolith
        # Here you can define how much regolith to process in a cycle
        process_regolith(4)  # For example, process 4 kg of regolith each activation
      else
        puts "Not enough energy to activate Lunar Regolith Processor."
      end
    end
  end
end
  