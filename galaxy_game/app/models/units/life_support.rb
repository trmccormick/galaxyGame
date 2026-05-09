# app/models/units/life_support.rb
module Units
  # LifeSupport units handle atmosphere, air, water, and critical crew resources.
  # Only include logic unique to life support here. Use concerns for shared logic.
  class LifeSupport < BaseUnit
    # --- Extension Plan ---
    # 1. Include concerns for shared logic (energy, resource management, etc.)
    #    include EnergyManagement
    #    include ResourceProcessing

    # 2. Example methods for alignment with operational_data JSON:

    # Returns enabled processing types (e.g., atmospheric, geosphere)
    def processing_capabilities
      operational_data['processing_capabilities'] || {}
    end

    # Returns input resources (array of hashes)
    def input_resources
      operational_data['input_resources'] || []
    end

    # Returns output resources (array of hashes)
    def output_resources
      operational_data['output_resources'] || []
    end

    # Returns byproducts (array of hashes)
    def byproducts
      operational_data['byproducts'] || []
    end

    # Returns current operational mode
    def current_mode
      operational_data.dig('operational_modes', 'current_mode') || 'standby'
    end

    # Switches to a new operational mode if available
    def switch_mode(mode_name)
      available = (operational_data.dig('operational_modes', 'available_modes') || [])
      if available.include?(mode_name)
        operational_data['operational_modes']['current_mode'] = mode_name
        save! if respond_to?(:save!)
        true
      else
        false
      end
    end

    # Returns diagnostics hash
    def diagnostics
      operational_data['diagnostics'] || {}
    end

    # Returns telemetry config
    def telemetry
      operational_data['telemetry'] || {}
    end

    # Returns habitat systems info (if present)
    def habitat_systems
      operational_data['habitat_systems'] || {}
    end

    # Returns maintenance info
    def maintenance_info
      operational_data['maintenance'] || {}
    end

    # --- End Extension Plan ---
  end
end
