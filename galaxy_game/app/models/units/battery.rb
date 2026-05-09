module Units
  class Battery < BaseUnit
    include BatteryManagement

    # For test: expose charge_level as alias for battery_level
    def charge_level
      battery_level
    end

    # Optionally override max charge/discharge rates for this unit
    def max_charge_rate
      operational_data.dig('battery', 'max_charge_rate_kw') || 50.0
    end

    def max_discharge_rate
      operational_data.dig('battery', 'max_discharge_rate_kw') || 75.0
    end

    # Untested: Self-discharge logic (needs integration with simulation tick/maintenance)
    # Reduces battery charge by self_discharge_rate (fraction per hour) over time
    def apply_self_discharge(time_elapsed_hours = 1)
      rate = operational_data.dig('battery', 'self_discharge_rate') || 0.001 # Default: 0.1% per hour
      loss = battery_capacity * rate * time_elapsed_hours
      operational_data['battery']['current_charge'] = [battery_level - loss, 0].max
      save! if respond_to?(:save!)
    end
  end
end