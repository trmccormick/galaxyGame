# app/models/units/extractor.rb
module Units
  # Prototype for extractor units (mining, volatiles extraction, thermal extraction, etc.)
  # Aligns with operational_data JSON structure in data/json-data/operational_data/units/production/extractors/
  class Extractor < BaseUnit
    # --- Extension Plan ---
    # 1. All configuration/state is in operational_data (see JSON files)
    # 2. Add methods for:
    #    - Extraction control (start/stop, rates)
    #    - Resource output
    #    - Environmental requirements
    #    - Maintenance routines
    #    - Telemetry reporting

    # Returns current extraction rate (e.g., kg/hr)
    def extraction_rate
      operational_data.dig('extraction', 'rate_kg_hr') || 0
    end

    # Returns the type of resource being extracted
    def resource_type
      operational_data.dig('extraction', 'resource_type')
    end

    # Returns true if extractor is currently active
    def active?
      operational_data.dig('operational_status', 'status') == 'active'
    end

    # Starts extraction (sets status to active)
    def start_extraction
      operational_data['operational_status']['status'] = 'active'
      save! if respond_to?(:save!)
    end

    # Stops extraction (sets status to offline)
    def stop_extraction
      operational_data['operational_status']['status'] = 'offline'
      save! if respond_to?(:save!)
    end

    # Returns maintenance info
    def maintenance_info
      operational_data['maintenance'] || {}
    end

    # Returns telemetry config
    def telemetry
      operational_data['telemetry'] || {}
    end

    # Add more methods as needed for simulation, resource output, etc.
    # --- End Extension Plan ---
  end
end
