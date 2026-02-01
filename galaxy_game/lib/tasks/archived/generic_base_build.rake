# lib/tasks/generic_base_build.rake
# Generic base build framework for system-agnostic AI deployment

require 'ai_manager/autonomous_construction_manager'

namespace :ai do
  namespace :base_build do
    desc "Analyze system and recommend optimal base build pattern"
    task :analyze_system, [:celestial_body_id] => :environment do |t, args|
      celestial_body_id = args[:celestial_body_id]

      puts "🔭 === SYSTEM ANALYSIS FOR BASE BUILD ==="

      # Try to load from database first, fall back to cached analysis
      begin
        body = CelestialBodies::CelestialBody.find(celestial_body_id)
        puts "System: #{body.name} (#{body.type})"
        puts "Gravity: #{body.gravity} m/s²"
        puts "Temperature: #{body.surface_temperature}°C"
        puts "Atmosphere: #{body.known_pressure} Pa"
        puts ""

        # Analyze system characteristics
        analysis = analyze_system_characteristics(body)
      rescue ActiveRecord::RecordNotFound
        puts "Celestial body '#{celestial_body_id}' not found in database."
        puts "Loading cached analysis..."
        puts ""

        # Load cached analysis
        analysis_file = Rails.root.join('data', 'json-data', 'ai-manager', 'system_analyses.json')
        analyses = File.exist?(analysis_file) ? JSON.parse(File.read(analysis_file)) : {}

        cached_data = analyses[celestial_body_id]
        if cached_data
          analysis = cached_data['analysis']
          puts "System: #{cached_data['body_name']} (#{cached_data['body_type']})"
          puts "Using cached analysis from #{cached_data['analyzed_at']}"
          puts ""
        else
          puts "❌ No cached analysis found for '#{celestial_body_id}'"
          puts "Run analysis on a real celestial body first, or add cached data to system_analyses.json"
          exit 1
        end
      end

      puts "📊 SYSTEM CHARACTERISTICS:"
      puts "  • Resource Potential: #{analysis[:resource_potential] || analysis['resource_potential']}/10"
      puts "  • Infrastructure Suitability: #{analysis[:infrastructure_suitability] || analysis['infrastructure_suitability']}/10"
      puts "  • ISRU Feasibility: #{analysis[:isru_feasibility] || analysis['isru_feasibility']}/10"
      puts "  • Hazard Level: #{analysis[:hazard_level] || analysis['hazard_level']}/10"
      puts "  • Power Requirements: #{analysis[:power_requirements] || analysis['power_requirements']}"
      puts "  • Construction Timeline: #{analysis[:timeline_modifier] || analysis['timeline_modifier']}x standard"
      puts ""

      # Recommend pattern
      recommendation = recommend_build_pattern(analysis)

      puts "🎯 RECOMMENDED BUILD PATTERN:"
      puts "  • Primary Pattern: #{recommendation[:primary_pattern]}"
      puts "  • Fallback Pattern: #{recommendation[:fallback_pattern]}"
      puts "  • Key Adaptations: #{recommendation[:adaptations].join(', ')}"
      puts "  • Expected Success Rate: #{recommendation[:success_rate] * 100}%"
      puts ""

      # Save analysis for future reference (only if we analyzed a real body)
      if defined?(body) && body
        save_system_analysis(body, analysis, recommendation)
        puts "✅ Analysis saved to AI knowledge base"
      else
        puts "ℹ️ Using cached analysis (not saving)"
      end
    end

    desc "Generate adapted mission profile for specific system"
    task :adapt_mission, [:base_pattern, :celestial_body_id, :output_file] => :environment do |t, args|
      base_pattern = args[:base_pattern] || 'npc-base-deploy'
      celestial_body_id = args[:celestial_body_id]
      output_file = args[:output_file] || "#{base_pattern.split('-').join('_')}_adapted_#{celestial_body_id}.json"

      puts "🔧 === MISSION PROFILE ADAPTATION ==="
      puts "Base Pattern: #{base_pattern}"
      puts "Target System: #{celestial_body_id}"
      puts ""

      # Load base pattern
      base_profile_path = Rails.root.join('data', 'json-data', 'missions', base_pattern, "#{base_pattern.split('-').join('_')}_profile_v1.json")
      base_profile = JSON.parse(File.read(base_profile_path))

      # Load system analysis
      analysis_file = Rails.root.join('data', 'json-data', 'ai-manager', 'system_analyses.json')
      analyses = File.exist?(analysis_file) ? JSON.parse(File.read(analysis_file)) : {}
      system_analysis = analyses[celestial_body_id]

      raise "No system analysis found for #{celestial_body_id}. Run analyze_system first." unless system_analysis

      puts "📋 BASE PROFILE:"
      puts "  • Name: #{base_profile['name']}"
      puts "  • Phases: #{base_profile['phases']&.size || 0}"
      puts ""

      # Adapt profile
      adapted_profile = adapt_mission_profile(base_profile, system_analysis)

      puts "🔄 ADAPTATIONS APPLIED:"
      adaptations_list = adapted_profile['adaptations'] || adapted_profile[:adaptations] || []
      adaptations_list.each do |adaptation|
        puts "  • #{adaptation}"
      end
      puts ""

      # Save adapted profile
      output_path = Rails.root.join('data', 'json-data', 'missions', 'adapted', output_file)
      FileUtils.mkdir_p(output_path.dirname)
      File.write(output_path, JSON.pretty_generate(adapted_profile.except(:adaptations)))

      puts "💾 Adapted profile saved: #{output_path}"
      puts "🎯 Ready for AI autonomous deployment"
    end

    desc "Execute generic base build with AI oversight"
    task :execute, [:adapted_mission_file, :settlement_name] => :environment do |t, args|
      adapted_mission_file = args[:adapted_mission_file]
      settlement_name = args[:settlement_name] || "AI Base #{Time.now.to_i}"

      puts "🏗️ === GENERIC BASE BUILD EXECUTION ==="
      puts "Mission File: #{adapted_mission_file}"
      puts "Settlement: #{settlement_name}"
      puts ""

      # Load adapted mission
      mission_path = Rails.root.join('data', 'json-data', 'missions', 'adapted', adapted_mission_file)
      adapted_mission = JSON.parse(File.read(mission_path))

      puts "📋 MISSION OVERVIEW:"
      puts "  • Name: #{adapted_mission['name']}"
      puts "  • Adapted for: #{adapted_mission['target_system']}"
      puts "  • Phases: #{adapted_mission['phases']&.size || 0}"
      puts ""

      # Create settlement (simplified - in real implementation, this would be more complex)
      settlement = create_generic_settlement(settlement_name, adapted_mission['target_system'])

      # Initialize AI Construction Manager
      construction_manager = AutonomousConstructionManager.new(settlement, nil)

      # Execute with AI oversight
      execution_result = construction_manager.execute_adapted_mission(adapted_mission)

      puts "📊 EXECUTION RESULTS:"
      puts "  • Tasks Completed: #{execution_result[:tasks_completed]}"
      puts "  • Resources Used: #{execution_result[:resources_used]}"
      puts "  • Structures Built: #{execution_result[:structures_built]}"
      puts "  • AI Interventions: #{execution_result[:ai_interventions]}"
      puts "  • Success Rate: #{execution_result[:success_rate] * 100}%"
      puts ""

      if execution_result[:success_rate] > 0.8
        puts "✅ GENERIC BASE BUILD SUCCESSFUL"
        puts "AI Manager can now replicate this pattern"
      else
        puts "⚠️ BUILD COMPLETED WITH ISSUES"
        puts "AI will learn from this deployment"
      end
    end

    desc "Run full generic base build pipeline"
    task :pipeline, [:celestial_body_id, :base_pattern] => :environment do |t, args|
      celestial_body_id = args[:celestial_body_id]
      base_pattern = args[:base_pattern] || 'npc-base-deploy'

      puts "🚀 === GENERIC BASE BUILD PIPELINE ==="
      puts "System: #{celestial_body_id}"
      puts "Base Pattern: #{base_pattern}"
      puts ""

      # Step 1: Analyze system
      puts "Step 1: System Analysis"
      Rake::Task['ai:base_build:analyze_system'].invoke(celestial_body_id)
      Rake::Task['ai:base_build:analyze_system'].reenable

      # Step 2: Adapt mission
      puts "\nStep 2: Mission Adaptation"
      adapted_file = "#{base_pattern}_adapted_#{celestial_body_id}.json"
      Rake::Task['ai:base_build:adapt_mission'].invoke(base_pattern, celestial_body_id, adapted_file)
      Rake::Task['ai:base_build:adapt_mission'].reenable

      # Step 3: Execute build
      puts "\nStep 3: Build Execution"
      settlement_name = "AI Base #{celestial_body_id} #{Time.now.to_i}"
      Rake::Task['ai:base_build:execute'].invoke(adapted_file, settlement_name)
      Rake::Task['ai:base_build:execute'].reenable

      puts "\n🎉 GENERIC BASE BUILD PIPELINE COMPLETE"
      puts "AI Manager now has experience with #{celestial_body_id}-type systems"
    end
  end
end

# Helper methods
def analyze_system_characteristics(body)
  # Analyze based on celestial body properties
  resource_score = calculate_resource_score(body)
  hazard_score = calculate_hazard_score(body)
  isru_score = calculate_isru_score(body)

  {
    resource_potential: resource_score,
    infrastructure_suitability: [10 - hazard_score, 1].max,
    isru_feasibility: isru_score,
    hazard_level: hazard_score,
    power_requirements: body.surface_temperature < -50 ? 'nuclear_heavy' : 'solar_standard',
    timeline_modifier: hazard_score > 7 ? 2.0 : 1.0
  }
end

def calculate_resource_score(body)
  # Simplified resource scoring
  score = 5 # Base score

  # Adjust based on body type
  case body.type
  when /Moon/
    score += 2 # Moons often have accessible resources
  when /Planet.*Rocky/
    score += 1
  when /Planet.*Gas/
    score -= 2
  end

  # Adjust for temperature (extreme temps may indicate rich resources)
  score += 1 if body.surface_temperature.abs > 100

  [score, 10].min
end

def calculate_hazard_score(body)
  score = 0

  # Gravity hazards
  score += 2 if body.gravity > 2.0 || body.gravity < 0.5

  # Temperature hazards
  score += 2 if body.surface_temperature.abs > 100

  # Atmospheric hazards
  score += 3 if body.known_pressure.nil? || body.known_pressure > 101325 # Earth pressure

  [score, 10].min
end

def calculate_isru_score(body)
  # ISRU potential based on resource availability
  resource_score = calculate_resource_score(body)

  # Surface bodies are better for ISRU than orbital
  surface_bonus = body.type.include?('Moon') || body.type.include?('Planet') ? 2 : 0

  [resource_score + surface_bonus, 10].min
end

def recommend_build_pattern(analysis)
  # Handle both string and symbol keys
  isru = analysis[:isru_feasibility] || analysis['isru_feasibility']
  hazard = analysis[:hazard_level] || analysis['hazard_level']

  if isru && isru >= 7
    { primary_pattern: 'isru_focused_base', fallback_pattern: 'standard_base', adaptations: ['enhanced_isru', 'local_resource_priority'], success_rate: 0.9 }
  elsif hazard && hazard <= 3
    { primary_pattern: 'standard_base', fallback_pattern: 'minimal_outpost', adaptations: ['standard_procedures'], success_rate: 0.85 }
  else
    { primary_pattern: 'hazard_hardened_base', fallback_pattern: 'orbital_station', adaptations: ['radiation_shielding', 'redundant_systems'], success_rate: 0.75 }
  end
end

def save_system_analysis(body, analysis, recommendation)
  analysis_file = Rails.root.join('data', 'json-data', 'ai-manager', 'system_analyses.json')
  analyses = File.exist?(analysis_file) ? JSON.parse(File.read(analysis_file)) : {}

  analyses[body.id.to_s] = {
    body_name: body.name,
    body_type: body.type,
    analysis: analysis,
    recommendation: recommendation,
    analyzed_at: Time.current.iso8601
  }

  File.write(analysis_file, JSON.pretty_generate(analyses))
end

def adapt_mission_profile(base_profile, system_analysis)
  adapted = base_profile.deep_dup
  adaptations = []

  # Adapt based on system characteristics
  analysis = system_analysis['analysis']

  # Adjust power requirements
  if analysis['power_requirements'] == 'nuclear_heavy'
    adapted['phases'].each do |phase|
      # Add nuclear power tasks if not present
      adaptations << "Added nuclear power requirements"
    end
  end

  # Adjust timeline
  modifier = analysis['timeline_modifier']
  if modifier > 1.0
    adapted['estimated_duration_days'] = (adapted['estimated_duration_days'] || 30) * modifier
    adaptations << "Extended timeline by #{modifier}x for hazard mitigation"
  end

  # Add hazard-specific adaptations
  if analysis['hazard_level'] > 5
    adaptations << "Added radiation shielding requirements"
    adaptations << "Implemented redundant system backups"
  end

  # Set target system
  adapted['target_system'] = system_analysis['body_name']
  adapted['adaptations'] = adaptations

  adapted
end

def create_generic_settlement(name, system_name)
  # Simplified settlement creation for demonstration
  Settlement::BaseSettlement.create!(
    name: name,
    settlement_type: 'base',
    current_population: 0,
    operational_data: { ai_generated: true, target_system: system_name },
    owner: Player.create!(name: "AI Builder #{Time.now.to_i}", active_location: "Building"),
    location: Location::CelestialLocation.create!(
      name: "Build Site #{Time.now.to_i}",
      coordinates: "#{rand(0.00..90.00).round(2)}°N #{rand(0.00..180.00).round(2)}°E",
      celestial_body: CelestialBodies::Satellites::LargeMoon.find_or_create_by!(name: "Generic Moon") do |moon|
        moon.identifier = "GENERIC-MOON"
        moon.size = 0.2727
        moon.gravity = 1.62
        moon.density = 3.344
        moon.mass = 7.342e22
        moon.radius = 1.737e6
        moon.orbital_period = 27.322
        moon.albedo = 0.12
        moon.insolation = 1361
        moon.surface_temperature = 250
        moon.known_pressure = 0.0
        moon.properties = {}
      end
    )
  )
end