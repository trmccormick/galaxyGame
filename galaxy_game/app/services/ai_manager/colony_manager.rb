module AIManager
  class ColonyManager
    attr_accessor :colonies, :player_colony, :ceres_profile

    def initialize
      @colonies = []
      @player_colony = nil
      @ceres_profile = load_ceres_profile
    end
    def load_ceres_profile
      path = File.join(Rails.root, 'data', 'json-data', 'ceres_mars_belt_operations_hub_profile_v1.json')
      JSON.parse(File.read(path)) if File.exist?(path)
    rescue => e
      Rails.logger.warn("Could not load Ceres profile: #{e.message}")
      nil
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



    def manage_npc_colonies
      @colonies.each do |npc_colony|
        npc_colony.perform_autonomous_tasks
      end
    end

    def manage_player_colony
      player_colony.perform_autonomous_tasks  # Perform tasks for the player's colony
      handle_player_trade  # Optional trade management for the player
    end

    public
    def handle_player_trade(high_transit_risk: false)
      # Use GCC Trading Platform logic for water exports (Ceres-specific)
      return unless @ceres_profile && player_colony
      if player_colony.respond_to?(:resources) && player_colony.resources.include?('water')
        roi = calculate_ceres_water_export_roi(player_colony)
        if high_transit_risk
          loss_factor = 0.08 # 8% loss for 2.8 AU transit
          roi = (roi * (1 - loss_factor)).round(2)
        end
        Rails.logger.info("Ceres Phase 1 Water Export ROI: #{roi}")
        roi
      else
        puts "#{player_colony.name} is negotiating trade."
      end
    end

    def calculate_ceres_water_export_roi(colony)
      # Example: Use profile data to calculate ROI for water exports
      # This is a stub; real logic would use @ceres_profile and colony state
      0.87
    end
  end
end
