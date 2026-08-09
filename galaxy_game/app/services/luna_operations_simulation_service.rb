# app/services/luna_operations_simulation_service.rb
# Standalone daily-tick simulation service for a deployed Luna base.
# Advances the settlement forward N days, tracking inventory deltas and
# making local-vs-import decisions each tick.
#
# MVP scope: three components — daily state advancement, inventory delta calc,
# binary import gate. No economic engine, no learning, no multi-resource optimization.

class LunaOperationsSimulationService
  # Decision log entry per tick per resource.
  Decision = Struct.new(:tick, :resource, :decision, :reason, :delta, :cost_per_kg, keyword_init: true)

  # Tracked resources for the simulation loop.
  # Resources use capitalized display names for Item validation compatibility (special_case_name? check).
  TRACKED_RESOURCES = ['oxygen', 'hydrogen', 'water', 'food', 'regolith', 'Processed Regolith', 'Mixed Volatiles', 'He3'].freeze

  def initialize(settlement, day_count: 30)
    @settlement = settlement
    @day_count = day_count
    @decisions = []
    @daily_log = []
  end

  attr_reader :decisions, :daily_log

  # Run the simulation. Returns self for chaining.
  def run
    raise ArgumentError, "Settlement must be deployed (has location)" unless @settlement.location&.celestial_body
    raise ArgumentError, "Day count must be positive" if @day_count <= 0

    celestial_body = @settlement.location.celestial_body
    capability_service = AIManager::PrecursorCapabilityService.new(celestial_body)

    # Initialize tick tracking in operational_data (additive, no migration needed).
    ops = (@settlement.operational_data || {}).dup
    ops['tick_count'] ||= 0
    ops['last_simulated_at'] ||= Time.current.to_s
    @settlement.operational_data = ops

    @daily_log << "=== Luna Base Operations Simulation ==="
    @daily_log << "Settlement: #{@settlement.name} (ID: #{@settlement.id})"
    @daily_log << "Celestial body: #{celestial_body.name}"
    @daily_log << "Population: #{@settlement.current_population}"
    @daily_log << "Duration: #{@day_count} days"
    @daily_log << ""

    (1..@day_count).each do |tick|
      tick_result = advance_tick(tick, capability_service)
      @daily_log << "[Day #{tick}] #{tick_result[:summary]}"
    end

    # Persist tick count and last_simulated_at to settlement.
    ops = (@settlement.operational_data || {}).dup
    ops['tick_count'] = (ops['tick_count'] || 0) + @day_count
    ops['last_simulated_at'] = Time.current.to_s
    @settlement.operational_data = ops
    @settlement.save!

    @daily_log << ""
    @daily_log << "=== Simulation Complete ==="
    @daily_log << "Total ticks: #{@day_count}"
    @daily_log << "Final tick count: #{ops['tick_count']}"
    @daily_log << "Import decisions made: #{@decisions.count { |d| d.decision == 'IMPORT' }}"

    self
  end

  # Human-readable log of the entire simulation.
  def to_s
    @daily_log.join("\n")
  end

  private

  attr_reader :settlement, :day_count

  # Advance a single daily tick. Returns a summary hash.
  def advance_tick(tick, capability_service)
    population = settlement.current_population.to_i
    inventory = settlement.inventory
    return { summary: "No inventory on settlement" } unless inventory

    production = {}   # resource => amount produced this tick (kg or L)
    consumption = {}  # resource => amount consumed this tick (kg or L)

    # ── Tier A: Human Crew Life Support (hard requirement, cannot be paused) ──
    life_support = calculate_life_support_consumption(population)
    life_support.each do |resource, amount|
      consumption[resource] = (consumption[resource] || 0) + amount
    end

    # Apply life support consumption to inventory.
    life_support.each do |resource, amount|
      apply_consumption(inventory, resource, amount)
    end

    # ── Tier B: Blueprint Production (blocked if materials unavailable) ──
    production_tier_b = calculate_blueprint_production(inventory, capability_service)

    # Apply feedstock consumption for production jobs.
    production_tier_b[:feedstock_consumption]&.each do |resource, amount|
      consumption[resource] = (consumption[resource] || 0) + amount
      apply_consumption(inventory, resource, amount)
    end

    # Add only scalar production outputs (exclude feedstock_consumption hash).
    production_tier_b.each do |key, value|
      next if key == :feedstock_consumption
      production[key] = (production[key] || 0) + value
    end

    # ── Tier C: Base Maintenance (periodic infrastructure drain) ──
    maintenance = calculate_maintenance_drain()
    maintenance.each do |resource, amount|
      consumption[resource] = (consumption[resource] || 0) + amount
      apply_consumption(inventory, resource, amount)
    end

    # ── Apply production to inventory ──
    production.except(:feedstock_consumption).each do |resource, amount|
      apply_production(inventory, resource, amount)
    end

    # Persist inventory changes from this tick.
    if settlement.inventory&.persisted?
      settlement.inventory.items.each(&:save!)
    end

    # ── Calculate delta per tracked resource ──
    deltas = {}
    TRACKED_RESOURCES.each do |resource|
      prod = (production[resource] || 0).to_f
      cons = (consumption[resource] || 0).to_f
      deltas[resource] = prod - cons
    end

    # ── Evaluate import gate per tracked resource ──
    tick_decisions = evaluate_import_gate(tick, capability_service, deltas)

    # Build summary.
    summary_parts = deltas.map do |resource, delta|
      sign = delta >= 0 ? '+' : ''
      "#{resource}: #{sign}#{delta.round(3)}"
    end.join(", ")
    { summary: "Production/Consumption — #{summary_parts}" }
  end

  # ── Tier A: Life Support ──
  def calculate_life_support_consumption(population)
    ls = GameConstants::HUMAN_LIFE_SUPPORT
    {
      'oxygen' => population * ls['oxygen_per_person_day'],
      'water'  => population * GameConstants::WATER_UNRECOVERABLE_LOSS_PER_PERSON_DAY,
      'food'   => population * GameConstants::FOOD_PER_PERSON
    }
  end

  # ── Tier B: Blueprint Production ──
  def calculate_blueprint_production(inventory, capability_service)
    result = { feedstock_consumption: {} }

    # Regolith is surface material on Luna — unlimited feedstock for all production.
    # We use a large sentinel value to represent "unlimited" regolith availability.
    regolith_unlimited = 1_000_000.0

    # ── I-beam Production ──
    # Recipe: 75 kg regolith -> 69 kg I-beam, 2 hr production.
    if capability_service.can_produce_locally?('regolith')
      ibeam_output = 69.0
      result['ibeam'] = ibeam_output
      result[:feedstock_consumption]['regolith'] = (result[:feedstock_consumption]['regolith'] || 0) + 75
    end

    # ── TEU Production ──
    # Thermal Extraction Unit: raw_regolith -> processed_regolith + mixed_volatiles
    # Per cycle: 10 kg raw_regolith -> 9.95 kg processed_regolith + 0.05 kg mixed_volatiles
    # Energy: 50 kWh per cycle (per unit)
    teu_units = settlement.base_units.where(unit_type: 'thermal_extraction_unit_mk1').to_a
    if teu_units.any? && capability_service.can_produce_locally?('regolith')
      regolith_for_teu = [
        regolith_unlimited,
        teu_units.size * GameConstants::TEU_REGOLITH_PER_CYCLE_KG
      ].min

      if regolith_for_teu >= GameConstants::TEU_REGOLITH_PER_CYCLE_KG
        cycles = (regolith_for_teu / GameConstants::TEU_REGOLITH_PER_CYCLE_KG).floor
        processed_regolith = cycles * GameConstants::TEU_PROCESSED_REGOLITH_PER_CYCLE_KG
        mixed_volatiles = cycles * GameConstants::TEU_MIXED_VOLATILES_PER_CYCLE_KG

        result['Processed Regolith'] = (result['Processed Regolith'] || 0) + processed_regolith
        result[:feedstock_consumption]['regolith'] = (result[:feedstock_consumption]['regolith'] || 0) + regolith_for_teu
        # mixed_volatiles added to production (not feedstock)
        result['Mixed Volatiles'] = (result['Mixed Volatiles'] || 0) + mixed_volatiles
      end
    end

    # ── PVE Production ──
    # Planetary Volatiles Extractor: Processed Regolith -> O2 + H2 + He3
    # Per cycle: 5 kg Processed Regolith -> ~1.575 kg O2 + H2 (from H2O electrolysis) + trace He3
    # Energy: 120 kWh per cycle (per unit)
    # O2 recovery: 42% O2 in regolith × 0.75 processing efficiency (NASA ECLSS)
    # NOTE: capability_service.can_produce_locally? checks celestial body data, not deployed hardware.
    # Processed Regolith is a manufactured intermediate — check for deployed PVE units instead.
    pve_units = settlement.base_units.where(unit_type: 'planetary_volatiles_extractor_mk1').to_a
    if pve_units.any?
      processed_reg_for_pve = [
        inventory.current_storage_of('Processed Regolith'),
        pve_units.size * GameConstants::PVE_REGOLITH_PER_CYCLE_KG
      ].min

      if processed_reg_for_pve >= GameConstants::PVE_REGOLITH_PER_CYCLE_KG
        cycles = (processed_reg_for_pve / GameConstants::PVE_REGOLITH_PER_CYCLE_KG).floor

        # O2 from regolith oxides via high-temperature chemical reduction
        o2_yield = cycles * GameConstants::PVE_O2_PER_CYCLE_KG
        result['oxygen'] = (result['oxygen'] || 0) + o2_yield

        # He3 from solar-wind implanted volatiles (negligible at game scale)
        he3_yield = cycles * GameConstants::PVE_HE3_PER_CYCLE_KG
        result['He3'] = (result['He3'] || 0) + he3_yield if he3_yield > 0

        # H2 from water electrolysis (if H2O available in inventory)
        h2o_available = inventory.current_storage_of('H2O')
        if h2o_available > 0
          # Each cycle consumes Processed Regolith; H2 yield depends on H2O content
          # Electrolysis: 2H2O -> 2H2 + O2, mass ratio H2:H2O = 1:9
          h2_per_cycle = GameConstants::PVE_H2_FROM_ELECTROLYSIS_PER_KG_H2O * [h2o_available, cycles].min
          result['hydrogen'] = (result['hydrogen'] || 0) + h2_per_cycle
        end

        result[:feedstock_consumption]['Processed Regolith'] = (result[:feedstock_consumption]['Processed Regolith'] || 0) + processed_reg_for_pve
      end
    end

    # Solar cover panels: require 6 specialized materials NOT available on Luna.
    # Production is import-gated -- no local production possible for MVP.

    result
  end

  # ── Tier C: Base Maintenance ──
  def calculate_maintenance_drain()
    solar_units = settlement.base_units.where(unit_type: 'solar_panel').to_a
    return {} if solar_units.empty?

    daily_per_panel = {
      'cleaning_supplies' => 0.5 / 365.0,
      'replacement_parts' => 0.1 / 365.0
    }

    solar_units.each_with_object({}) do |panel, acc|
      daily_per_panel.each do |(resource, amount), _|
        acc[resource] = (acc[resource] || 0) + amount
      end
    end
  end

  # ── Import Gate ──
  def evaluate_import_gate(tick, capability_service, deltas)
    tick_decisions = []

    TRACKED_RESOURCES.each do |resource|
      delta = deltas[resource]
      current_stockpile = settlement.inventory.current_storage_of(resource)

      # If resource can be produced locally, no import needed.
      if capability_service.can_produce_locally?(resource)
        tick_decisions << Decision.new(
          tick: tick, resource: resource,
          decision: 'LOCAL_ONLY',
          reason: "PrecursorCapabilityService confirms local production available",
          delta: delta
        )
        @decisions << tick_decisions.last
        next
      end

      # Resource cannot be produced locally -- check projected exhaustion.
      daily_consumption = (deltas[resource] >= 0) ? 0 : -deltas[resource]

      if daily_consumption <= 0 || current_stockpile <= 0
        # No consumption or no stockpile -- no import decision needed (or already exhausted).
        if current_stockpile <= 0 && daily_consumption > 0
          tick_decisions << Decision.new(
            tick: tick, resource: resource,
            decision: 'IMPORT',
            reason: "Stockpile exhausted (#{current_stockpile} kg), consumption rate #{daily_consumption.round(3)} kg/day",
            delta: delta
          )
          @decisions << tick_decisions.last
        else
          tick_decisions << Decision.new(
            tick: tick, resource: resource,
            decision: 'NO_IMPORT_NEEDED',
            reason: "No consumption or no stockpile to project",
            delta: delta
          )
          @decisions << tick_decisions.last
        end
        next
      end

      # Project days until exhaustion.
      days_until_exhaustion = current_stockpile / daily_consumption
      transit_days = Logistics::Contract::EARTH_LUNA_TRANSIT_DAYS rescue 3

      if days_until_exhaustion < transit_days
        # Import needed -- stockpile will run out before replacement arrives.
        cost_per_kg = Logistics::TransportCostService.calculate_cost_per_kg(from: 'earth', to: 'luna', resource: resource)
        tick_decisions << Decision.new(
          tick: tick, resource: resource,
          decision: 'IMPORT',
          reason: "Projected exhaustion before Earth->Luna transit (#{days_until_exhaustion.round(1)}d < #{transit_days}d)",
          delta: delta,
          cost_per_kg: cost_per_kg
        )
        @decisions << tick_decisions.last
      else
        tick_decisions << Decision.new(
          tick: tick, resource: resource,
          decision: 'LOCAL_ONLY',
          reason: "Stockpile sufficient for transit window (#{days_until_exhaustion.round(1)}d >= #{transit_days}d)",
          delta: delta
        )
        @decisions << tick_decisions.last
      end
    end

    tick_decisions
  end

  # ── Inventory Helpers ──
  def apply_production(inventory, resource, amount)
    inventory.add_item(resource, amount.to_i, settlement.owner || nil, { simulation: 'luna_operations' })
  end

  def apply_consumption(inventory, resource, amount)
    current = inventory.current_storage_of(resource)
    actual = [current, amount].min
    if actual > 0
      item = inventory.items.find_by(name: resource)
      if item
        item.amount -= actual
        item.amount <= 0 ? item.destroy : item.save!
      end
    end
  end
end
