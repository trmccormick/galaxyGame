# app/services/ai_manager/foothold_planner.rb

# Resource-First Foothold Planner
# ================================
# Extends the established resource-first, world-agnostic design line:
#   - RESUPPLY_AND_ESCALATION_ARCHITECTURE.md  (state-based triggers, ISRU-first)
#   - AI_MANAGER_CONSTRUCTION_ECONOMICS.md     (local cost vs import, player-first)
#   - CYCLER_SYSTEM_ARCHITECTURE.md            (generic platform + data-driven fits)
#   - construction_system.md                   (generic regolith I-beam methodology)
#   - v2 task/phase registry                   (composable building blocks)
#
# This is NOT a new philosophy. It applies the same principles to initial foothold
# / system-entry planning — where the current pattern_name entry point handles poorly.

class AIManager::FootholdPlanner
  # Input contract: celestial body + system context snapshot.
  # No pattern_name required. The planner evaluates the body's actual resources,
  # moons/asteroids, accessibility, and logistics distance at runtime.
  #
  # @param celestial_body [CelestialBody] The target body to plan for
  # @param system_context [Hash] Optional system topology snapshot:
  #   :moons           => [Array<CelestialBody>] moons orbiting this body
  #   :asteroids       => [Array<Hash>] nearby asteroids with mass, composition, accessibility
  #   :distance_from_sun => [Float] AU (for transport cost estimation)
  #   :parent_body     => [CelestialBody, nil] if this body orbits another
  #   :nearby_nodes    => [Array<CelestialBody>] other settled/accessible bodies in the system
  def initialize(celestial_body, system_context: {})
    @celestial_body = celestial_body
    @system_context = system_context
    @capability_service = AIManager::PrecursorCapabilityService.new(celestial_body)
  end

  # Public entry point — returns ranked foothold options.
  #
  # @return [Array<FootholdOption>] Ranked list (best first)
  def plan
    raw_options = evaluate_all_patterns
    raw_options.sort_by { |opt| -opt[:score] }.map do |opt|
      FootholdOption.new(opt.merge(rationale: explain(opt)))
    end
  end

  # Lightweight check — can this body support ISRU at all?
  # @return [Boolean]
  def isru_feasible?
    @capability_service.isru_options.any?
  end

  # Expose local resources for caller-side decisions
  # @return [Array<String>]
  def local_resources
    @capability_service.local_resources
  end

  private

  # Evaluate all viable foothold patterns against the body + system snapshot.
  # Each pattern returns a plain hash (scored, not yet ranked).
  #
  # Patterns evaluated:
  #   surface_feature     — surface settlement on a geological feature (lava tube, crater, etc.)
  #   orbital_depot       — orbital depot leveraging nearby moons/asteroids
  #   captured_asteroid   — move small asteroid into orbit and convert it
  #   atmospheric         — atmospheric settlement (Venus-style floating platform)
  #   subsurface          — subsurface ice/water resource exploitation
  #   hybrid              — multi-location composition (surface + orbital depot)
  def evaluate_all_patterns
    patterns = []

    patterns << evaluate_surface_feature if surface_feasible?
    patterns << evaluate_orbital_depot if orbital_depot_feasible?
    patterns << evaluate_captured_asteroid if captured_asteroid_feasible?
    patterns << evaluate_atmospheric if atmospheric_feasible?
    patterns << evaluate_subsurface if subsurface_feasible?
    patterns << evaluate_hybrid(patterns) if hybrid_feasible?(patterns)

    patterns.compact
  end

  # --- Pattern evaluators (thin — score only, no full implementation) ---

  def evaluate_surface_feature
    return nil unless surface_feasible?

    has_regolith = @capability_service.has_regolith?
    local_res_count = @capability_service.local_resources.size
    isru_options = @capability_service.isru_options.size

    score = (local_res_count * 10) + (isru_options * 15) + (has_regolith ? 20 : 0)

    {
      pattern: :surface_feature,
      location_type: :surface,
      score: score,
      preferred_location: geological_preference,
      task_sequence: surface_task_sequence,
      local_vs_import_bias: compute_local_import_bias(local_res_count),
      rationale: "Surface settlement leveraging #{local_res_count} local resources"
    }
  end

  def evaluate_orbital_depot
    return nil unless orbital_depot_feasible?

    moons = @system_context[:moons] || []
    moon_count = moons.size
    # More moons = more depot value (transfer points, resource diversity)
    score = moon_count * 25

    # Bonus if the body itself has valuable resources to export from orbit
    score += 30 if @capability_service.local_resources.any? { |r| %w[He3 regolith O2].include?(r) }

    {
      pattern: :orbital_depot,
      location_type: :orbital_depot,
      score: score,
      preferred_location: "Orbital — leveraging #{moon_count} moon(s)",
      task_sequence: orbital_task_sequence(moon_count),
      local_vs_import_bias: :moderate_local,
      rationale: "Orbital depot with #{moon_count} transfer point(s)"
    }
  end

  def evaluate_captured_asteroid
    return nil unless captured_asteroid_feasible?

    asteroids = (@system_context[:asteroids] || [])
    viable = asteroids.select { |a| a[:mass].to_f > 100 && accessible?(a) }

    return nil if viable.empty?

    score = viable.size * 35
    # Bonus for composition diversity (more ISRU pathways)
    viable.each do |ast|
      score += 10 if ast[:composition]&.any? { |c| %w[H2O CO2 Fe Ni].include?(c) }
    end

    {
      pattern: :captured_asteroid,
      location_type: :orbital_depot,
      score: score,
      preferred_location: "Captured asteroid in orbit",
      task_sequence: captured_asteroid_sequence(viable.size),
      local_vs_import_bias: :high_local,
      rationale: "#{viable.size} viable asteroid(s) for capture and conversion"
    }
  end

  def evaluate_atmospheric
    return nil unless atmospheric_feasible?

    atmo = @celestial_body.atmosphere
    return nil unless atmo

    pressure = atmo.pressure.to_f
    co2_pct = atmo.gas_percentage('CO2').to_f
    n2_pct = atmo.gas_percentage('N2').to_f

    # Score based on atmosphere density and useful gas content
    score = (pressure * 5) + (co2_pct * 10) + (n2_pct * 8)

    {
      pattern: :atmospheric,
      location_type: :atmospheric,
      score: score,
      preferred_location: "Floating platform in upper atmosphere",
      task_sequence: atmospheric_task_sequence(co2_pct > 0.01, n2_pct > 0.01),
      local_vs_import_bias: compute_atmospheric_bias(co2_pct, n2_pct),
      rationale: "Atmosphere supports CO2 extraction (#{co2_pct > 0.01}) and N2 extraction (#{n2_pct > 0.01})"
    }
  end

  def evaluate_subsurface
    return nil unless subsurface_feasible?

    has_water = @capability_service.can_extract_water?
    has_ocean = @celestial_body.hydrosphere&.water_bodies&.present?

    score = (has_water ? 40 : 0) + (has_ocean ? 30 : 0)

    {
      pattern: :subsurface,
      location_type: :subsurface,
      score: score,
      preferred_location: "Subsurface ice/water deposit",
      task_sequence: subsurface_task_sequence(has_water),
      local_vs_import_bias: compute_subsurface_bias(has_water, has_ocean),
      rationale: has_ocean ? "Subsurface ocean detected" : "Subsurface water/volatiles available"
    }
  end

  def evaluate_hybrid(original_patterns)
    return nil if original_patterns.size < 2

    # Hybrid is viable when at least 2 distinct patterns scored above threshold
    viable_scores = original_patterns.map { |p| p[:score] }.select { |s| s > 15 }
    return nil if viable_scores.size < 2

    score = viable_scores.sum * 0.6 # Hybrid scores lower than best single pattern (complexity penalty)

    {
      pattern: :hybrid,
      location_type: :multi_location,
      score: score,
      preferred_location: "Multi-location (surface + orbital)",
      task_sequence: hybrid_task_sequence(viable_scores.size),
      local_vs_import_bias: :high_local,
      rationale: "Hybrid approach combining #{viable_scores.size} viable patterns"
    }
  end

  # --- Feasibility checks ---

  def surface_feasible?
    @celestial_body.has_solid_surface?
  end

  def orbital_depot_feasible?
    # Orbital depot is always technically feasible; score reflects value
    true
  end

  def captured_asteroid_feasible?
    asteroids = @system_context[:asteroids] || []
    asteroids.any? { |a| a[:mass].to_f > 100 }
  end

  def atmospheric_feasible?
    @celestial_body.atmosphere&.pressure&.to_f&.>(0.001) || false
  end

  def subsurface_feasible?
    @capability_service.can_extract_water? ||
      @celestial_body.hydrosphere&.water_bodies&.present?
  end

  def hybrid_feasible?(patterns)
    patterns.count { |p| p && p[:score] > 15 } >= 2
  end

  # --- Helpers ---

  def geological_preference
    return "Lava tube" if @celestial_body.respond_to?(:lava_tubes) && @celestial_body.lava_tubes.any?
    return "Crater" if @celestial_body.respond_to?(:craters) && @celestial_body.craters.any?
    return "Valley" if @celestial_body.respond_to?(:valleys) && @celestial_body.valleys.any?
    "Flat terrain near resource deposit"
  end

  def accessible?(asteroid)
    # Simple accessibility heuristic: mass < 1e12 kg and not too far from parent body
    asteroid[:mass].to_f < 1e12
  end

  def compute_local_import_bias(local_res_count)
    case local_res_count
    when 8..Float::INFINITY then :very_high_local
    when 5..7               then :high_local
    when 3..4               then :moderate_local
    else                         :low_local
    end
  end

  def compute_atmospheric_bias(co2_pct, n2_pct)
    if co2_pct > 0.1 && n2_pct > 0.01
      :very_high_local
    elsif co2_pct > 0.01 || n2_pct > 0.01
      :moderate_local
    else
      :low_local
    end
  end

  def compute_subsurface_bias(has_water, has_ocean)
    has_ocean ? :very_high_local : (has_water ? :high_local : :low_local)
  end

  # --- Task sequence builders (v2-style task_ref references) ---

  def surface_task_sequence
    [
      { phase: "site_prep_foundation", tasks: ["deploy_regolith_harvester_rover"] },
      { phase: "power_comms", tasks: ["deploy_solar_rig", "deploy_puh_and_ppmu", "deploy_comms_equipment"] },
      { phase: "isru_deployment", tasks: ["deploy_lspu", "deploy_gas_separator", "deploy_pve_unit"] }
    ]
  end

  def orbital_task_sequence(moon_count)
    seq = [{ phase: "orbital_survey", tasks: ["deploy_orbital_sensors"] }]
    if moon_count > 0
      seq << { phase: "moon_access", tasks: ["deploy_transfer_vehicles", "establish_moon_landing_pad"] }
    end
    seq << { phase: "depot_construction", tasks: ["print_inflatable_tank_shells", "deploy_docking_ports"] }
    seq
  end

  def captured_asteroid_sequence(count)
    [
      { phase: "asteroid_survey", tasks: ["deploy_probes", "determine_orbit_and_composition"] },
      { phase: "capture_operation", tasks: ["deploy_tug_vehicles", "apply_gravity_tether"] },
      { phase: "hollowing", tasks: ["deploy_hollowing_equipment", "extract_propellant"] },
      { phase: "depot_conversion", tasks: ["pressurize_hollowed_core", "deploy_solar_arrays"] }
    ]
  end

  def atmospheric_task_sequence(has_co2, has_n2)
    seq = [{ phase: "atmospheric_probe", tasks: ["deploy_aerostats", "map_wind_and_density_profile"] }]
    seq << { phase: "platform_deployment", tasks: ["deploy_floating_platform", "anchor_stabilization"] }
    if has_co2
      seq << { phase: "co2_processing", tasks: ["deploy_atmospheric_processor", "deploy_gas_separator"] }
    end
    if has_n2
      seq << { phase: "n2_processing", tasks: ["deploy_nitrogen_extractor"] }
    end
    seq
  end

  def subsurface_task_sequence(has_water)
    seq = [{ phase: "subsurface_survey", tasks: ["deploy_radar_probes", "map_ice_deposits"] }]
    if has_water
      seq << { phase: "water_extraction", tasks: ["deploy_drilling_unit", "deploy_pve_unit"] }
    end
    seq
  end

  def hybrid_task_sequence(count)
    surface_seq = surface_task_sequence
    orbital_seq = orbital_task_sequence(@system_context[:moons]&.size || 0)
    [
      { phase: "surface_phase", tasks: surface_seq.first(2).flat_map { |p| p[:tasks] } },
      { phase: "orbital_phase", tasks: orbital_seq.first(2).flat_map { |p| p[:tasks] } },
      { phase: "integration", tasks: ["establish_surface_orbital_link"] }
    ]
  end

  def explain(pattern)
    case pattern[:pattern]
    when :surface_feature
      "Surface settlement on #{geological_preference} — highest local resource leverage"
    when :orbital_depot
      "Orbital depot — leverages #{(@system_context[:moons] || []).size} moon(s) as transfer points"
    when :captured_asteroid
      "Captured asteroid conversion — provides mobile, customizable habitat with local resources"
    when :atmospheric
      "Atmospheric platform — free gas extraction from dense atmosphere"
    when :subsurface
      "Subsurface exploitation — direct access to water/ice deposits"
    when :hybrid
      "Multi-location approach — combines surface and orbital for maximum flexibility"
    else
      pattern[:rationale]
    end
  end

  # Public data class for planner output
  FootholdOption = Struct.new(
    :pattern,
    :location_type,
    :score,
    :preferred_location,
    :task_sequence,
    :local_vs_import_bias,
    :rationale,
    keyword_init: true
  ) do
    def to_h
      to_hash
    end
  end
end
