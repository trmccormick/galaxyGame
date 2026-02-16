# app/services/ai_manager/station_construction_strategy.rb
module AIManager
  class StationConstructionStrategy
    attr_reader :shared_context

    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Main method to determine optimal station construction strategy
    def determine_optimal_station_strategy(target_system, strategic_purpose, available_resources = {})
      Rails.logger.info "[StationConstructionStrategy] Analyzing station construction strategy for #{target_system[:identifier]}"

      # Analyze local resources and conditions
      resource_analysis = analyze_local_resources(target_system)

      # Evaluate strategic requirements
      strategic_requirements = evaluate_strategic_requirements(strategic_purpose, target_system)

      # Generate construction options
      construction_options = generate_construction_options(resource_analysis, strategic_requirements)

      # Select optimal strategy using cost-benefit analysis
      cost_benefit_analyzer = AIManager::StationCostBenefitAnalyzer.new(@shared_context)
      optimal_strategy = cost_benefit_analyzer.select_optimal_strategy(
        construction_options,
        available_resources,
        strategic_requirements
      )

      # Generate implementation plan
      implementation_plan = generate_implementation_plan(optimal_strategy[:optimal_strategy], target_system)

      {
        optimal_strategy: optimal_strategy,
        construction_options: construction_options,
        resource_analysis: resource_analysis,
        strategic_requirements: strategic_requirements,
        implementation_plan: implementation_plan,
        risk_assessment: assess_implementation_risks(optimal_strategy[:optimal_strategy], target_system)
      }
    end

    # Evaluate station type suitability for specific purposes
    def evaluate_station_type_suitability(station_type, strategic_purpose, target_system)
      suitability_score = 0
      reasoning = []

      case strategic_purpose
      when :wormhole_anchor
        suitability_score += evaluate_wormhole_anchor_suitability(station_type, target_system)
        reasoning << "Wormhole anchoring capabilities"
      when :resource_processing
        suitability_score += evaluate_resource_processing_suitability(station_type, target_system)
        reasoning << "Resource processing and ISRU capabilities"
      when :defensive_position
        suitability_score += evaluate_defensive_suitability(station_type, target_system)
        reasoning << "Defensive positioning and military capabilities"
      when :trade_hub
        suitability_score += evaluate_trade_hub_suitability(station_type, target_system)
        reasoning << "Trade and logistics capabilities"
      when :research_outpost
        suitability_score += evaluate_research_suitability(station_type, target_system)
        reasoning << "Research and scientific capabilities"
      end

      # Factor in construction feasibility
      construction_feasibility = assess_construction_feasibility(station_type, target_system)
      suitability_score *= construction_feasibility[:feasibility_multiplier]

      {
        suitability_score: suitability_score,
        reasoning: reasoning,
        construction_feasibility: construction_feasibility,
        recommended_modifications: suggest_modifications(station_type, strategic_purpose)
      }
    end

    private

    def analyze_local_resources(target_system)
      # Analyze available resources for station construction
      celestial_bodies = target_system['celestial_bodies'] || target_system[:celestial_bodies] || {}

      resource_inventory = {
        asteroids: [],
        moons: [],
        planets: [],
        construction_materials: {},
        energy_sources: []
      }

      # Analyze asteroids for conversion potential
      asteroids = celestial_bodies['asteroids'] || celestial_bodies[:asteroids] || []
      if asteroids.is_a?(Array)
        asteroids.each do |asteroid|
          asteroid_analysis = analyze_asteroid_for_construction(asteroid)
          resource_inventory[:asteroids] << asteroid_analysis if asteroid_analysis[:suitable_for_conversion]
        end
      end

      # Analyze moons for potential station sites
      ['moons', 'ice_moons', 'rocky_moons'].each do |moon_type|
        moons = celestial_bodies[moon_type] || celestial_bodies[moon_type.to_sym] || []
        next unless moons.is_a?(Array)
        moons.each do |moon|
          moon_analysis = analyze_moon_for_station(moon)
          resource_inventory[:moons] << moon_analysis
        end
      end

      # Analyze planets for orbital construction
      planets = celestial_bodies['planets'] || celestial_bodies[:planets] || []
      if planets.is_a?(Array)
        planets.each do |planet|
          planet_analysis = analyze_planet_for_orbital_construction(planet)
          resource_inventory[:planets] << planet_analysis
        end
      end

      # Calculate aggregate resource availability
      resource_inventory[:aggregate_score] = calculate_aggregate_resource_score(resource_inventory)

      resource_inventory
    end

    def evaluate_strategic_requirements(strategic_purpose, target_system)
      requirements = {
        purpose: strategic_purpose,
        timeline_requirements: {},
        capability_requirements: [],
        risk_tolerance: :medium,
        scalability_needs: :medium
      }

      case strategic_purpose
      when :wormhole_anchor
        requirements[:capability_requirements] = [:wormhole_stabilization, :energy_generation, :defensive_systems]
        requirements[:timeline_requirements] = { critical: 6.months, optimal: 3.months }
        requirements[:risk_tolerance] = :low
        requirements[:scalability_needs] = :high
      when :resource_processing
        requirements[:capability_requirements] = [:isru_facilities, :processing_capacity, :storage_systems]
        requirements[:timeline_requirements] = { critical: 12.months, optimal: 8.months }
        requirements[:risk_tolerance] = :medium
        requirements[:scalability_needs] = :high
      when :defensive_position
        requirements[:capability_requirements] = [:weapon_systems, :sensor_arrays, :rapid_deployment]
        requirements[:timeline_requirements] = { critical: 3.months, optimal: 1.months }
        requirements[:risk_tolerance] = :low
        requirements[:scalability_needs] = :medium
      when :trade_hub
        requirements[:capability_requirements] = [:docking_facilities, :marketplace, :logistics_coordination]
        requirements[:timeline_requirements] = { critical: 9.months, optimal: 6.months }
        requirements[:risk_tolerance] = :medium
        requirements[:scalability_needs] = :high
      when :research_outpost
        requirements[:capability_requirements] = [:laboratory_facilities, :sensor_arrays, :data_processing]
        requirements[:timeline_requirements] = { critical: 18.months, optimal: 12.months }
        requirements[:risk_tolerance] = :high
        requirements[:scalability_needs] = :low
      end

      # Adjust based on system characteristics
      requirements.merge!(adjust_requirements_for_system(target_system))

      requirements
    end

    def generate_construction_options(resource_analysis, strategic_requirements)
      options = []

      # Option 1: Full space station construction
      options << generate_full_station_option(resource_analysis, strategic_requirements)

      # Option 2: Asteroid conversion
      resource_analysis[:asteroids].each do |asteroid|
        options << generate_asteroid_conversion_option(asteroid, strategic_requirements)
      end

      # Option 3: Lunar surface station
      resource_analysis[:moons].each do |moon|
        options << generate_lunar_station_option(moon, strategic_requirements)
      end

      # Option 4: Orbital construction around planets
      resource_analysis[:planets].each do |planet|
        options << generate_orbital_station_option(planet, strategic_requirements)
      end

      # Option 5: Hybrid approaches
      options << generate_hybrid_construction_option(resource_analysis, strategic_requirements)

      options
    end

    def generate_implementation_plan(optimal_strategy, target_system)
      plan = {
        phases: [],
        resource_requirements: {},
        timeline: {},
        risk_mitigation: [],
        contingency_plans: []
      }

      case optimal_strategy[:construction_type]
      when :full_space_station
        plan = generate_full_station_implementation_plan(optimal_strategy, target_system)
      when :asteroid_conversion
        plan = generate_asteroid_conversion_implementation_plan(optimal_strategy, target_system)
      when :lunar_surface_station
        plan = generate_lunar_implementation_plan(optimal_strategy, target_system)
      when :orbital_construction
        plan = generate_orbital_implementation_plan(optimal_strategy, target_system)
      when :hybrid_approach
        plan = generate_hybrid_implementation_plan(optimal_strategy, target_system)
      end

      plan
    end

    def assess_implementation_risks(optimal_strategy, target_system)
      risks = {
        technical_risks: [],
        resource_risks: [],
        timeline_risks: [],
        environmental_risks: [],
        overall_risk_level: :low
      }

      # Assess technical risks
      risks[:technical_risks] = assess_technical_risks(optimal_strategy)

      # Assess resource availability risks
      risks[:resource_risks] = assess_resource_risks(optimal_strategy, target_system)

      # Assess timeline risks
      risks[:timeline_risks] = assess_timeline_risks(optimal_strategy)

      # Assess environmental risks
      risks[:environmental_risks] = assess_environmental_risks(optimal_strategy, target_system)

      # Calculate overall risk level
      risks[:overall_risk_level] = calculate_overall_risk_level(risks)

      risks
    end

    # Helper methods for analysis
    def analyze_asteroid_for_construction(asteroid)
      {
        id: asteroid['id'] || asteroid[:id],
        name: asteroid['name'] || asteroid[:name],
        size: asteroid['diameter_km'] || asteroid[:diameter_km] || 1.0,
        composition: asteroid['composition'] || asteroid[:composition] || 'unknown',
        suitable_for_conversion: is_suitable_for_asteroid_conversion?(asteroid),
        conversion_complexity: calculate_conversion_complexity(asteroid),
        resource_value: calculate_asteroid_resource_value(asteroid),
        stability_rating: assess_asteroid_stability(asteroid)
      }
    end

    def analyze_moon_for_station(moon)
      {
        id: moon['id'] || moon[:id],
        name: moon['name'] || moon[:name],
        parent_body: moon['parent_body'] || moon[:parent_body],
        gravity: moon['gravity_m_s2'] || moon[:gravity_m_s2] || 0.0,
        atmosphere: moon['atmosphere'] || moon[:atmosphere] || 'none',
        resources: moon['resources'] || moon[:resources] || [],
        surface_suitability: assess_moon_surface_suitability(moon),
        orbital_characteristics: analyze_moon_orbit(moon)
      }
    end

    def analyze_planet_for_orbital_construction(planet)
      {
        id: planet['id'] || planet[:id],
        name: planet['name'] || planet[:name],
        type: planet['type'] || planet[:type],
        gravity: planet['gravity_m_s2'] || planet[:gravity_m_s2],
        atmosphere_density: planet['atmosphere_density'] || planet[:atmosphere_density] || 0.0,
        orbital_stability: assess_orbital_stability(planet),
        radiation_environment: assess_radiation_environment(planet),
        construction_complexity: calculate_orbital_construction_complexity(planet)
      }
    end

    # Construction option generators
    def generate_full_station_option(resource_analysis, strategic_requirements)
      {
        construction_type: :full_space_station,
        name: 'Full Space Station Construction',
        description: 'Construct a complete space station from prefabricated components',
        estimated_cost: calculate_full_station_cost(strategic_requirements),
        construction_time: calculate_full_station_construction_time(strategic_requirements),
        capability_score: calculate_capability_score(:full_space_station, strategic_requirements),
        risk_level: :medium,
        scalability: :high,
        resource_requirements: calculate_full_station_resources(strategic_requirements),
        advantages: ['High customization', 'Proven technology', 'Flexible positioning'],
        disadvantages: ['High initial cost', 'Long construction time', 'Resource intensive']
      }
    end

    def generate_asteroid_conversion_option(asteroid, strategic_requirements)
      {
        construction_type: :asteroid_conversion,
        name: "Asteroid Conversion - #{asteroid[:name]}",
        description: "Convert asteroid #{asteroid[:name]} into a functional space station",
        asteroid_data: asteroid,
        estimated_cost: calculate_asteroid_conversion_cost(asteroid, strategic_requirements),
        construction_time: calculate_asteroid_conversion_time(asteroid, strategic_requirements),
        capability_score: calculate_capability_score(:asteroid_conversion, strategic_requirements),
        risk_level: assess_asteroid_conversion_risk(asteroid),
        scalability: :medium,
        resource_requirements: calculate_asteroid_conversion_resources(asteroid, strategic_requirements),
        advantages: ['Cost effective', 'Natural radiation shielding', 'Resource rich'],
        disadvantages: ['Structural integrity concerns', 'Limited expansion potential', 'Orbital adjustments required']
      }
    end

    def generate_lunar_station_option(moon, strategic_requirements)
      {
        construction_type: :lunar_surface_station,
        name: "Lunar Surface Station - #{moon[:name]}",
        description: "Construct station on the surface of #{moon[:name]}",
        moon_data: moon,
        estimated_cost: calculate_lunar_station_cost(moon, strategic_requirements),
        construction_time: calculate_lunar_station_construction_time(moon, strategic_requirements),
        capability_score: calculate_capability_score(:lunar_surface_station, strategic_requirements),
        risk_level: :low,
        scalability: :high,
        resource_requirements: calculate_lunar_station_resources(moon, strategic_requirements),
        advantages: ['Stable surface', 'Resource access', 'Radiation protection'],
        disadvantages: ['Gravity well', 'Dust contamination', 'Thermal extremes']
      }
    end

    def generate_orbital_station_option(planet, strategic_requirements)
      {
        construction_type: :orbital_construction,
        name: "Orbital Station - #{planet[:name]}",
        description: "Construct station in orbit around #{planet[:name]}",
        planet_data: planet,
        estimated_cost: calculate_orbital_station_cost(planet, strategic_requirements),
        construction_time: calculate_orbital_station_construction_time(planet, strategic_requirements),
        capability_score: calculate_capability_score(:orbital_construction, strategic_requirements),
        risk_level: assess_orbital_construction_risk(planet),
        scalability: :high,
        resource_requirements: calculate_orbital_station_resources(planet, strategic_requirements),
        advantages: ['Strategic positioning', 'Easy access', 'Communication advantages'],
        disadvantages: ['Orbital decay', 'Radiation exposure', 'Debris risks']
      }
    end

    def generate_hybrid_construction_option(resource_analysis, strategic_requirements)
      {
        construction_type: :hybrid_approach,
        name: 'Hybrid Construction Approach',
        description: 'Combine multiple construction methods for optimal results',
        estimated_cost: calculate_hybrid_cost(resource_analysis, strategic_requirements),
        construction_time: calculate_hybrid_construction_time(resource_analysis, strategic_requirements),
        capability_score: calculate_capability_score(:hybrid_approach, strategic_requirements),
        risk_level: :medium,
        scalability: :high,
        resource_requirements: calculate_hybrid_resources(resource_analysis, strategic_requirements),
        advantages: ['Risk mitigation', 'Resource optimization', 'Flexibility'],
        disadvantages: ['Complex coordination', 'Higher management overhead']
      }
    end

    # Implementation plan generators
    def generate_full_station_implementation_plan(strategy, target_system)
      {
        phases: [
          { name: 'Site Selection', duration: 1.month, resources: ['survey_craft'] },
          { name: 'Component Manufacturing', duration: 4.months, resources: ['industrial_capacity'] },
          { name: 'Assembly Phase 1', duration: 2.months, resources: ['construction_crew', 'assembly_equipment'] },
          { name: 'Systems Integration', duration: 3.months, resources: ['technical_crew', 'testing_equipment'] },
          { name: 'Final Assembly', duration: 1.month, resources: ['construction_crew'] }
        ],
        resource_requirements: strategy[:resource_requirements],
        timeline: { total_duration: 11.months, critical_path: ['Component Manufacturing', 'Systems Integration'] },
        risk_mitigation: ['Redundant systems', 'Quality assurance protocols', 'Backup components'],
        contingency_plans: ['Alternative assembly locations', 'Component substitution protocols']
      }
    end

    def generate_asteroid_conversion_implementation_plan(strategy, target_system)
      asteroid = strategy[:asteroid_data]
      {
        phases: [
          { name: 'Asteroid Assessment', duration: 2.weeks, resources: ['survey_craft', 'geological_team'] },
          { name: 'Structural Reinforcement', duration: 2.months, resources: ['construction_crew', 'reinforcement_materials'] },
          { name: 'Interior Excavation', duration: 3.months, resources: ['mining_equipment', 'excavation_crew'] },
          { name: 'Systems Installation', duration: 4.months, resources: ['technical_crew', 'station_components'] },
          { name: 'Orbital Adjustment', duration: 1.month, resources: ['propulsion_systems'] }
        ],
        resource_requirements: strategy[:resource_requirements],
        timeline: { total_duration: 10.months, critical_path: ['Interior Excavation', 'Systems Installation'] },
        risk_mitigation: ['Structural integrity monitoring', 'Emergency evacuation protocols'],
        contingency_plans: ['Alternative asteroid selection', 'Full station construction fallback']
      }
    end

    # Utility methods
    def is_suitable_for_asteroid_conversion?(asteroid)
      size = asteroid['diameter_km'] || asteroid[:diameter_km] || 0
      composition = asteroid['composition'] || asteroid[:composition] || 'unknown'

      size >= 0.5 && size <= 5.0 && ['stony', 'metallic', 'carbonaceous'].include?(composition.downcase)
    end

    def calculate_conversion_complexity(asteroid)
      size = asteroid['diameter_km'] || asteroid[:diameter_km] || 1.0
      composition = asteroid['composition'] || asteroid[:composition] || 'unknown'

      complexity = 1.0

      # Size complexity
      complexity *= (size / 2.0) if size < 2.0
      complexity *= 1.5 if size > 3.0

      # Composition complexity
      complexity *= 1.3 if composition.downcase == 'carbonaceous'
      complexity *= 1.2 if composition.downcase == 'metallic'

      complexity
    end

    def calculate_asteroid_resource_value(asteroid)
      resources = asteroid['resources'] || asteroid[:resources] || []
      value = 0

      resources.each do |resource|
        case resource.downcase
        when 'iron', 'nickel', 'cobalt'
          value += 100
        when 'platinum', 'gold', 'rare_earths'
          value += 500
        when 'water_ice', 'carbon'
          value += 50
        end
      end

      value
    end

    def assess_asteroid_stability(asteroid)
      # Simplified stability assessment
      rotation_period = asteroid['rotation_period_hours'] || asteroid[:rotation_period_hours] || 24
      shape = asteroid['shape'] || asteroid[:shape] || 'irregular'

      stability = 1.0
      stability *= 0.8 if rotation_period < 2 || rotation_period > 100
      stability *= 0.9 if shape == 'irregular'

      stability
    end

    def assess_moon_surface_suitability(moon)
      gravity = moon['gravity_m_s2'] || moon[:gravity_m_s2] || 0.0
      atmosphere = moon['atmosphere'] || moon[:atmosphere] || 'none'

      suitability = 1.0
      suitability *= 0.7 if gravity > 0.5  # Too much gravity
      suitability *= 1.2 if gravity < 0.1  # Low gravity advantage
      suitability *= 0.8 if atmosphere != 'none'  # Atmosphere can complicate construction

      suitability
    end

    def analyze_moon_orbit(moon)
      orbital_period = moon['orbital_period_days'] || moon[:orbital_period_days] || 30
      eccentricity = moon['orbital_eccentricity'] || moon[:orbital_eccentricity] || 0.0

      {
        period_days: orbital_period,
        eccentricity: eccentricity,
        stability: calculate_orbital_stability(orbital_period, eccentricity)
      }
    end

    def calculate_orbital_stability(period, eccentricity)
      stability = 1.0
      stability *= 0.9 if eccentricity > 0.1
      stability *= 0.95 if period < 10 || period > 100

      stability
    end

    def assess_orbital_stability(planet)
      # Simplified orbital stability assessment
      type = planet['type'] || planet[:type] || 'terrestrial'

      case type.downcase
      when 'gas_giant', 'ice_giant'
        0.8  # More complex orbital mechanics
      when 'terrestrial'
        0.95  # Generally stable
      else
        0.9
      end
    end

    def assess_radiation_environment(planet)
      type = planet['type'] || planet[:type] || 'terrestrial'
      magnetic_field = planet['magnetic_field_strength'] || planet[:magnetic_field_strength] || 0.0

      radiation_level = 1.0
      radiation_level *= 1.5 if type.downcase == 'gas_giant' && magnetic_field < 0.5
      radiation_level *= 0.7 if magnetic_field > 1.0

      radiation_level
    end

    def calculate_orbital_construction_complexity(planet)
      stability = assess_orbital_stability(planet)
      radiation = assess_radiation_environment(planet)

      complexity = 1.0 / (stability * (1.0 / radiation))  # Higher radiation increases complexity

      complexity.clamp(0.5, 2.0)
    end

    # Cost calculation methods
    def calculate_full_station_cost(strategic_requirements)
      base_cost = 100_000_000  # Base cost in credits

      # Adjust based on strategic requirements
      case strategic_requirements[:purpose]
      when :wormhole_anchor
        base_cost *= 1.5
      when :defensive_position
        base_cost *= 1.3
      when :research_outpost
        base_cost *= 0.8
      end

      base_cost
    end

    def calculate_asteroid_conversion_cost(asteroid, strategic_requirements)
      base_cost = 50_000_000  # Base conversion cost
      complexity_multiplier = calculate_conversion_complexity(asteroid)

      base_cost * complexity_multiplier
    end

    def calculate_lunar_station_cost(moon, strategic_requirements)
      base_cost = 75_000_000
      gravity_penalty = moon[:gravity] > 0.3 ? 1.2 : 1.0

      base_cost * gravity_penalty
    end

    def calculate_orbital_station_cost(planet, strategic_requirements)
      base_cost = 90_000_000
      complexity_multiplier = calculate_orbital_construction_complexity(planet)

      base_cost * complexity_multiplier
    end

    def calculate_hybrid_cost(resource_analysis, strategic_requirements)
      # Average of available options
      options = [calculate_full_station_cost(strategic_requirements)]
      options += resource_analysis[:asteroids].map { |a| calculate_asteroid_conversion_cost(a, strategic_requirements) }
      options += resource_analysis[:moons].map { |m| calculate_lunar_station_cost(m, strategic_requirements) }
      options += resource_analysis[:planets].map { |p| calculate_orbital_station_cost(p, strategic_requirements) }

      options.sum / options.length * 1.1  # 10% overhead for hybrid approach
    end

    # Time calculation methods
    def calculate_full_station_construction_time(strategic_requirements)
      base_time = 11.months

      case strategic_requirements[:purpose]
      when :defensive_position
        base_time * 0.7  # Faster for defensive purposes
      when :research_outpost
        base_time * 1.2  # Longer for research facilities
      else
        base_time
      end
    end

    def calculate_asteroid_conversion_time(asteroid, strategic_requirements)
      base_time = 10.months
      complexity_multiplier = calculate_conversion_complexity(asteroid)

      base_time * complexity_multiplier
    end

    def calculate_lunar_station_construction_time(moon, strategic_requirements)
      base_time = 8.months
      gravity_penalty = moon[:gravity] > 0.3 ? 1.3 : 1.0

      base_time * gravity_penalty
    end

    def calculate_orbital_station_construction_time(planet, strategic_requirements)
      base_time = 9.months
      complexity_multiplier = calculate_orbital_construction_complexity(planet)

      base_time * complexity_multiplier
    end

    def calculate_hybrid_construction_time(resource_analysis, strategic_requirements)
      # Parallel construction reduces total time
      options_times = [
        calculate_full_station_construction_time(strategic_requirements),
        *resource_analysis[:asteroids].map { |a| calculate_asteroid_conversion_time(a, strategic_requirements) },
        *resource_analysis[:moons].map { |m| calculate_lunar_station_construction_time(m, strategic_requirements) },
        *resource_analysis[:planets].map { |p| calculate_orbital_station_construction_time(p, strategic_requirements) }
      ]

      # Take the minimum time (parallel execution) plus 20% coordination overhead
      (options_times.min * 1.2)
    end

    # Capability scoring
    def calculate_capability_score(construction_type, strategic_requirements)
      base_score = 50

      capability_matches = strategic_requirements[:capability_requirements].count do |req|
        case construction_type
        when :full_space_station
          true  # Full stations can handle most requirements
        when :asteroid_conversion
          [:isru_facilities, :storage_systems].include?(req)
        when :lunar_surface_station
          [:isru_facilities, :research_facilities].include?(req)
        when :orbital_construction
          [:defensive_systems, :sensor_arrays, :docking_facilities].include?(req)
        when :hybrid_approach
          true  # Hybrid can adapt to requirements
        end
      end

      base_score + (capability_matches * 20)
    end

    # Risk assessment methods
    def assess_asteroid_conversion_risk(asteroid)
      stability = assess_asteroid_stability(asteroid)
      complexity = calculate_conversion_complexity(asteroid)

      risk_score = (1.0 - stability) + (complexity - 1.0)
      risk_score > 0.7 ? :high : risk_score > 0.4 ? :medium : :low
    end

    def assess_orbital_construction_risk(planet)
      stability = assess_orbital_stability(planet)
      radiation = assess_radiation_environment(planet)

      risk_score = (1.0 - stability) + (radiation - 1.0)
      risk_score > 0.6 ? :high : risk_score > 0.3 ? :medium : :low
    end

    # Resource requirement calculations
    def calculate_full_station_resources(strategic_requirements)
      {
        materials: { steel: 50000, aluminum: 30000, electronics: 10000, life_support: 5000 },
        personnel: { engineers: 50, technicians: 100, construction_crew: 200 },
        equipment: { assembly_rigs: 5, transport_crafts: 10, testing_equipment: 20 }
      }
    end

    def calculate_asteroid_conversion_resources(asteroid, strategic_requirements)
      complexity = calculate_conversion_complexity(asteroid)
      {
        materials: {
          steel: (20000 * complexity).to_i,
          aluminum: (15000 * complexity).to_i,
          explosives: (5000 * complexity).to_i,
          life_support: (3000 * complexity).to_i
        },
        personnel: {
          engineers: (30 * complexity).to_i,
          technicians: (60 * complexity).to_i,
          mining_crew: (100 * complexity).to_i
        },
        equipment: {
          mining_equipment: (3 * complexity).to_i,
          excavation_rigs: (2 * complexity).to_i,
          structural_reinforcements: (10 * complexity).to_i
        }
      }
    end

    def calculate_lunar_station_resources(moon, strategic_requirements)
      gravity_factor = moon[:gravity] > 0.3 ? 1.3 : 1.0
      {
        materials: {
          steel: (40000 * gravity_factor).to_i,
          concrete: (60000 * gravity_factor).to_i,
          electronics: (8000 * gravity_factor).to_i,
          life_support: (4000 * gravity_factor).to_i
        },
        personnel: {
          engineers: (40 * gravity_factor).to_i,
          technicians: (80 * gravity_factor).to_i,
          construction_crew: (150 * gravity_factor).to_i
        },
        equipment: {
          construction_vehicles: (8 * gravity_factor).to_i,
          habitat_modules: (20 * gravity_factor).to_i,
          power_generators: (5 * gravity_factor).to_i
        }
      }
    end

    def calculate_orbital_station_resources(planet, strategic_requirements)
      complexity = calculate_orbital_construction_complexity(planet)
      {
        materials: {
          steel: (45000 * complexity).to_i,
          aluminum: (25000 * complexity).to_i,
          composites: (15000 * complexity).to_i,
          electronics: (12000 * complexity).to_i
        },
        personnel: {
          engineers: (45 * complexity).to_i,
          technicians: (90 * complexity).to_i,
          assembly_crew: (120 * complexity).to_i
        },
        equipment: {
          assembly_rigs: (4 * complexity).to_i,
          transport_crafts: (8 * complexity).to_i,
          orbital_tugs: (3 * complexity).to_i
        }
      }
    end

    def calculate_hybrid_resources(resource_analysis, strategic_requirements)
      # Combine resources from multiple approaches with 15% efficiency gain
      all_resources = [
        calculate_full_station_resources(strategic_requirements),
        *resource_analysis[:asteroids].map { |a| calculate_asteroid_conversion_resources(a, strategic_requirements) },
        *resource_analysis[:moons].map { |m| calculate_lunar_station_resources(m, strategic_requirements) },
        *resource_analysis[:planets].map { |p| calculate_orbital_station_resources(p, strategic_requirements) }
      ]

      combined = { materials: {}, personnel: {}, equipment: {} }

      all_resources.each do |resources|
        resources[:materials].each { |k, v| combined[:materials][k] = (combined[:materials][k] || 0) + v }
        resources[:personnel].each { |k, v| combined[:personnel][k] = (combined[:personnel][k] || 0) + v }
        resources[:equipment].each { |k, v| combined[:equipment][k] = (combined[:equipment][k] || 0) + v }
      end

      # Apply efficiency gain
      combined[:materials].transform_values! { |v| (v * 0.85).to_i }
      combined[:personnel].transform_values! { |v| (v * 0.85).to_i }
      combined[:equipment].transform_values! { |v| (v * 0.85).to_i }

      combined
    end

    # Strategic requirement adjustments
    def adjust_requirements_for_system(target_system)
      adjustments = {}

      # Adjust based on system distance from home
      distance = target_system['distance_ly'] || target_system[:distance_ly] || 10
      if distance > 50
        adjustments[:timeline_requirements] = { critical: 24.months, optimal: 18.months }
        adjustments[:risk_tolerance] = :high
      end

      # Adjust based on system hostility
      threat_level = target_system['threat_level'] || target_system[:threat_level] || :low
      if threat_level == :high
        adjustments[:capability_requirements] ||= []
        adjustments[:capability_requirements] << :defensive_systems
        adjustments[:risk_tolerance] = :low
      end

      adjustments
    end

    # Suitability evaluation methods
    def evaluate_wormhole_anchor_suitability(station_type, target_system)
      score = 0

      case station_type
      when :full_space_station, :orbital_construction
        score += 80  # Best for wormhole anchoring
      when :asteroid_conversion
        score += 60  # Good but less stable
      when :lunar_surface_station
        score += 40  # Possible but gravity well issues
      when :hybrid_approach
        score += 70  # Good compromise
      end

      # Bonus for systems with wormholes
      score += 20 if target_system['wormholes']&.any?

      score
    end

    def evaluate_resource_processing_suitability(station_type, target_system)
      score = 0

      case station_type
      when :lunar_surface_station, :asteroid_conversion
        score += 80  # Best for resource processing
      when :full_space_station
        score += 60  # Good but needs resource transport
      when :orbital_construction
        score += 50  # Moderate capability
      when :hybrid_approach
        score += 75  # Good combination
      end

      score
    end

    def evaluate_defensive_suitability(station_type, target_system)
      score = 0

      case station_type
      when :orbital_construction, :full_space_station
        score += 80  # Best defensive positions
      when :asteroid_conversion
        score += 70  # Good cover and stability
      when :lunar_surface_station
        score += 60  # Surface advantage
      when :hybrid_approach
        score += 75  # Multiple defensive layers
      end

      score
    end

    def evaluate_trade_hub_suitability(station_type, target_system)
      score = 0

      case station_type
      when :orbital_construction, :full_space_station
        score += 85  # Best for trade and logistics
      when :lunar_surface_station
        score += 50  # Limited accessibility
      when :asteroid_conversion
        score += 45  # Remote location
      when :hybrid_approach
        score += 75  # Good accessibility options
      end

      score
    end

    def evaluate_research_suitability(station_type, target_system)
      score = 0

      case station_type
      when :lunar_surface_station
        score += 80  # Best for surface research
      when :full_space_station, :orbital_construction
        score += 70  # Good for orbital research
      when :asteroid_conversion
        score += 60  # Interesting geological research
      when :hybrid_approach
        score += 75  # Multiple research opportunities
      end

      score
    end

    def assess_construction_feasibility(station_type, target_system)
      feasibility = { feasibility_multiplier: 1.0, factors: [] }

      case station_type
      when :full_space_station
        feasibility[:feasibility_multiplier] = 0.9
        feasibility[:factors] << 'Requires significant prefabricated components'
      when :asteroid_conversion
        asteroid_count = target_system.dig('celestial_bodies', 'asteroids')&.length || 0
        feasibility[:feasibility_multiplier] = asteroid_count > 0 ? 0.8 : 0.3
        feasibility[:factors] << "#{asteroid_count} suitable asteroids available"
      when :lunar_surface_station
        moon_count = ['moons', 'ice_moons', 'rocky_moons'].sum do |type|
          target_system.dig('celestial_bodies', type)&.length || 0
        end
        feasibility[:feasibility_multiplier] = moon_count > 0 ? 0.85 : 0.2
        feasibility[:factors] << "#{moon_count} suitable moons available"
      when :orbital_construction
        planet_count = target_system.dig('celestial_bodies', 'planets')&.length || 0
        feasibility[:feasibility_multiplier] = planet_count > 0 ? 0.9 : 0.4
        feasibility[:factors] << "#{planet_count} planets available for orbital construction"
      when :hybrid_approach
        feasibility[:feasibility_multiplier] = 0.75
        feasibility[:factors] << 'Combines multiple construction methods'
      end

      feasibility
    end

    def suggest_modifications(station_type, strategic_purpose)
      suggestions = []

      case [station_type, strategic_purpose]
      when [:asteroid_conversion, :wormhole_anchor]
        suggestions << 'Add artificial gravity systems for crew comfort'
        suggestions << 'Install advanced stabilization equipment'
      when [:lunar_surface_station, :trade_hub]
        suggestions << 'Add orbital transfer facilities'
        suggestions << 'Install high-capacity docking systems'
      when [:orbital_construction, :resource_processing]
        suggestions << 'Add surface-to-orbit transport systems'
        suggestions << 'Install processing facilities in orbit'
      end

      suggestions
    end

    # Risk assessment helper methods
    def assess_technical_risks(strategy)
      risks = []

      case strategy[:construction_type]
      when :full_space_station
        risks << { risk: 'Component integration failures', probability: :medium, impact: :high }
        risks << { risk: 'Assembly equipment malfunction', probability: :low, impact: :medium }
      when :asteroid_conversion
        risks << { risk: 'Structural collapse during excavation', probability: :high, impact: :critical }
        risks << { risk: 'Unexpected geological features', probability: :medium, impact: :high }
      when :lunar_surface_station
        risks << { risk: 'Dust contamination of systems', probability: :high, impact: :medium }
        risks << { risk: 'Thermal expansion/contraction', probability: :medium, impact: :medium }
      when :orbital_construction
        risks << { risk: 'Orbital decay', probability: :low, impact: :critical }
        risks << { risk: 'Space debris collision', probability: :medium, impact: :high }
      when :hybrid_approach
        risks << { risk: 'Coordination complexity', probability: :medium, impact: :medium }
        risks << { risk: 'Resource allocation conflicts', probability: :low, impact: :high }
      end

      risks
    end

    def assess_resource_risks(strategy, target_system)
      risks = []

      # Check for resource availability
      required_resources = strategy[:resource_requirements][:materials] || {} if strategy[:resource_requirements]
      available_resources = target_system['available_resources'] || {}

      required_resources.each do |material, quantity|
        available = available_resources[material] || 0
        if available < quantity * 0.5  # Less than 50% available
          risks << {
            risk: "Insufficient #{material} availability",
            probability: :high,
            impact: :high,
            mitigation: "Import #{quantity - available} units of #{material}"
          }
        end
      end

      risks
    end

    def assess_timeline_risks(strategy)
      risks = []

      construction_time = strategy[:construction_time]
      critical_timeline = strategy.dig(:strategic_requirements, :timeline_requirements, :critical)

      if critical_timeline && construction_time > critical_timeline
        delay_months = ((construction_time - critical_timeline) / 1.month).round
        risks << {
          risk: "#{delay_months} month construction delay",
          probability: :medium,
          impact: :high,
          mitigation: 'Accelerate critical path activities'
        }
      end

      risks
    end

    def assess_environmental_risks(strategy, target_system)
      risks = []

      # Radiation risks
      radiation_level = target_system['radiation_level'] || :low
      if radiation_level == :high
        risks << {
          risk: 'High radiation exposure',
          probability: :high,
          impact: :medium,
          mitigation: 'Install additional radiation shielding'
        }
      end

      # Micrometeorite risks
      micrometeorite_density = target_system['micrometeorite_density'] || :low
      if micrometeorite_density == :high
        risks << {
          risk: 'High micrometeorite impact risk',
          probability: :medium,
          impact: :medium,
          mitigation: 'Add impact-resistant outer hull'
        }
      end

      risks
    end

    def calculate_overall_risk_level(risks)
      return :low if risks.empty?

      # Combine all risk arrays
      all_risks = []
      all_risks += risks[:technical_risks] || []
      all_risks += risks[:resource_risks] || []
      all_risks += risks[:timeline_risks] || []
      all_risks += risks[:environmental_risks] || []

      high_impact_count = all_risks.count { |r| r[:impact] == :critical || r[:impact] == :high }
      high_probability_count = all_risks.count { |r| r[:probability] == :high }

      if high_impact_count >= 2 || high_probability_count >= 3
        :high
      elsif high_impact_count >= 1 || high_probability_count >= 2
        :medium
      else
        :low
      end
    end

    # Implementation plan generators for different types
    def generate_lunar_implementation_plan(strategy, target_system)
      moon = strategy[:moon_data]
      {
        phases: [
          { name: 'Site Survey', duration: 1.month, resources: ['survey_craft', 'geological_team'] },
          { name: 'Foundation Preparation', duration: 2.months, resources: ['construction_equipment', 'excavation_crew'] },
          { name: 'Module Assembly', duration: 3.months, resources: ['assembly_crew', 'prefab_modules'] },
          { name: 'Infrastructure Installation', duration: 2.months, resources: ['technical_crew', 'utility_systems'] },
          { name: 'System Testing', duration: 1.month, resources: ['testing_team', 'diagnostic_equipment'] }
        ],
        resource_requirements: strategy[:resource_requirements],
        timeline: { total_duration: 9.months, critical_path: ['Module Assembly', 'Infrastructure Installation'] },
        risk_mitigation: ['Dust mitigation systems', 'Thermal protection', 'Emergency shelter protocols'],
        contingency_plans: ['Alternative site selection', 'Orbital station fallback']
      }
    end

    def generate_orbital_implementation_plan(strategy, target_system)
      planet = strategy[:planet_data]
      {
        phases: [
          { name: 'Orbital Analysis', duration: 2.weeks, resources: ['survey_craft', 'orbital_mechanics_team'] },
          { name: 'Component Delivery', duration: 1.month, resources: ['transport_crafts', 'logistics_team'] },
          { name: 'Initial Assembly', duration: 3.months, resources: ['assembly_rigs', 'construction_crew'] },
          { name: 'System Integration', duration: 2.months, resources: ['technical_crew', 'integration_equipment'] },
          { name: 'Orbital Positioning', duration: 1.month, resources: ['propulsion_systems', 'navigation_team'] }
        ],
        resource_requirements: strategy[:resource_requirements],
        timeline: { total_duration: 7.5.months, critical_path: ['Initial Assembly', 'System Integration'] },
        risk_mitigation: ['Orbital debris monitoring', 'Attitude control systems', 'Emergency deorbit protocols'],
        contingency_plans: ['Alternative orbital parameters', 'Ground-based station fallback']
      }
    end

    def generate_hybrid_implementation_plan(strategy, target_system)
      {
        phases: [
          { name: 'Multi-site Assessment', duration: 1.month, resources: ['survey_team', 'analysis_crew'] },
          { name: 'Parallel Construction Initiation', duration: 2.months, resources: ['multiple_construction_teams'] },
          { name: 'Component Integration', duration: 3.months, resources: ['integration_crew', 'coordination_team'] },
          { name: 'System Synchronization', duration: 2.months, resources: ['technical_crew', 'testing_equipment'] },
          { name: 'Final Optimization', duration: 1.month, resources: ['optimization_team', 'performance_monitors'] }
        ],
        resource_requirements: strategy[:resource_requirements],
        timeline: { total_duration: 9.months, critical_path: ['Parallel Construction Initiation', 'Component Integration'] },
        risk_mitigation: ['Redundant systems across sites', 'Cross-site backup capabilities', 'Coordinated emergency response'],
        contingency_plans: ['Site-specific fallbacks', 'Reduced capability operation modes']
      }
    end

    # Calculate aggregate resource score
    def calculate_aggregate_resource_score(resource_inventory)
      score = 0

      # Asteroid resources
      score += resource_inventory[:asteroids].sum { |a| a[:resource_value] } * 0.3

      # Moon suitability
      score += resource_inventory[:moons].sum { |m| m[:surface_suitability] } * 20

      # Planet orbital complexity (inverse scoring - lower complexity is better)
      planet_score = resource_inventory[:planets].sum { |p| 2.0 - p[:construction_complexity] } * 15
      score += planet_score

      score
    end
  end
end