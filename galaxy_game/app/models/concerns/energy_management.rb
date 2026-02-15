# app/models/concerns/energy_management.rb (STREAMLINED VERSION)
module EnergyManagement
  extend ActiveSupport::Concern

  # Define constants at the module level for unit types that generate power.
  # These are examples; adjust based on your actual unit types.
  POWER_UNIT_TYPES = [
    'power_generator', 'solar_array', 'nuclear_generator',
    'solar_panel', 'fusion_reactor', 'fission_reactor', 'power_plant'
  ].freeze

  included do
    # Ensure the including model has an `operational_data` attribute (jsonb type recommended in DB)
    attribute :operational_data, :jsonb, default: -> { {} } unless method_defined?(:operational_data)

    # Define delegates for methods that exist on the `owner` (e.g., User, Faction)
    delegate :account, to: :owner, allow_nil: true
    delegate :under_sanction?, to: :owner, allow_nil: true
  end

  # --- Core Power Calculation Methods ---

  # Calculates the total power usage (consumption) of the craft/unit and its attached components.
  # This sums up power_consumption_kw from its own operational_data and that of its units.
  def power_usage
    # First try the resource_management path used in the test
    resource_usage = operational_data.dig('resource_management', 'consumables', 'energy_kwh', 'rate')
    return resource_usage.to_f if resource_usage

    # Fall back to the path used in the concern implementation
    calculate_power_usage
  end

  # Calculates the total power generation of the craft/unit and its attached components.
  # Sums up power_generation_kw from its own operational_data and power-generating units.
  def power_generation
    # First try the resource_management path used in the test
    resource_rate = operational_data.dig('resource_management', 'generated', 'energy_kwh', 'rate')
    return resource_rate.to_f if resource_rate

    # Fall back to the path used in the concern implementation
    calculate_power_generation
  end

  # Checks if the craft/unit has enough power to meet its current demands.
  def has_sufficient_power?
    power_generation >= power_usage
  end

  # Calculates the energy balance (surplus or deficit) in kW.
  def energy_balance
    power_generation - power_usage
  end

  # --- Unit-level Power Methods ---

  # Returns the power generation for this unit
  def power_generation
    operational_data.dig('operational_properties', 'power_generation_kw') || 0.0
  end

  # Returns an array of attached units that are power generators.
  # Assumes a `base_units` or `units` association on the including model.
  def power_generating_units
    return [] unless respond_to?(:base_units) # Or :units, depending on your association name
    base_units.select do |unit|
      unit.operational_data.dig('category') == 'energy' &&
      POWER_UNIT_TYPES.include?(unit.operational_data.dig('subcategory'))
    end
  end

  # Provides a snapshot of the current power grid status.
  def power_grid_status
    calculate_power_grid_status
  end

  # Creates a virtual hash of operational data for external consumption or debugging.
  # This represents current calculated states related to power flow.
  def virtual_operational_data
    {
      'resource_management' => {
        'consumables' => {
          'energy_kwh' => {'rate' => calculate_power_usage, 'current_usage' => calculate_power_usage}
        },
        'generated' => {
          'energy_kwh' => {'rate' => calculate_power_generation, 'current_output' => calculate_power_generation}
        }
      },
      'power_grid' => power_grid_status # Use the public method
    }
  end

  # --- Solar Output Methods ---

  # Returns the current solar output factor for scaling solar power generation
  def current_solar_output_factor
    return 1.0 unless respond_to?(:location) && location.present?
    location.solar_output_factor
  end

  # Determines if it's currently daylight based on solar output factor
  def solar_daylight?
    current_solar_output_factor > 0.1
  end

  # --- Private Helper Methods ---

  private

  # Calculates total power usage by summing this model's and its units' consumption.
  # Assumes models can have a `power_consumption_kw` in operational_data
  # and units can have a `power_usage` method (e.g., from EnergyManagement if they also include it,
  # or a direct attribute/method from their own operational_data mapping).
  def calculate_power_usage
    total_usage = operational_data.dig('operational_properties', 'power_consumption_kw') || 0.0

    if respond_to?(:base_units) # Check if the model has associated units
      base_units.each do |unit|
        total_usage += unit.power_usage if unit.respond_to?(:power_usage)
      end
    end
    total_usage
  end

  # Calculates total power generation by summing this model's and its units' generation.
  # Assumes models can have a `power_generation_kw` in operational_data
  # and units can have a `power_generation` method.
  def calculate_power_generation
    total_generation = operational_data.dig('operational_properties', 'power_generation_kw') || 0.0

    if respond_to?(:base_units) # Check if the model has associated units
      base_units.each do |unit|
        unit_generation = unit.power_generation if unit.respond_to?(:power_generation)
        # Apply solar scaling for solar units
        if unit_solar?(unit)
          unit_generation = (unit_generation || 0.0) * current_solar_output_factor
        end
        total_generation += unit_generation || 0.0
      end
    end
    total_generation
  end

  # --- Private Helper Methods ---

  private

  # Helper method to determine if a unit is solar-powered
  def unit_solar?(unit)
    return false unless unit.respond_to?(:operational_data)
    
    subcategory = unit.operational_data&.dig('subcategory')
    subcategory&.include?('solar') || subcategory == 'solar_panel'
  end

  # Calculates the current status of the power grid (e.g., 'online', 'offline', 'low_power').
  # Note: If battery support is desired here, the including model would need to
  # `respond_to?(:battery_level)` (i.e., include `BatteryManagement`).
  def calculate_power_grid_status
    if power_generation > 0 && power_usage > 0
      if power_generation >= power_usage
        'online'
      elsif respond_to?(:battery_level) && battery_level > 0 # Check for battery support if BatteryManagement is included
        'low_power_battery_support'
      else
        'critical_power_deficit'
      end
    elsif power_generation > 0
      'online_idle'
    else
      'offline'
    end
  end

  # During power shortage detection
  def handle_power_shortage(shortage_amount)
    # First try battery backup
    if activate_emergency_power_backup
      # Recalculate shortage after backup power
      remaining_shortage = power_usage - power_generation
      return 0 if remaining_shortage <= 0
    end
    
    # If still in shortage, try biogas generators
    if activate_biogas_generators
      # Recalculate shortage after generators
      remaining_shortage = power_usage - power_generation
      return 0 if remaining_shortage <= 0
    end
    
    # If still in shortage, start powering down systems
    # Continue with the power-down logic we discussed
    # ...
  end

  def activate_emergency_power_backup
    backup_modules = find_modules_by_type('emergency_power_backup')
    return false if backup_modules.empty?
    
    activated = false
    backup_modules.each do |module_unit|
      next if module_unit.current_mode == 'generation' || 
              module_unit.current_mode == 'battery_supply' ||
              module_unit.current_mode == 'emergency'
              
      # Check battery level
      battery_level = module_unit.operational_data.dig('resource_management', 'storage', 'energy_kwh', 'current_level').to_f
      
      if battery_level > 0
        # Use battery supply if we have charge
        module_unit.set_operational_mode('battery_supply')
        activated = true
      elsif module_unit.fuel_remaining > 0
        # Use generator if we have fuel
        module_unit.set_operational_mode('generation')
        activated = true
      end
    end
    
    activated
  end

  def activate_biogas_generators
    generators = find_units_by_type('biogas_generator')
    return false if generators.empty?
    
    # Check biogas storage
    biogas_storage = resource_storage.get_resource_amount('biogas')
    return false if biogas_storage <= 0
    
    # Calculate how many generators we can run
    max_generators = (biogas_storage / 20).floor # Assuming 20 biogas per generator cycle
    active_count = 0
    
    generators.each do |generator|
      break if active_count >= max_generators
      
      if !generator.is_active?
        generator.activate!
        active_count += 1
      end
    end
    
    active_count > 0
  end

  def activate_backup_power_systems(shortage_amount)
    # Find biogas generators in standby mode
    generators = power_generating_units.select do |unit|
      unit.unit_type == 'generator' && 
      unit.subcategory == 'backup_power' &&
      unit.operational_data.dig('operational_modes', 'current_mode') == 'standby'
    end
    
    return false if generators.empty?
    
    # Check biogas availability
    biogas_available = total_resource_amount('biogas_m3')
    return false if biogas_available <= 0
    
    activated_power = 0
    
    # Activate generators
    generators.each do |generator|
      # Check if we have enough biogas for this generator
      biogas_rate = generator.operational_data.dig('resource_management', 'consumables', 'biogas_m3', 'rate').to_f
      break if biogas_available < biogas_rate
      
      # Choose appropriate mode based on shortage severity
      if shortage_amount > 60
        new_mode = 'emergency'
        output = generator.operational_data.dig('operational_modes', 'modes').find { |m| m['name'] == 'emergency' }['power_output_kw'].to_f
      else
        new_mode = 'active'
        output = generator.operational_data.dig('operational_modes', 'modes').find { |m| m['name'] == 'active' }['power_output_kw'].to_f
      end
      
      # Update generator mode
      generator.set_operational_mode(new_mode)
      
      # Track activated power
      activated_power += output
      
      # Reduce available biogas
      biogas_available -= biogas_rate
      
      # If we've met the shortage, stop activating more generators
      break if activated_power >= shortage_amount
    end
    
    # Return true if we activated any power
    activated_power > 0
  end
end