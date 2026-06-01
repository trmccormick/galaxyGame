# frozen_string_literal: true

module Logistics
  class ShortageDetector
    # Detect shortages for a settlement
    # Returns array of hashes: [{ resource, current, target, amount, critical }]
    def self.detect_shortages(settlement, threshold_percent = 20)
      inventory = settlement.inventory
      shortages = []
      resources = inventory.resources # Assumes inventory responds to .resources
      resources.each do |resource|
        current = inventory.quantity_of(resource)
        target = calculate_target_inventory(settlement, resource)
        next if target.nil? || current >= (target * (threshold_percent / 100.0))
        amount = target - current
        critical = current < (target * 0.1)
        shortages << {
          resource: resource,
          current: current,
          target: target,
          amount: amount,
          critical: critical
        }
      end
      shortages
    end

    # Calculate target inventory for a resource
    def self.calculate_target_inventory(settlement, resource)
      # 1. Check operational_data
      if settlement.respond_to?(:operational_data) && settlement.operational_data&.dig(:inventory_targets, resource)
        return settlement.operational_data[:inventory_targets][resource]
      end
      # 2. Fallback: check consumption_rates
      if settlement.respond_to?(:consumption_rates) && settlement.consumption_rates&.[](resource)
        # Default: 30 days of consumption
        return settlement.consumption_rates[resource] * 30
      end
      # 3. Fallback: game constants
      if defined?(GameConstants) && GameConstants.const_defined?("#{resource.upcase}_PER_PERSON") && settlement.respond_to?(:population)
        per_person = GameConstants.const_get("#{resource.upcase}_PER_PERSON")
        return per_person * settlement.population * 30
      end
      nil
    end
  end
end
