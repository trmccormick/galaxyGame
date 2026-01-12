module Units
  class Battery < BaseUnit
    include BatteryManagement
    
    def battery_capacity
      operational_data.dig('battery', 'capacity') || 0
    end
    
    def battery_level
      operational_data.dig('battery', 'current_charge') || 0
    end
    
    def battery_percentage
      return 0 if battery_capacity == 0
      (battery_level / battery_capacity) * 100
    end
    
    def charge_battery(amount)
      current = operational_data.dig('battery', 'current_charge') || 0
      capacity = operational_data.dig('battery', 'capacity') || 0
      max_charge = operational_data.dig('battery', 'max_charge_rate_kw') || 10.0
      
      # Limit by max charge rate
      amount = [amount, max_charge].min
      
      # Don't exceed capacity
      new_charge = [current + amount, capacity].min
      
      # Update the operational data
      operational_data['battery']['current_charge'] = new_charge
      save!
      
      # Return the amount actually charged
      new_charge - current
    end
    
    def discharge_battery(amount)
      current = operational_data.dig('battery', 'current_charge') || 0
      max_discharge = operational_data.dig('battery', 'max_discharge_rate_kw') || 15.0
      
      # Limit by max discharge rate
      amount = [amount, max_discharge].min
      
      # Don't go below zero
      amount = [amount, current].min
      
      # Update the operational data
      operational_data['battery']['current_charge'] = current - amount
      save!
      
      # Return the amount actually discharged
      amount
    end
  end
end