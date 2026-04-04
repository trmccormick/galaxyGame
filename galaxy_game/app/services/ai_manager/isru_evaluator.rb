# app/services/ai_manager/isru_evaluator.rb
#
# ISRU Evaluator — Assesses In-Situ Resource Utilization capabilities.
#
# Reads live settlement state:
#   - Unit inventory via UnitLookupService (no hardcoded unit lists)
#   - Geosphere stored_volatiles for H2O / CO2 regolith content
#   - Atmosphere gases for live CO2 / O2 atmospheric state
#   - Surface storage material_piles for raw_regolith stock
#
# Power is a hard gate: insufficient power returns { status: :blocked }.
#
# PVE (planetary_volatiles_extractor) operates standalone on raw_regolith.
# TEU (thermal_extraction_unit) is preferred first — improves PVE efficiency —
# but is NOT a hard prerequisite.
#
# All resource identifiers use chemical formulas (H2O, O2, CO2, CH4, CO).
# Human-readable names (water, oxygen) are UI-layer only.

class AIManager::ISRUEvaluator
  # Fallback H2O fraction when geosphere has no stored volatile data (2% — typical lunar regolith)
  DEFAULT_VOLATILE_FRACTION = 0.02

  def initialize(settlement)
    @settlement = settlement
    @unit_lookup = Lookup::UnitLookupService.new
  end

  # Main assessment — returns operational hash or blocked status if power insufficient
  def assess_capabilities
    units     = inventory_isru_units
    resources = assess_resource_availability
    power     = assess_power_availability
    required  = calculate_total_power_requirement(units)

    if required > 0 && power < required
      return {
        status:          :blocked,
        reason:          :insufficient_power,
        power_capacity:  power,
        power_required:  required,
        recommendations: ["Expand power generation — need #{(required - power).round(1)} kW more"]
      }
    end

    maintenance = assess_maintenance_status(units)

    {
      status:                :operational,
      units_available:       units,
      resource_availability: resources,
      power_capacity:        power,
      maintenance_status:    maintenance,
      production_rates:      calculate_production_rates(units, resources),
      overall_readiness:     calculate_overall_readiness(units, resources, power, required, maintenance),
      recommendations:       generate_recommendations(units, resources, power, required, maintenance),
      regolith_processing:   pve_capable?(units, resources),
      teu_present:           teu_present?(units),
      atmospheric_processing: atmospheric_processing_capable?(units, resources),
      atmospheric_inputs:    atmospheric_inputs_available?(units, resources),
      methane_generation:    methane_capable?(units, resources)
    }
  end

  # Per-compound production rates (kg/hr) for all active processing units
  def calculate_production_rates(units = nil, resources = nil)
    units     ||= inventory_isru_units
    resources ||= assess_resource_availability
    rates = {}

    units.each do |unit_type, count|
      next if count == 0
      unit_data = @unit_lookup.find_unit(unit_type)
      next unless unit_data
      unit_rates(unit_data, resources, count).each do |compound, rate|
        rates[compound] = (rates[compound] || 0.0) + rate
      end
    end

    rates
  end

  # Returns true if ISRU can produce the compound faster than a baseline import
  def should_use_isru?(compound, quantity_needed, _timeframe_days)
    capabilities = assess_capabilities
    return false if capabilities[:status] == :blocked
    return false unless capabilities[:overall_readiness].to_f > 0.5

    rate = capabilities[:production_rates][compound.to_s] || 0
    return false if rate <= 0

    production_time_days = (quantity_needed / rate.to_f) / 24.0
    production_time_days <= 14  # Conservative import baseline
  end

  # GCC cost comparison for a compound (chemical formula string)
  def compare_isru_vs_import_cost(compound, quantity_needed)
    capabilities = assess_capabilities

    isru_cost_per_kg   = calculate_isru_cost_per_kg(compound, capabilities)
    import_cost_per_kg = calculate_import_cost_per_kg(compound)

    isru_total   = isru_cost_per_kg   * quantity_needed
    import_total = import_cost_per_kg * quantity_needed * 1.2  # 20% import delay premium

    {
      isru_cost:          isru_total,
      import_cost:        import_total,
      recommended:        isru_total < import_total ? 'isru' : 'import',
      savings_percentage: ((import_total - isru_total) / import_total.to_f * 100).round(1)
    }
  end

  private

  # All operational units that have at least one processing capability enabled via UnitLookupService
  def inventory_isru_units
    @settlement.base_units.select(&:operational?).each_with_object({}) do |unit, h|
      data = @unit_lookup.find_unit(unit.unit_type)
      next unless processing_capable?(data)
      h[unit.unit_type] ||= 0
      h[unit.unit_type] += 1
    end
  end

  # Live resource state from geosphere, atmosphere, and surface storage
  def assess_resource_availability
    geosphere  = @settlement.celestial_body&.geosphere
    atmosphere = @settlement.celestial_body&.atmosphere

    {
      raw_regolith:       @settlement.surface_storage
                            &.material_piles
                            &.find_by(material_type: 'raw_regolith')
                            &.amount.to_f || 0.0,
      regolith_volatiles: geosphere&.stored_volatiles || {},
      atmospheric_gases:  atmosphere&.gases&.pluck(:name, :percentage)&.to_h || {}
    }
  end

  # Total power generated by all operational units that report power_generation_kw
  def assess_power_availability
    @settlement.base_units.select(&:operational?).sum do |unit|
      data = @unit_lookup.find_unit(unit.unit_type)
      data&.dig('operational_properties', 'power_generation_kw').to_f
    end
  end

  # Total power consumed by the processing units currently in the settlement
  def calculate_total_power_requirement(units)
    units.sum do |unit_type, count|
      data = @unit_lookup.find_unit(unit_type)
      data&.dig('operational_properties', 'power_consumption_kw').to_f * count
    end
  end

  # Maintenance score across all processing-capable unit types
  def assess_maintenance_status(units = nil)
    types = (units || inventory_isru_units).keys
    return { status: :no_units, score: 0.0, operational_units: 0, total_units: 0 } if types.empty?

    all_units   = @settlement.base_units.where(unit_type: types)
    total       = all_units.count
    operational = all_units.count(&:operational?)
    score       = total > 0 ? operational.to_f / total : 0.0

    status = case score
             when 0.9..1.0  then :excellent
             when 0.7...0.9 then :good
             when 0.5...0.7 then :fair
             else                :poor
             end

    { status: status, score: score, operational_units: operational, total_units: total }
  end

  # Readiness 0.0–1.0 weighted across unit count, regolith availability, power, maintenance
  def calculate_overall_readiness(units, resources, power, required, maintenance)
    return 0.0 if units.empty?
    unit_score     = units.values.sum > 0 ? [units.values.sum / 4.0, 1.0].min : 0.0
    regolith_kg    = resources[:raw_regolith].to_f
    resource_score = regolith_kg >= 1000 ? 1.0 : regolith_kg / 1000.0
    power_score    = required > 0 ? [power / required.to_f, 1.0].min : 1.0

    (unit_score * 0.35) + (resource_score * 0.35) + (power_score * 0.15) + (maintenance[:score].to_f * 0.15)
  end

  def generate_recommendations(units, resources, power, required, maintenance)
    recs = []
    unless pve_capable?(units, resources)
      recs << "Deploy a volatile extractor unit to begin H2O extraction from regolith"
    end
    unless teu_present?(units)
      recs << "Deploy a thermal extraction unit upstream of the volatile extractor to improve yield efficiency"
    end
    if resources[:raw_regolith].to_f < 1000
      recs << "Increase raw regolith surface mining — current stock: #{resources[:raw_regolith].to_f.round} kg"
    end
    if required > 0 && power < required
      recs << "Expand power generation — need #{(required - power).round(1)} kW more"
    end
    if maintenance[:total_units].to_i > 0 && maintenance[:score].to_f < 0.8
      down = maintenance[:total_units] - maintenance[:operational_units]
      recs << "#{down} processing unit(s) offline — schedule maintenance"
    end
    unless atmospheric_processing_capable?(units, resources)
      recs << "Deploy an atmospheric processing unit to extract gases from available atmosphere"
    end
    recs
  end

  # Per-unit hourly output rates (kg/hr) — generic data-driven loop.
  #
  # Units are input/output machines: behavior defined entirely by operational JSON.
  # - output.amount > 0  → fixed ratio from JSON (e.g. TEU: 9.95 out per 10 in)
  # - output.amount == 0 → world-driven: look up output.id in stored_volatiles or
  #                         atmospheric_gases and apply geosphere/atmospheric efficiency
  #
  # No case statements on unit type name. No hardcoded chemistry.
  def unit_rates(unit_data, resources, count)
    outputs = unit_data['output_resources'].to_a
    return {} if outputs.empty?

    input_kg  = unit_data.dig('input_resources', 0, 'amount').to_f
    input_id  = unit_data.dig('input_resources', 0, 'id').to_s

    # Resolve input availability against world resources
    input_available = input_available?(input_id, input_kg, resources)
    return {} unless input_available

    geo_eff = unit_data.dig('processing_capabilities', 'geosphere_processing', 'efficiency').to_f
    geo_eff = 1.0 if geo_eff == 0
    atm_eff = unit_data.dig('processing_capabilities', 'atmospheric_processing', 'efficiency').to_f
    atm_eff = 1.0 if atm_eff == 0

    rates = {}
    outputs.each do |output|
      id     = output['id'].to_s
      amount = output['amount'].to_f

      rate = if amount > 0
        # Fixed ratio already in JSON — use directly
        amount * count
      else
        # World-driven: fraction from stored_volatiles or atmospheric_gases
        fraction = world_fraction(id, resources)
        next if fraction == 0
        eff = geosphere_output?(id) ? geo_eff : atm_eff
        input_kg * fraction * eff * count
      end

      rates[id] = rate if rate > 0
    end

    rates
  end

  # True if the world has the input resource available
  def input_available?(input_id, input_kg, resources)
    return true if input_id.empty? || input_kg == 0
    case input_id
    when 'raw_regolith', 'processed_regolith'
      resources[:raw_regolith].to_f > 0
    else
      # Atmospheric or geosphere input — check availability
      resources[:atmospheric_gases][input_id].to_f > 0 ||
        resources[:regolith_volatiles][input_id].present?
    end
  end

  # Whether this output ID is resolved from geosphere volatiles (vs atmosphere)
  def geosphere_output?(id)
    # Outputs resolved from stored_volatiles; compound-named outputs may be geo or atm
    # If the compound exists in stored_volatiles, treat as geosphere-driven.
    # Atmospheric outputs (O2, CO, CH4 from Sabatier) are atm_eff driven.
    !%w[O2 CO CH4].include?(id)
  end

  # World fraction for a zero-amount output: look in stored_volatiles first, then atmosphere
  def world_fraction(id, resources)
    return 1.0 - DEFAULT_VOLATILE_FRACTION if id == 'depleted_regolith'
    return 1.0 if id == 'processed_regolith'

    # mixed_volatiles = total gas fraction driven off per kg regolith input.
    # DEFAULT_VOLATILE_FRACTION is the conservative baseline (2%).
    # A future geosphere survey integration can improve this per-world.
    return DEFAULT_VOLATILE_FRACTION if id == 'mixed_volatiles'

    volatiles = resources[:regolith_volatiles]

    # No geosphere survey data — use conservative default fraction
    return DEFAULT_VOLATILE_FRACTION if volatiles.blank?

    # Survey data exists — look up compound specifically
    frac = volatile_fraction(volatiles, id)
    return frac if frac > 0

    # Compound absent in geosphere survey — check atmospheric sources
    atm_pct = resources[:atmospheric_gases][id].to_f
    atm_pct > 0 ? atm_pct / 100.0 : 0.0
  end

  # Fraction of a compound in stored_volatiles relative to total volatile mass.
  # Returns 0.0 when compound not found (survey has data but not this compound).
  # Returns DEFAULT_VOLATILE_FRACTION only when stored_volatiles is empty or has no total mass.
  def volatile_fraction(stored_volatiles, compound)
    return DEFAULT_VOLATILE_FRACTION unless stored_volatiles.is_a?(Hash) && stored_volatiles.present?

    total = stored_volatiles.values.sum do |v|
      v.is_a?(Hash) ? v.values.sum.to_f : v.to_f
    end
    return DEFAULT_VOLATILE_FRACTION if total == 0

    compound_data = stored_volatiles[compound]
    return 0.0 unless compound_data  # compound absent in survey — not in this deposit

    amount = compound_data.is_a?(Hash) ? compound_data.values.sum.to_f : compound_data.to_f
    [amount / total, 1.0].min
  end

  # True if unit_data has at least one enabled processing capability
  # OR has defined output_resources — fully data-driven, no name matching
  def processing_capable?(unit_data)
    return false unless unit_data.is_a?(Hash)
    caps = unit_data['processing_capabilities'] || {}
    return true if caps.any? { |_, v| v.is_a?(Hash) && v['enabled'] == true }
    unit_data['output_resources'].to_a.any?
  end

  # True if any unit has atmospheric_processing enabled AND the world has atmosphere gases
  def atmospheric_processing_capable?(units, resources)
    return false if resources[:atmospheric_gases].empty?
    units.keys.any? do |unit_type|
      data = @unit_lookup.find_unit(unit_type)
      data&.dig('processing_capabilities', 'atmospheric_processing', 'enabled') == true
    end
  end

  # True if any unit consumes regolith inputs AND regolith is available — no name matching
  def pve_capable?(units, resources)
    return false if resources[:raw_regolith].to_f == 0
    units.keys.any? do |unit_type|
      data = @unit_lookup.find_unit(unit_type)
      input_id = data&.dig('input_resources', 0, 'id').to_s
      input_id == 'processed_regolith'
    end
  end

  # True if TEU (raw_regolith input, geosphere_processing enabled) is present
  def teu_present?(units)
    units.keys.any? do |unit_type|
      data = @unit_lookup.find_unit(unit_type)
      data&.dig('input_resources', 0, 'id') == 'raw_regolith' &&
        data&.dig('processing_capabilities', 'geosphere_processing', 'enabled') == true
    end
  end

  # True if any input gas of any atmospheric-processing unit exists in the world's atmosphere
  def atmospheric_inputs_available?(units, resources)
    return false if resources[:atmospheric_gases].empty?
    units.keys.any? do |unit_type|
      data = @unit_lookup.find_unit(unit_type)
      next false unless data&.dig('processing_capabilities', 'atmospheric_processing', 'enabled') == true
      data['input_resources'].to_a.any? do |inp|
        resources[:atmospheric_gases][inp['id']].to_f > 0
      end
    end
  end

  def methane_capable?(units, resources)
    units.keys.any? do |unit_type|
      data = @unit_lookup.find_unit(unit_type)
      next false unless data&.dig('processing_capabilities', 'atmospheric_processing', 'enabled') == true
      # Unit produces CH4 in its output_resources
      data['output_resources'].to_a.any? { |o| o['id'] == 'CH4' } &&
        atmospheric_inputs_available?({ unit_type => 1 }, resources)
    end
  end

  def calculate_isru_cost_per_kg(compound, capabilities)
    base_costs = { 'O2' => 0.5, 'CH4' => 0.8, 'H2O' => 0.2 }
    readiness  = [capabilities[:overall_readiness].to_f, 0.01].max
    (base_costs[compound.to_s] || 1.0) / readiness
  end

  def calculate_import_cost_per_kg(compound)
    { 'O2' => 2.0, 'CH4' => 3.0, 'H2O' => 1.5 }.fetch(compound.to_s, 5.0)
  end
end