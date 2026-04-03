
# CRITICAL BUG FIX: Remove hardcoded resource_profile, delegate to live models
module AIManager
  class StateAnalyzer
    def analyze_state(settlement)
      {
        unfilled_buy_orders: Market::Order.where(
          settlement: settlement,
          order_type: :buy,
          status: :open
        ).order(created_at: :asc),
        inventory: settlement.inventory,
        surface_storage: settlement.surface_storage,
        power_available: calculate_power_available(settlement)
      }
    end

    private

    def calculate_power_available(settlement)
      settlement.base_units
                .select(&:operational?)
                .sum { |u| unit_power_output(u) }
    end

    def unit_power_output(unit)
      Lookup::UnitLookupService.new
        .find_unit(unit.unit_type)
        &.dig('operational_properties', 'power_output_kw')
        .to_f
    end
  end
end
  end
end