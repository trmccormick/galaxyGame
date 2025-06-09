# app/models/concerns/energy_management.rb
module EnergyManagement
  extend ActiveSupport::Concern
  
  # Define the constant at the module level, not inside included block
  POWER_UNIT_TYPES = [
    'power_generator', 'solar_array', 'nuclear_generator', 
    'solar_panel', 'fusion_reactor', 'fission_reactor'
  ].freeze
  
  included do
    # No need to redefine it here - it will be inherited properly
  end

  # Get total power usage - combines data from operational_data and units
  def power_usage
    # First check direct operational_data values
    if operational_data.is_a?(Hash)
      if operational_data['resource_management']&.dig('consumables', 'energy_kwh', 'rate')
        # Return the operational data only if we don't have units to aggregate
        return operational_data['resource_management']['consumables']['energy_kwh']['rate'].to_f unless respond_to?(:base_units) && base_units.any?
      elsif operational_data['consumables']&.dig('energy')
        return operational_data['consumables']['energy'].to_f
      elsif operational_data['power_usage']
        return operational_data['power_usage'].to_f
      end
    end
    
    # Calculate from structures and units
    total_usage = 0
    
    # Add structure usage if applicable
    if respond_to?(:structures) && structures.any?
      total_usage += structures.sum { |s| s.respond_to?(:power_usage) ? s.power_usage : 0 }
    end
    
    # Add unit usage if applicable
    if respond_to?(:base_units) && base_units.any?
      total_usage += base_units.sum do |unit|
        if unit.respond_to?(:power_usage)
          unit.power_usage
        elsif unit.operational_data&.dig('consumables', 'energy')
          unit.operational_data['consumables']['energy'].to_f
        else
          0
        end
      end
    end
    
    total_usage
  end
  
  # Get power generation - combines data from operational_data and units
  def power_generation
    return 0 unless respond_to?(:operational_data)
    
    # First check direct operational_data values
    if operational_data.is_a?(Hash)
      if operational_data['resource_management']&.dig('generated', 'energy_kwh', 'rate')
        # Return the operational data only if we don't have units to aggregate
        return operational_data['resource_management']['generated']['energy_kwh']['rate'].to_f unless respond_to?(:base_units) && base_units.any?
      elsif operational_data['generated']&.dig('energy')
        return operational_data['generated']['energy'].to_f
      elsif operational_data['power_generation']
        return operational_data['power_generation'].to_f
      end
    end
    
    # If not found in operational_data, calculate from structures and units
    total_generation = 0
    
    # Add structure generation if applicable
    if respond_to?(:structures) && structures.any?
      total_generation += structures.sum { |s| s.respond_to?(:power_generation) ? s.power_generation : 0 }
    end
    
    # Add unit generation if applicable
    if respond_to?(:base_units) && base_units.any?
      total_generation += base_units.sum do |unit|
        if unit.respond_to?(:power_generation)
          unit.power_generation
        elsif unit.operational_data&.dig('generated', 'energy')
          unit.operational_data['generated']['energy'].to_f
        else
          0
        end
      end
    end
    
    total_generation
  end
  
  # Check if there's enough power for current operations
  def has_sufficient_power?
    power_generation >= power_usage
  end
  
  # Calculate energy surplus or deficit
  def energy_balance
    power_generation - power_usage
  end
  
  # Get power generating units (if units association exists)
  def power_generating_units
    return [] unless respond_to?(:base_units) && base_units.any?
    
    # Use the POWER_UNIT_TYPES constant from the class
    power_types = self.class::POWER_UNIT_TYPES
    
    base_units.select do |unit| 
      unit.operational_data&.dig('generated', 'energy').to_f > 0 || 
      power_types.include?(unit.unit_type.to_s)
    end
  end
  
  # Calculate power distribution to all consumers
  def distribute_power
    return false unless has_sufficient_power?
    
    available = power_generation
    
    # Only applicable if we have base_units
    return true unless respond_to?(:base_units) && base_units.any?
    
    # Prioritize critical systems first
    critical_units = base_units.select { |u| u.operational_data&.dig('power_priority') == 'critical' }
    critical_usage = critical_units.sum do |unit|
      unit.respond_to?(:power_usage) ? unit.power_usage : unit.operational_data&.dig('consumables', 'energy').to_f || 0
    end
    
    available -= critical_usage
    return false if available < 0
    
    # Then allocate to structures if applicable
    if respond_to?(:structures) && structures.any?
      structure_usage = structures.sum(&:power_usage)
      available -= structure_usage
      return false if available < 0
    end
    
    # Finally allocate to non-critical units
    non_critical_units = base_units.reject { |u| u.operational_data&.dig('power_priority') == 'critical' }
    non_critical_usage = non_critical_units.sum do |unit|
      unit.respond_to?(:power_usage) ? unit.power_usage : unit.operational_data&.dig('consumables', 'energy').to_f || 0
    end
    
    available -= non_critical_usage
    
    # Return surplus power
    available >= 0
  end
  
  # Power distribution grid status
  def power_grid_status
    return {} unless respond_to?(:base_units)
    
    status = if has_sufficient_power?
      "optimal"
    elsif power_generation >= power_usage * 0.8
      "strained"
    elsif power_generation >= power_usage * 0.5
      "critical"
    else
      "failing"
    end
    
    distribution = {}
    
    # Add structure distribution if applicable
    if respond_to?(:structures) && structures.any?
      distribution[:structures] = structures.sum(&:power_usage)
    end
    
    # Add unit distributions
    if respond_to?(:base_units) && base_units.any?
      distribution[:critical_units] = base_units
        .select { |u| u.operational_data&.dig('power_priority') == 'critical' }
        .sum { |u| u.operational_data&.dig('consumables', 'energy').to_f || 0 }
      
      distribution[:standard_units] = base_units
        .reject { |u| u.operational_data&.dig('power_priority') == 'critical' }
        .sum { |u| u.operational_data&.dig('consumables', 'energy').to_f || 0 }
    end
    
    {
      status: status,
      total_generation: power_generation,
      total_usage: power_usage,
      surplus: energy_balance,
      distribution: distribution
    }
  end
  
  # Optimize power usage by adjusting operational modes
  def optimize_power_usage
    return true if has_sufficient_power?
    
    # First try to increase generation if possible
    if respond_to?(:power_generating_units) && power_generating_units.any?
      # Implement logic to boost generation if possible
      # This would be game-specific logic
    end
    
    return true if has_sufficient_power?
    
    # If still insufficient, reduce consumption by changing modes
    if respond_to?(:structures) && structures.any?
      structures.each do |structure|
        structure.update_power_usage('standby') if structure.respond_to?(:update_power_usage)
      end
    end
    
    # If still insufficient, shut down non-critical systems
    if !has_sufficient_power? && respond_to?(:base_units) && base_units.any?
      non_critical_units = base_units.reject { |u| u.operational_data&.dig('power_priority') == 'critical' }
      non_critical_units.each do |unit|
        unit.deactivate if unit.respond_to?(:deactivate)
      end
    end
    
    has_sufficient_power?
  end
  
  # Update power usage based on operational mode
  def update_power_usage(mode = nil)
    return unless operational_data && operational_data['operational_modes']
    
    # If no mode specified, use current mode
    mode ||= operational_data['operational_modes']['current_mode']
    
    # Find the specified mode in available modes
    mode_data = operational_data['operational_modes']['available_modes'].find { |m| m['name'] == mode }
    return unless mode_data
    
    # Update power usage based on mode
    if operational_data['resource_management'] && operational_data['resource_management']['consumables'] && 
       operational_data['resource_management']['consumables']['energy_kwh']
      operational_data['resource_management']['consumables']['energy_kwh']['rate'] = mode_data['power_draw']
    else
      # Create the structure if it doesn't exist
      operational_data['resource_management'] ||= {}
      operational_data['resource_management']['consumables'] ||= {}
      operational_data['resource_management']['consumables']['energy_kwh'] ||= {}
      operational_data['resource_management']['consumables']['energy_kwh']['rate'] = mode_data['power_draw']
    end
    
    save if respond_to?(:save)
  end
  
  # Create a virtual operational_data for models that don't have it in the database
  def virtual_operational_data
    # Don't call operational_data - that's creating the recursion
    # Instead, build the power data directly
    {
      'resource_management' => {
        'consumables' => {
          'energy_kwh' => {'rate' => calculate_power_usage, 'current_usage' => calculate_power_usage}
        },
        'generated' => {
          'energy_kwh' => {'rate' => calculate_power_generation, 'current_output' => calculate_power_generation}
        }
      },
      'power_grid' => calculate_power_grid_status
    }
  end

  private

  def calculate_power_generation
    # Get power generation directly from units
    base_units.sum do |unit|
      unit.operational_data&.dig('power', 'generation')&.to_f || 0.0
    end
  end

  def calculate_power_usage
    # Get power usage directly from units
    base_units.sum do |unit|
      unit.operational_data&.dig('power', 'consumption')&.to_f || 0.0
    end
  end

  def calculate_power_grid_status
    gen = calculate_power_generation
    usage = calculate_power_usage
    
    if gen == 0
      {'status' => 'offline', 'efficiency' => 0.0}
    elsif gen >= usage
      {'status' => 'online', 'efficiency' => 1.0}
    else
      {'status' => 'overloaded', 'efficiency' => gen / usage}
    end
  end
end
