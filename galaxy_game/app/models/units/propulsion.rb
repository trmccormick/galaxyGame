# app/models/units/propulsion.rb
module Units
  # Prototype for propulsion units (engines, thrusters, etc.)
  # Aligns with operational_data JSON structure in data/json-data/operational_data/units/propulsion/
  class Propulsion < BaseUnit
    # --- Extension Plan ---
    # 1. All configuration/state is in operational_data (see JSON files)
    # 2. Add methods for:
    #    - Thrust control (throttle, modes)
    #    - Fuel consumption
    #    - Diagnostics (temperature, pressure)
    #    - Maintenance routines
    #    - Telemetry reporting

    # Returns current thrust (kN)
    def current_thrust
      operational_data.dig('propulsion_system', 'thrust_kn') || 0
    end

    # Returns current throttle percent (0.0 - 1.0)
    def throttle_percent
      operational_data.dig('propulsion_system', 'throttle_percent') || 0.0
    end

    # Sets throttle percent (clamped to allowed range)
    def set_throttle(percent)
      range = operational_data.dig('propulsion_system', 'throttle_range') || [0.0, 1.0]
      percent = [[percent, range[0]].max, range[1]].min
      operational_data['propulsion_system']['throttle_percent'] = percent
      save! if respond_to?(:save!)
    end

    # Returns current fuel type
    def fuel_type
      operational_data.dig('propulsion_system', 'fuel_type')
    end

    # Returns current operational mode (e.g., offline, standby, active, emergency)
    def current_mode
      operational_data.dig('operational_modes', 'current_mode') || 'offline'
    end

    # Switches to a new operational mode if available
    def switch_mode(mode_name)
      available = (operational_data.dig('operational_modes', 'available_modes') || []).map { |m| m['name'] }
      if available.include?(mode_name)
        operational_data['operational_modes']['current_mode'] = mode_name
        save! if respond_to?(:save!)
        true
      else
        false
      end
    end

    # Returns diagnostics hash (temperature, chamber pressure, etc.)
    def diagnostics
      operational_data['diagnostics'] || {}
    end

    # Returns maintenance info
    def maintenance_info
      operational_data['maintenance'] || {}
    end

    # Returns telemetry config
    def telemetry
      operational_data['telemetry'] || {}
    end

    # Add more methods as needed for simulation, resource consumption, etc.
    # --- End Extension Plan ---
  end
end
