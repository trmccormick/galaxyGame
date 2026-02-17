# WormholeManager Service
# Monitors wormhole mass, triggers shift, integrates EM harvesting, generates lore logs

module AIManager
  class WormholeManager
    attr_reader :wormholes, :sol_anchor_id

    # Jupiter-Anchor principle: Sol-side is shift_resistant
    def initialize(wormholes, sol_anchor_id)
      @wormholes = wormholes
      @sol_anchor_id = sol_anchor_id
    end

    def monitor_and_trigger_shift
      wormholes.each do |wh|
        if wh[:id] == sol_anchor_id
          wh[:shift_resistant] = true
          next # Sol anchor never shifts, but mass is tracked
        end
        if wh[:current_mass] >= wh[:instability_threshold]
          execute_shift_discharge(wh)
        else
          generate_lore_log(wh)
        end
      end
    end

    def execute_shift_discharge(wormhole)
      # Mark previous system as orphaned
      wormhole[:status] = 'orphaned'
      # Update destination_id to new star system
      wormhole[:destination_id] = select_new_destination
      # EM Bloom harvesting integration
      harvest_em_bloom(wormhole)
      create_hot_start_resource_pool(wormhole)
    end

    def select_new_destination
      # TODO: Load from aol-732356.json or generate procedural seed
      "random_star_system_#{rand(100000..999999)}"
    end

    def harvest_em_bloom(wormhole)
      # Integrate with NaturalWormholeAnchor (WS) blueprint
      wormhole[:em_bloom_harvested] = true
    end

    def create_hot_start_resource_pool(wormhole)
      wormhole[:hot_start_resource_pool] = true
    end

    def generate_lore_log(wormhole)
      if wormhole[:current_mass] > 0.9 * wormhole[:instability_threshold]
        log = "Pilot Report: EM Bloom increasing near wormhole #{wormhole[:id]} as mass approaches critical threshold."
        wormhole[:lore_log] ||= []
        wormhole[:lore_log] << log
      end
    end
  end
end
