# app/services/ai_manager/probe_deployment_service.rb
module AIManager
  class ProbeDeploymentService
    def initialize(target_system)
      @target_system = target_system
    end

    # Deploy scout probes before AI analysis (Phase 0)
    def deploy_scout_probes
      Rails.logger.info "[ProbeDeployment] Deploying scout probes to system #{@target_system['identifier']}"

      probes = []

      # Priority 1: EM Detection Probe
      em_probe = deploy_probe(
        type: "generic_probe",
        config: "em_detection_probe_data",
        target: @target_system,
        priority: 1
      )
      probes << em_probe

      # Priority 2: System Survey Probe
      survey_probe = deploy_probe(
        type: "generic_probe",
        config: "system_survey_probe_data",
        target: @target_system,
        priority: 2
      )
      probes << survey_probe

      # Priority 3: Resource Assessment Probe
      resource_probe = deploy_probe(
        type: "generic_probe",
        config: "resource_assessment_probe_data",
        target: @target_system,
        priority: 3
      )
      probes << resource_probe

      # Priority 4: Threat Assessment Probe
      threat_probe = deploy_probe(
        type: "generic_probe",
        config: "threat_assessment_probe_data",
        target: @target_system,
        priority: 4
      )
      probes << threat_probe

      # Priority 5: Atmospheric Probe (if applicable)
      if has_atmospheric_bodies?(@target_system)
        atmos_probe = deploy_probe(
          type: "generic_probe",
          config: "atmospheric_probe_data",
          target: @target_system,
          priority: 5
        )
        probes << atmos_probe
      end

      Rails.logger.info "[ProbeDeployment] Deployed #{probes.size} probes"

      # Collect and return probe data
      collect_probe_data(probes)
    end

    private

    def deploy_probe(type:, config:, target:, priority:)
      # Load probe blueprint
      blueprint_path = Rails.root.join('data', 'json-data', 'blueprints', 'crafts', 'space', 'probes', "#{type}_bp.json")
      blueprint = JSON.parse(File.read(blueprint_path)) rescue {}

      probe = {
        id: "probe_#{priority}_#{Time.now.to_i}",
        type: type,
        config: config,
        target_system: target['identifier'],
        priority: priority,
        deployed_at: Time.current.iso8601,
        blueprint: blueprint,
        status: 'deployed'
      }

      Rails.logger.info "[ProbeDeployment] Deployed #{type} probe (priority #{priority})"
      probe
    end

    def has_atmospheric_bodies?(system)
      # Check if system has planets with atmospheres
      system.dig('celestial_bodies', 'terrestrial_planets')&.any? do |planet|
        planet['atmosphere'].present?
      end
    end

    def collect_probe_data(probes)
      # Simulate probe data collection (14 days)
      Rails.logger.info "[ProbeDeployment] Collecting probe data (14 days simulation)"

      probe_data = {
        collection_period_days: 14,
        probes_deployed: probes.size,
        data_types: [],
        findings: {}
      }

      probes.each do |probe|
        case probe[:config]
        when 'em_detection_probe_data'
          probe_data[:data_types] << 'electromagnetic_signatures'
          probe_data[:findings][:em_signatures] = simulate_em_detection(@target_system)
        when 'system_survey_probe_data'
          probe_data[:data_types] << 'system_survey'
          probe_data[:findings][:system_survey] = simulate_system_survey(@target_system)
        when 'resource_assessment_probe_data'
          probe_data[:data_types] << 'resource_assessment'
          probe_data[:findings][:resource_assessment] = simulate_resource_assessment(@target_system)
        when 'threat_assessment_probe_data'
          probe_data[:data_types] << 'threat_assessment'
          probe_data[:findings][:threat_assessment] = simulate_threat_assessment(@target_system)
        when 'atmospheric_probe_data'
          probe_data[:data_types] << 'atmospheric_analysis'
          probe_data[:findings][:atmospheric_analysis] = simulate_atmospheric_analysis(@target_system)
        end
      end

      Rails.logger.info "[ProbeDeployment] Probe data collection complete"
      probe_data
    end

    def simulate_em_detection(system)
      # Simulate EM signature detection
      bodies = system.dig('celestial_bodies', 'terrestrial_planets') || []
      body_count = [bodies.size, 1].max
      sample_count = rand(1..body_count)

      {
        total_signatures: rand(1..5),
        locations: bodies.sample(sample_count).map { |b| b['identifier'] },
        strength_range: 'weak to moderate'
      }
    end

    def simulate_system_survey(system)
      # Simulate comprehensive system survey
      bodies = system.dig('celestial_bodies')
      {
        total_bodies: count_all_bodies(bodies),
        terraformable_bodies: count_terraformable_bodies(bodies),
        resource_rich_bodies: count_resource_rich_bodies(bodies),
        habitability_index: rand(0.1..0.9).round(2)
      }
    end

    def simulate_resource_assessment(system)
      # Simulate resource assessment
      bodies = system.dig('celestial_bodies')
      {
        high_value_resources: ['helium-3', 'water_ice', 'rare_metals'].sample(rand(1..3)),
        extraction_difficulty: ['easy', 'moderate', 'hard'].sample,
        total_resource_bodies: count_resource_rich_bodies(bodies)
      }
    end

    def simulate_threat_assessment(system)
      # Simulate threat assessment
      {
        radiation_levels: ['low', 'moderate', 'high'].sample,
        gravitational_hazards: rand(0..3),
        orbital_instability_risk: ['low', 'moderate', 'high'].sample,
        overall_threat_level: ['minimal', 'moderate', 'significant'].sample
      }
    end

    def simulate_atmospheric_analysis(system)
      # Simulate atmospheric analysis for planets with atmospheres
      planets_with_atmos = system.dig('celestial_bodies', 'terrestrial_planets')&.select { |p| p['atmosphere'].present? } || []
      {
        analyzed_planets: planets_with_atmos.size,
        atmospheric_compositions: planets_with_atmos.map do |planet|
          {
            planet: planet['identifier'],
            primary_gas: planet.dig('atmosphere')&.keys&.first || 'unknown',
            pressure_range: ['low', 'moderate', 'high'].sample
          }
        end
      }
    end

    def count_all_bodies(bodies)
      return 0 unless bodies
      (bodies['terrestrial_planets'] || []).size +
      (bodies['gas_giants'] || []).size +
      (bodies['ice_giants'] || []).size +
      (bodies['dwarf_planets'] || []).size +
      (bodies['asteroids'] || []).size
    end

    def count_terraformable_bodies(bodies)
      return 0 unless bodies && bodies['terrestrial_planets']
      bodies['terrestrial_planets'].count { |p| p['terraforming_difficulty'].to_f < 5.0 }
    end

    def count_resource_rich_bodies(bodies)
      return 0 unless bodies
      # Count bodies with resource potential
      resource_bodies = 0
      resource_bodies += (bodies['terrestrial_planets'] || []).size
      resource_bodies += (bodies['asteroids'] || []).size
      resource_bodies += (bodies['dwarf_planets'] || []).size
      resource_bodies
    end
  end
end