class ColonyManager
    attr_accessor :colonies, :player_colony

    def initialize
      @colonies = []  # Store all NPC colonies
      @player_colony = nil  # Reference to the player's colony
    end

    def add_colony(colony)
      @colonies << colony
    end

    def set_player_colony(colony)
      @player_colony = colony
    end

    def manage_colonies
      manage_npc_colonies
      manage_player_colony if player_colony && player_colony.auto_manage
    end

    private

    def manage_npc_colonies
      @colonies.each do |npc_colony|
        npc_colony.perform_autonomous_tasks
      end
    end

    def manage_player_colony
      player_colony.perform_autonomous_tasks  # Perform tasks for the player's colony
      handle_player_trade  # Optional trade management for the player
    end

    def handle_player_trade
      # Logic for managing trades based on the player's colony status and needs
      puts "#{player_colony.name} is negotiating trade."
    end
  end
  