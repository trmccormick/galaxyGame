# app/services/ai_manager/isru_evaluator.rb
#
# ISRU Evaluator - Assesses In-Situ Resource Utilization capabilities
# Prioritizes local production over imports for Luna base development

class AIManager::ISRUEvaluator
  # ISRU unit types and their production capabilities
  ISRU_UNITS = {
    'PLANETARY_VOLATILES_EXTRACTOR_MK1' => {
      input_resource: 'processed_regolith',
      input_rate_kg_per_hour: 5.0,
      outputs: {
        water: 0.30,      # kg per 5kg input
        gases: 0.05,      # kg per 5kg input (H2, CO, He-3, Ne)
        inert_waste: 4.65 # kg per 5kg input
      },
      power_requirement_kw: 25.0,
      operational_efficiency: 0.95
    },
    'THERMAL_EXTRACTION_UNIT_MK1' => {
      input_resource: 'raw_regolith',
      input_rate_kg_per_hour: 10.0,
      outputs: {
        processed_regolith: 9.95 # kg per 10kg input
      },
      power_requirement_kw: 15.0,
      operational_efficiency: 0.98
    },
    'CO2_SPLITTER_MK1' => {
      input_resource: 'venus_atmosphere',
      input_rate_kg_per_hour: 50.0,
      outputs: {
        liquid_oxygen: 0.23,  # ~23% of CO2 mass converts to O2
        carbon_monoxide: 0.42 # ~42% becomes CO
      },
      power_requirement_kw: 30.0,
      operational_efficiency: 0.85
    },
    'SABATIER_REACTOR_MK1' => {
      inputs: { co2: 1.0, h2: 4.0 }, # CO2 + 4H2 → CH4 + 2H2O
      input_rate_kg_per_hour: 10.0,
      outputs: {
        methane: 0.67,    # kg CH4 per kg CO2 input
        water: 1.43       # kg H2O produced
      },
      power_requirement_kw: 20.0,
      operational_efficiency: 0.90
    }
  }.freeze

  # Gas composition ratios from regolith processing
  GAS_COMPOSITION = {
    hydrogen: 0.50,
    carbon_monoxide: 0.25,
    helium_3: 0.05,
    neon: 0.20
  }.freeze

  def initialize(settlement)
    @settlement = settlement
  end

  # Main assessment method - returns ISRU readiness rating
  def assess_capabilities
    units = inventory_isru_units
    resources = assess_resource_availability
    power = assess_power_availability
    maintenance = assess_maintenance_status

    capabilities = {
      units_available: units,
      resource_availability: resources,
      power_capacity: power,
      maintenance_status: maintenance,
      production_rates: calculate_production_rates(units, resources, power),
      overall_readiness: calculate_overall_readiness(units, resources, power, maintenance),
      recommendations: generate_recommendations(units, resources, power, maintenance)
    }

    # Add specific capability flags
    capabilities.merge!(
      regolith_processing: units['PLANETARY_VOLATILES_EXTRACTOR_MK1'] > 0 && units['THERMAL_EXTRACTION_UNIT_MK1'] > 0,
      venus_compatible: units['CO2_SPLITTER_MK1'] > 0,
      co2_ice_available: resources[:co2] > 1000 && resources[:ice] > 500,
      methane_generation: units['SABATIER_REACTOR_MK1'] > 0 && resources[:co2] > 0 && resources[:h2] > 0
    )

    capabilities
  end

  # Calculate production rates for each resource type
  def calculate_production_rates(units = nil, resources = nil, power_capacity = nil)
    units ||= inventory_isru_units
    resources ||= assess_resource_availability
    power_capacity ||= assess_power_availability
    
    total_power_required = calculate_total_power_requirement(units)
    power_factor = if total_power_required > 0
                     [1.0, power_capacity / total_power_required.to_f].min
                   else
                     1.0
                   end
    rates = {}

    units.each do |unit_type, count|
      next if count == 0
      unit_outputs = ISRU_UNITS[unit_type][:outputs] || {}
      unit_outputs.each do |resource, rate|
        rates[resource.to_sym] ||= 0
        rates[resource.to_sym] += rate.to_f * count * power_factor
      end
    end

    rates
  end

  # Determine if ISRU is preferable to imports for a given resource
  def should_use_isru?(resource_type, quantity_needed, timeframe_days)
    capabilities = assess_capabilities

    return false unless capabilities[:overall_readiness] > 0.5

    production_rate = capabilities[:production_rates][resource_type.to_sym] || 0
    return false if production_rate <= 0

    # Calculate time to produce needed quantity
    production_time_hours = quantity_needed / production_rate.to_f
    production_time_days = production_time_hours / 24.0

    # Compare with import time (assume 7-14 days for Earth, 30-90 for other)
    import_time_days = case resource_type.to_s
                      when 'liquid_oxygen', 'methane', 'water'
                        14 # Earth import time
                      else
                        30 # Other imports
                      end

    # Use ISRU if it can meet the need faster than imports
    production_time_days <= import_time_days
  end

  # Calculate ISRU vs import cost comparison
  def compare_isru_vs_import_cost(resource_type, quantity_needed)
    capabilities = assess_capabilities

    isru_cost_per_kg = calculate_isru_cost_per_kg(resource_type, capabilities)
    import_cost_per_kg = calculate_import_cost_per_kg(resource_type)

    isru_total_cost = isru_cost_per_kg * quantity_needed
    import_total_cost = import_cost_per_kg * quantity_needed

    # Factor in time value (imports take longer)
    import_time_penalty = 1.2 # 20% premium for delay
    import_total_cost *= import_time_penalty

    {
      isru_cost: isru_total_cost,
      import_cost: import_total_cost,
      recommended: isru_total_cost < import_total_cost ? 'isru' : 'import',
      savings_percentage: ((import_total_cost - isru_total_cost) / import_total_cost.to_f * 100).round(1)
    }
  end

  private

  # Count available ISRU units by type
  def inventory_isru_units
    units = @settlement.base_units.where(unit_type: ISRU_UNITS.keys)
    unit_counts = Hash.new(0)

    units.each do |unit|
      unit_counts[unit.unit_type] += 1 if unit.operational?
    end

    unit_counts
  end

  # Assess available resources for ISRU processes
  def assess_resource_availability
    inventory = @settlement.inventory
    surface_storage = @settlement.surface_storage

    {
      raw_regolith: surface_storage&.material_piles&.find_by(material_type: 'raw_regolith')&.amount&.to_f || 0,
      processed_regolith: inventory.items.find_by(name: 'processed_regolith')&.amount&.to_f || 0,
      co2: inventory.items.find_by(name: 'carbon_dioxide')&.amount&.to_f || 0,
      ice: inventory.items.find_by(name: 'water_ice')&.amount&.to_f || 0,
      h2: inventory.items.find_by(name: 'hydrogen')&.amount&.to_f || 0,
      venus_atmosphere: inventory.items.find_by(name: 'venus_atmosphere')&.amount&.to_f || 0
    }
  end

  # Assess available power capacity
  def assess_power_availability
    # Check for power generation units and current capacity
    power_units = @settlement.base_units.where(unit_type: ['SOLAR_PANEL_ARRAY', 'NUCLEAR_REACTOR_MK1', 'RTG_MK1'])

    total_capacity = power_units.sum do |unit|
      case unit.unit_type
      when 'SOLAR_PANEL_ARRAY'
        10.0 # kW - assume lunar day average
      when 'NUCLEAR_REACTOR_MK1'
        100.0 # kW
      when 'RTG_MK1'
        0.125 # kW (125 watts)
      else
        0.0
      end
    end

    total_capacity
  end

  # Assess maintenance status of ISRU units
  def assess_maintenance_status
    isru_units = @settlement.base_units.where(unit_type: ISRU_UNITS.keys)

    total_units = isru_units.count
    return { status: :no_units, score: 0.0, operational_units: 0, total_units: 0 } if total_units == 0

    operational_units = isru_units.count { |unit| unit.operational? }
    maintenance_score = operational_units / total_units.to_f

    status = case maintenance_score
             when 0.9..1.0 then :excellent
             when 0.7..0.9 then :good
             when 0.5..0.7 then :fair
             else :poor
             end

    { status: status, score: maintenance_score, operational_units: operational_units, total_units: total_units }
  end

  # Calculate overall ISRU readiness score (0.0 to 1.0)
  def calculate_overall_readiness(units, resources, power_capacity, maintenance)
    scores = []

    # Unit availability score
    unit_score = units.values.sum > 0 ? [units.values.sum / 6.0, 1.0].min : 0.0 # Assume 6 units for full capability
    scores << unit_score

    # Resource availability score
    resource_score = [
      resources[:raw_regolith] > 1000 ? 1.0 : resources[:raw_regolith] / 1000.0,
      resources[:co2] > 500 ? 1.0 : resources[:co2] / 500.0,
      resources[:ice] > 200 ? 1.0 : resources[:ice] / 200.0
    ].sum / 3.0
    scores << resource_score

    # Power capacity score
    required_power = calculate_total_power_requirement(units)
    power_score = required_power > 0 ? [power_capacity / required_power.to_f, 1.0].min : 0.0
    scores << power_score

    # Maintenance score
    maintenance_score = maintenance[:score]
    scores << maintenance_score

    # Weighted average
    weights = [0.3, 0.3, 0.2, 0.2] # Units, Resources, Power, Maintenance
    weighted_score = scores.zip(weights).sum { |score, weight| score * weight }

    weighted_score
  end

  # Generate recommendations for improving ISRU capabilities
  def generate_recommendations(units, resources, power_capacity, maintenance)
    recommendations = []

    if units.values.sum == 0
      recommendations << "Deploy initial ISRU units (TEU and PVE) for regolith processing"
    end

    if resources[:raw_regolith] < 1000
      recommendations << "Increase raw regolith mining capacity"
    end

    if power_capacity < 50
      recommendations << "Expand power generation infrastructure"
    end

    if maintenance[:score] < 0.8
      recommendations << "Schedule maintenance for #{maintenance[:total_units] - maintenance[:operational_units]} ISRU units"
    end

    if units['CO2_SPLITTER_MK1'] == 0
      recommendations << "Consider Venus atmosphere processing capability"
    end

    if units['SABATIER_REACTOR_MK1'] == 0 && resources[:co2] > 0
      recommendations << "Add Sabatier reactor for methane generation from CO2 + H2"
    end

    recommendations
  end

  # Calculate total power requirement for a set of units
  def calculate_total_power_requirement(units)
    total_power = 0.0
    units.each do |unit_type, count|
      next if count == 0
      power_req_kw = ISRU_UNITS[unit_type][:power_requirement_kw] || 0.0
      total_power += power_req_kw * count
    end
    total_power
  end

  # Calculate ISRU cost per kg for a resource
  def calculate_isru_cost_per_kg(resource_type, capabilities)
    # Base costs in GCC (Galactic Crypto Currency)
    base_costs = {
      liquid_oxygen: 0.5,    # GCC per kg
      methane: 0.8,          # GCC per kg
      water: 0.2,            # GCC per kg
      inert_waste: 0.0       # Free byproduct
    }

    # Adjust for efficiency
    efficiency_multiplier = 1.0 / capabilities[:overall_readiness]
    base_cost = base_costs[resource_type.to_sym] || 1.0

    base_cost * efficiency_multiplier
  end

  # Calculate import cost per kg for a resource
  def calculate_import_cost_per_kg(resource_type)
    # Import costs include transportation and Earth Anchor Price (EAP)
    import_costs = {
      liquid_oxygen: 2.0,    # GCC per kg (Earth transport + EAP)
      methane: 3.0,          # GCC per kg (Earth transport + EAP)
      water: 1.5,            # GCC per kg
      inert_waste: 0.0       # Not imported
    }

    import_costs[resource_type.to_sym] || 5.0
  end
end