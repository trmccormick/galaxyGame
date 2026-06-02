# frozen_string_literal: true

module Logistics
  class IsruCapabilityManager < BaseService
    
    # List of equipment unit names that provide Oxygen extraction capabilities
    O2_EQUIPMENT_NAMES = %w[
      planetary_volatiles_extractor_mk1
      planetary_volatiles_extractor_mk2
      co2_oxygen_production_unit
      thermal_extraction_unit
      lunar_oxygen_extractor
    ].freeze

    # List of equipment unit names that provide Power generation capabilities
    POWER_EQUIPMENT_NAMES = %w[
      solar_panel
      nuclear_reactor
      radioisotope_thermoelectric_generator
      rtg
      biogas_generator_engine
    ].freeze

    def self.assess_isru_capability(settlement)
      # Check for O2 extraction equipment in base_units
      has_o2 = settlement.base_units.any? { |unit| 
        O2_EQUIPMENT_NAMES.include?(unit.unit_name) 
      }
      
      # Check for Power source equipment in base_units
      has_power = settlement.base_units.any? { |unit| 
        POWER_EQUIPMENT_NAMES.include?(unit.unit_name) 
      }

      viable = has_o2 && has_power
      
      # Call missing_for_survival to get missing equipment
      missing_info = missing_for_survival(settlement)

      {
        viable: viable,
        o2_extraction: has_o2,
        power_source: has_power,
        basic_capability: viable ? "O2 extraction confirmed" : "Missing O2 extraction",
        missing: missing_info || []
      }
    end

    # Simple boolean check for survival basics
    def self.has_basic_isru?(settlement)
      result = assess_isru_capability(settlement)
      result[:viable]
    end

    # Returns array of equipment names missing for viability
    # Logic: If no O2 extraction unit found -> return all O2 names. 
    #        If no Power unit found -> return all Power names.
    def self.missing_for_survival(settlement)
      o2_capable = O2_EQUIPMENT_NAMES.any? { |name| 
        settlement.base_units.any? { |u| u.unit_name == name } 
      }
      
      power_capable = POWER_EQUIPMENT_NAMES.any? { |name| 
        settlement.base_units.any? { |u| u.unit_name == name } 
      }
      
      missing_names = []
      
      # If we lack O2 capability, list all O2 equipment as missing
      unless o2_capable
        missing_names.concat(O2_EQUIPMENT_NAMES)
      end
      
      # If we lack Power capability, list all Power equipment as missing
      unless power_capable
        missing_names.concat(POWER_EQUIPMENT_NAMES)
      end
      
      missing_names
    end
  end

  # Backwards-compatible constant for the original all-caps name
  ISRUCapabilityManager = IsruCapabilityManager
end
