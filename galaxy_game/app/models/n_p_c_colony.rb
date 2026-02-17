class NPCColony < Settlement
    attr_accessor :ai_manager, :trade_routes
  
    def initialize(name, population_capacity, initial_resources)
      super(name, population_capacity, initial_resources)
      @ai_manager = AIManager::ColonyManager.new  # Each NPC colony can have its own AI manager
      @trade_routes = []  # Potential routes for trading with other colonies
    end
  
    def perform_autonomous_tasks
      @ai_manager.manage_colonies  # Use the colony manager for resource management
      explore_and_expand  # Optional function for NPC colonies
    end
  
    def explore_and_expand
      # Logic for NPC colonies to explore new areas or expand their population
      puts "#{name} is exploring for new resources or potential expansion."
    end
  
    def establish_trade_route(other_colony)
      @trade_routes << other_colony
      puts "#{name} has established a trade route with #{other_colony.name}."
    end
  
    def negotiate_trade
      # Simple logic to negotiate trades with player colonies or other NPCs
      puts "#{name} is negotiating trade with nearby colonies."
    end
  end
  