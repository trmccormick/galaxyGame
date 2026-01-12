# app/services/ai_manager/settlement_plan_generator.rb
module AIManager
  class SettlementPlanGenerator
    def initialize(analysis, target_system)
      @analysis = analysis
      @target_system = target_system
    end

    # Generate enhanced settlement plan with asteroid tug integration
    def generate_settlement_plan
      base_plan = create_base_plan

      # Add specialized craft for moon/asteroid targets
      if moon_or_asteroid_target?(@analysis[:target_body])
        base_plan[:specialized_craft] = generate_asteroid_tug_config
        base_plan[:phases].insert(1, "asteroid_capture_and_conversion")
        base_plan[:infrastructure] << "depot_conversion_equipment"
      end

      # Link to mission profile
      base_plan[:mission_profile] = select_mission_profile(@analysis)
      base_plan[:cycler_config] = select_cycler_config(@analysis)

      base_plan
    end

    private

    def create_base_plan
      {
        mission_type: determine_mission_type,
        target_body: @analysis[:target_body][:identifier],
        strategy: @analysis[:strategy],
        roi_years: @analysis[:roi_years],
        success_probability: @analysis[:success_probability],
        infrastructure: determine_infrastructure,
        phases: determine_phases,
        crew_requirements: estimate_crew,
        economic_model: @analysis[:economic_model]
      }
    end

    def determine_mission_type
      case @analysis[:strategy]
      when 'mining_outpost' then 'resource_extraction'
      when 'terraforming_base' then 'planetary_terraforming'
      when 'research_station' then 'scientific_research'
      when 'orbital_harvesting' then 'atmospheric_harvesting'
      else 'general_settlement'
      end
    end

    def determine_infrastructure
      base_infra = ['power_generation', 'life_support', 'communication']

      case @analysis[:strategy]
      when 'mining_outpost'
        base_infra + ['mining_equipment', 'processing_facility']
      when 'terraforming_base'
        base_infra + ['atmospheric_processors', 'greenhouse_facilities']
      when 'research_station'
        base_infra + ['laboratory_equipment', 'observatory']
      when 'orbital_harvesting'
        base_infra + ['harvesting_equipment', 'storage_facilities']
      else
        base_infra + ['general_construction']
      end
    end

    def determine_phases
      case @analysis[:strategy]
      when 'mining_outpost'
        ['cycler_deployment', 'mining_operations', 'resource_processing', 'kinetic_hammer_return']
      when 'terraforming_base'
        ['cycler_deployment', 'atmospheric_terraforming', 'surface_habitation', 'expansion']
      when 'research_station'
        ['cycler_deployment', 'facility_construction', 'research_operations', 'data_transmission']
      when 'orbital_harvesting'
        ['cycler_deployment', 'harvesting_setup', 'processing_operations', 'export_logistics']
      else
        ['cycler_deployment', 'initial_construction', 'operations', 'expansion']
      end
    end

    def estimate_crew
      case @analysis[:strategy]
      when 'mining_outpost' then 8
      when 'terraforming_base' then 12
      when 'research_station' then 6
      when 'orbital_harvesting' then 10
      else 8
      end
    end

    def moon_or_asteroid_target?(target_body)
      target_body[:type].in?(["moon", "asteroid"])
    end

    def generate_asteroid_tug_config
      target_body = @analysis[:target_body]
      tug_config = {
        type: "asteroid_relocation_tug",
        mission: determine_tug_mission(target_body),
        target: target_body[:identifier],
        fit: select_tug_configuration(@target_system)
      }

      [tug_config]
    end

    def determine_tug_mission(body)
      mass_kg = body[:mass].to_f

      if mass_kg > 1e10 # Phobos-sized or larger
        "capture_and_hollow_for_depot"
      elsif mass_kg > 1e8 # Medium asteroid
        "relocate_to_optimal_orbit"
      else # Small asteroid
        "capture_and_position"
      end
    end

    def select_tug_configuration(system)
      # Select appropriate tug configuration based on system characteristics
      if system.dig('stars', 0, 'type')&.include?('M') # Red dwarf system
        "nuclear_thermal_compact" # More efficient for close orbits
      elsif has_high_radiation?(system)
        "radiation_shielded_nuclear"
      else
        "standard_nuclear_thermal"
      end
    end

    def has_high_radiation?(system)
      # Check for gas giants or other radiation sources
      gas_giants = system.dig('celestial_bodies', 'gas_giants') || []
      ice_giants = system.dig('celestial_bodies', 'ice_giants') || []
      gas_giants.size + ice_giants.size > 1
    end

    def select_mission_profile(analysis)
      case analysis[:primary_characteristic]
      when :large_moon_with_resources
        "luna_deployment_mission.json"
      when :small_moons_with_belt
        "mars_deployment_mission.json"
      when :atmospheric_planet_no_surface_access
        "venus_deployment_mission.json"
      when :gas_giant_with_moons
        "titan_deployment_mission.json"
      when :icy_moon_system
        "neptune_orbital_hub_profile_v1.json"
      else
        "generic_settlement_mission.json"
      end
    end

    def select_cycler_config(analysis)
      case analysis[:primary_characteristic]
      when :large_moon_with_resources
        "luna_support_configuration"
      when :small_moons_with_belt
        "mars_constructor_configuration"
      when :atmospheric_planet_no_surface_access
        "venus_harvester_configuration"
      when :gas_giant_with_moons
        "titan_harvester_configuration"
      when :icy_moon_system
        "neptune_deep_space_configuration"
      else
        "standard_cycler_configuration"
      end
    end
  end
end