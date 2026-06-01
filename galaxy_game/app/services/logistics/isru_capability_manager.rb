# frozen_string_literal: true

module Logistics
  class ISRUCapabilityManager
    # Returns true if settlement has O2 extraction and sufficient power
    def self.has_basic_isru?(settlement)
      operational = settlement.operational_data || {}
      o2 = operational.dig('isru', 'o2_extraction')
      power = operational.dig('power_grid', 'status') == 'online'
      o2 && power
    end

    # Returns array of missing survival capabilities (e.g., ["O2 extraction", "Power"])
    def self.missing_for_survival(settlement)
      missing = []
      operational = settlement.operational_data || {}
      missing << 'O2 extraction' unless operational.dig('isru', 'o2_extraction')
      missing << 'Power' unless operational.dig('power_grid', 'status') == 'online'
      missing
    end
  end
end
