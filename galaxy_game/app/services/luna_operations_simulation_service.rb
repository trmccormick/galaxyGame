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
  TRACKED_RESOURCES = %w[oxygen hydrogen water food regolith].freeze

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
      'water'  => population * ls['total_water_per_person_day'],
      'food'   => population * GameConstants::FOOD_PER_PERSON
    }
  end

  # ── Tier B: Blueprint Production ──
  def calculate_blueprint_production(inventory, capability_service)
    result = { feedstock_consumption: {} }

    # I-beam production: regolith -> 3D printed I-beam.
    # Recipe: 75 kg regolith -> 69 kg I-beam, 2 hr production.
    # Regolith is locally available on Luna (unlimited feedstock).
    if capability_service.can_produce_locally?('regolith')
      regolith_available = inventory.current_storage_of('regolith')
      if regolith_available >= 75
        ibeam_output = 69.0
        result['ibeam'] = ibeam_output
        result[:feedstock_consumption]['regolith'] = (result[:feedstock_consumption]['regolith'] || 0) + 75
        # NOTE: feedstock consumption is applied by the caller via feedstock_consumption iteration
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
