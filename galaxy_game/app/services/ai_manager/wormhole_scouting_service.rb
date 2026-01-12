# app/services/ai_manager/wormhole_scouting_service.rb
module AIManager
  class WormholeScoutingService
    attr_reader :current_system, :available_systems

    def initialize(current_system: 'sol')
      @current_system = current_system
      @available_systems = load_available_systems
    end

    # Main method to evaluate and select systems for wormhole scouting
    def evaluate_scouting_opportunities
      puts "[WormholeScoutingService] Evaluating scouting opportunities from #{current_system}" if defined?(Rails)
      Rails.logger.info "[WormholeScoutingService] Evaluating scouting opportunities from #{current_system}" if defined?(Rails)

      candidate_systems = select_candidate_systems
      scored_systems = score_systems_for_scouting(candidate_systems)

      # Return top candidates sorted by score
      scored_systems.sort_by { |system| -system[:scouting_score] }.first(5)
    end

    # Create artificial wormhole for scouting a specific system
    def create_scouting_wormhole(target_system_name)
      puts "[WormholeScoutingService] Creating scouting wormhole to #{target_system_name}" if defined?(Rails)
      Rails.logger.info "[WormholeScoutingService] Creating scouting wormhole to #{target_system_name}" if defined?(Rails)

      source_system = SolarSystem.find_by(name: current_system)
      target_system = SolarSystem.find_by(name: target_system_name)

      unless source_system && target_system
        puts "[WormholeScoutingService] Could not find systems: source=#{source_system}, target=#{target_system}" if defined?(Rails)
        Rails.logger.error "[WormholeScoutingService] Could not find systems: source=#{source_system}, target=#{target_system}" if defined?(Rails)
        return nil
      end

      # Use the wormhole splicer to create artificial wormhole
      splicer = StarSim::Wormholes::Splicer.new
      wormhole = splicer.create_artificial_wormhole(
        source_system: source_system,
        target_system: target_system
      )

      puts "[WormholeScoutingService] Created scouting wormhole #{wormhole.id} to #{target_system_name}" if defined?(Rails)
      Rails.logger.info "[WormholeScoutingService] Created scouting wormhole #{wormhole.id} to #{target_system_name}" if defined?(Rails)
      wormhole
    end

    # Execute full scouting mission: create wormhole, deploy probes, complete system data
    def execute_scouting_mission(target_system_name)
      puts "[WormholeScoutingService] Executing scouting mission to #{target_system_name}" if defined?(Rails)
      Rails.logger.info "[WormholeScoutingService] Executing scouting mission to #{target_system_name}" if defined?(Rails)

      # Step 1: Create artificial wormhole for access
      wormhole = create_scouting_wormhole(target_system_name)
      return { status: :failed, reason: :wormhole_creation_failed } unless wormhole

      # Step 2: Load and complete system data
      system_data = load_system_data(target_system_name)
      return { status: :failed, reason: :system_data_not_found } unless system_data

      # Step 3: Deploy probes for intelligence gathering
      probe_results = deploy_scouting_probes(system_data)

      # Step 4: Analyze scouting results
      analysis = analyze_scouting_results(probe_results, system_data)

      # Step 5: Determine if system warrants full wormhole investment
      recommendation = generate_investment_recommendation(analysis)

      {
        status: :success,
        wormhole: wormhole,
        system_data: system_data,
        probe_results: probe_results,
        analysis: analysis,
        recommendation: recommendation
      }
    end

    private

    def load_available_systems
      # Load all available star systems from the local bubble
      service_dir = File.dirname(__FILE__)
      data_dir = File.expand_path('../../../../data/json-data/star_systems', service_dir)
      system_files = Dir.glob(File.join(data_dir, '*.json'))
      system_files.reject { |f| File.basename(f).start_with?('sol') }.map do |file|
        File.basename(file, '.json')
      end
    end

    def select_candidate_systems
      # Filter systems based on basic criteria
      available_systems.select do |system_name|
        system_data = load_system_data(system_name)
        next false unless system_data

        # Basic filtering criteria
        meets_scouting_criteria?(system_data)
      end
    end

    def meets_scouting_criteria?(system_data)
      # Distance: prefer closer systems (within 20 light years)
      distance = system_data.dig('stars', 0, 'distance_ly') || 100
      return false if distance > 20

      # Star type: prefer main sequence stars
      star_type = system_data.dig('stars', 0, 'spectral_type') || 'Unknown'
      return false if star_type.include?('White Dwarf') || star_type.include?('Neutron')

      # Has planets: prefer systems with confirmed planets
      planets = system_data['celestial_bodies']&.select { |body| body['type']&.include?('Terrestrial') || body['type']&.include?('Earth') || body['type']&.include?('Super-Earth') } || []
      return false if planets.empty?

      true
    end

    def score_systems_for_scouting(system_names)
      system_names.map do |system_name|
        system_data = load_system_data(system_name)
        next nil unless system_data

        score = calculate_scouting_score(system_data)
        {
          system_name: system_name,
          scouting_score: score,
          system_data: system_data
        }
      end.compact
    end

    def calculate_scouting_score(system_data)
      score = 0

      # Distance factor (closer is better)
      distance = system_data.dig('stars', 0, 'distance_ly') || 10
      score += (20 - distance) * 2  # Max 40 points for being within 1 ly

      # Planet count (more planets = more potential)
      planets = system_data['celestial_bodies']&.select { |body| body['type']&.include?('Terrestrial') || body['type']&.include?('Earth') || body['type']&.include?('Super-Earth') } || []
      score += planets.count * 5  # 5 points per planet

      # Star type bonus
      star_type = system_data.dig('stars', 0, 'spectral_type') || ''
      if star_type.start_with?('G', 'K')  # Sun-like or cooler
        score += 10
      elsif star_type.start_with?('M')  # Red dwarfs
        score += 5
      end

      # Known exoplanets bonus - check if there are confirmed exoplanets
      if planets.any?
        score += 15
      end

      # Habitable zone potential - check if any planets are in habitable zone
      habitable_planets = planets.select { |p| p['notable_traits']&.include?('Habitable Zone') }
      if habitable_planets.any?
        score += 10
      end

      score
    end

    def load_system_data(system_name)
      # Use relative path from the service file
      service_dir = File.dirname(__FILE__)
      data_dir = File.expand_path('../../../../data/json-data/star_systems', service_dir)
      file_path = File.join(data_dir, "#{system_name}.json")
      return nil unless File.exist?(file_path)

      begin
        JSON.parse(File.read(file_path))
      rescue JSON::ParserError
        puts "Failed to parse system data for #{system_name}" if defined?(Rails)
        Rails.logger.error "[WormholeScoutingService] Failed to parse system data for #{system_name}" if defined?(Rails)
        nil
      end
    end

    def deploy_scouting_probes(system_data)
      # Use the existing probe deployment service
      target_system = { identifier: system_data['name'], data: system_data }
      probe_service = ProbeDeploymentService.new(target_system)
      probe_service.deploy_and_analyze
    end

    def analyze_scouting_results(probe_results, system_data)
      # Analyze probe data to determine system value
      {
        resource_potential: assess_resource_potential(probe_results),
        habitability_score: assess_habitability(probe_results, system_data),
        infrastructure_cost: estimate_infrastructure_cost(probe_results),
        roi_estimate: calculate_roi_estimate(probe_results, system_data)
      }
    end

    def assess_resource_potential(probe_results)
      # Assess resource value based on probe findings
      resource_score = 0

      if probe_results.dig(:resource_assessment, :rare_metals)
        resource_score += 20
      end

      if probe_results.dig(:resource_assessment, :water_ice)
        resource_score += 15
      end

      if probe_results.dig(:resource_assessment, :volatiles)
        resource_score += 10
      end

      resource_score
    end

    def assess_habitability(probe_results, system_data)
      # Assess habitability based on atmospheric and surface data
      habitability_score = 0

      # Check for potentially habitable planets
      planets = system_data['celestial_bodies']&.select { |body| body['type']&.include?('Terrestrial') || body['type']&.include?('Earth') } || []
      planets.each do |planet|
        if planet['atmosphere']&.dig('N2')&.> 0.5  # Nitrogen-rich atmosphere
          habitability_score += 20
        elsif planet['notable_traits']&.include?('Habitable Zone')
          habitability_score += 15
        end
      end

      # Atmospheric processing potential
      if probe_results.dig(:atmospheric_data, :co2_abundance)&.> 0.1
        habitability_score += 10
      end

      habitability_score
    end

    def estimate_infrastructure_cost(probe_results)
      # Estimate GCC cost for full infrastructure development
      base_cost = 50000  # Base settlement cost

      # Adjust based on system characteristics
      if probe_results.dig(:threat_assessment, :radiation_levels)&.> 0.5
        base_cost += 20000  # Radiation shielding
      end

      if probe_results.dig(:atmospheric_data, :extreme_conditions)
        base_cost += 15000  # Atmospheric processing
      end

      base_cost
    end

    def calculate_roi_estimate(probe_results, system_data)
      # Estimate return on investment in years
      infrastructure_cost = estimate_infrastructure_cost(probe_results)
      resource_value = assess_resource_potential(probe_results)

      # Simple ROI calculation: higher resource value = faster ROI
      case resource_value
      when 0..10 then 15  # 15 years
      when 11..25 then 8  # 8 years
      when 26..40 then 5  # 5 years
      else 3  # 3 years for high-value systems
      end
    end

    def generate_investment_recommendation(analysis)
      # Determine if system warrants full wormhole investment
      total_score = analysis[:resource_potential] + analysis[:habitability_score]

      if total_score >= 50 && analysis[:roi_estimate] <= 7
        {
          invest: true,
          priority: :high,
          reason: "High resource potential and good ROI",
          estimated_cost: analysis[:infrastructure_cost],
          expected_roi_years: analysis[:roi_estimate]
        }
      elsif total_score >= 30 && analysis[:roi_estimate] <= 10
        {
          invest: true,
          priority: :medium,
          reason: "Moderate potential with acceptable ROI",
          estimated_cost: analysis[:infrastructure_cost],
          expected_roi_years: analysis[:roi_estimate]
        }
      elsif total_score >= 15
        {
          invest: false,
          priority: :low,
          reason: "Limited potential, consider for future evaluation",
          estimated_cost: analysis[:infrastructure_cost],
          expected_roi_years: analysis[:roi_estimate]
        }
      else
        {
          invest: false,
          priority: :none,
          reason: "Insufficient potential for investment",
          estimated_cost: analysis[:infrastructure_cost],
          expected_roi_years: analysis[:roi_estimate]
        }
      end
    end
  end
end