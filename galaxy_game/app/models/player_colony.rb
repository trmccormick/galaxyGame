class PlayerColony < Settlement
    attr_accessor :auto_manage
  
    def initialize(name, population_capacity, initial_resources, auto_manage = true)
      super(name, population_capacity, initial_resources)
      @auto_manage = auto_manage  # Determines if AI should manage this colony
    end
  
    def perform_autonomous_tasks
      # Logic for the player to perform tasks manually if not automated
      puts "#{name} is performing autonomous tasks."
    end
  end