namespace :ai do
  namespace :sol_system do

    desc "Analyze the Sol system data and provide AI recommendations"
    task analyze: :environment do
      require 'json'
      require_relative '../../lib/ai_manager'

      puts "=== AI Sol System Analysis ==="
      puts "Loading Sol system data..."

      # Load the complete Sol system data
      sol_data_path = Rails.root.join('data', 'json-data', 'star_systems', 'sol-complete.json')
      unless File.exist?(sol_data_path)
        puts "ERROR: sol-complete.json not found at #{sol_data_path}"
        exit 1
      end

      sol_data = JSON.parse(File.read(sol_data_path))

      analyzer = AISolSystemAnalyzer.new(sol_data)
      analyzer.analyze_system

      puts "\n=== Analysis Results ==="
      puts "System: #{analyzer.system_name}"
      puts "Celestial Bodies: #{analyzer.celestial_bodies_count}"
      puts "Planets: #{analyzer.planets_count}"
      puts "Moons: #{analyzer.moons_count}"
      puts "Dwarf Planets: #{analyzer.dwarf_planets_count}"

      puts "\n=== AI Recommendations ==="
      selector = AIPatternSelector.new(analyzer)
      recommendations = selector.generate_recommendations

      recommendations.each do |rec|
        puts "\n#{rec[:priority].upcase}: #{rec[:target]}"
        puts "  Reason: #{rec[:reason]}"
        puts "  Pattern: #{rec[:pattern]}"
        puts "  Estimated Cost: #{rec[:estimated_cost]}"
      end

      puts "\n=== Pattern Analysis ==="
      patterns = selector.identify_patterns
      patterns.each do |pattern, bodies|
        puts "#{pattern}: #{bodies.join(', ')}"
      end
    end

    desc "Build out the Sol system using AI-driven decisions"
    task build: :environment do
      require 'json'
      require_relative '../../lib/ai_manager'

      puts "=== AI Sol System Builder ==="
      puts "Loading Sol system data..."

      sol_data_path = Rails.root.join('data', 'json-data', 'star_systems', 'sol-complete.json')
      unless File.exist?(sol_data_path)
        puts "ERROR: sol-complete.json not found at #{sol_data_path}"
        exit 1
      end

      sol_data = JSON.parse(File.read(sol_data_path))

      analyzer = AISolSystemAnalyzer.new(sol_data)
      analyzer.analyze_system

      selector = AIPatternSelector.new(analyzer)
      builder = AISolSystemBuilder.new(analyzer, selector)

      puts "Building Sol system with AI-driven decisions..."
      results = builder.build_system

      puts "\n=== Build Results ==="
      puts "Total constructions: #{results[:total_constructions]}"
      puts "Strategic locations: #{results[:strategic_locations].join(', ')}"
      puts "Resource priorities: #{results[:resource_priorities].join(', ')}"

      puts "\n=== Construction Details ==="
      results[:constructions].each do |construction|
        puts "\n#{construction[:type]} on #{construction[:location]}"
        puts "  Priority: #{construction[:priority]}"
        puts "  Resources: #{construction[:resources].join(', ')}"
        puts "  Estimated completion: #{construction[:estimated_completion]}"
      end
    end

    desc "Test AI pattern recognition with sample scenarios"
    task test_patterns: :environment do
      require 'json'
      require_relative '../../lib/ai_manager'

      puts "=== AI Pattern Recognition Tests ==="

      # Test with different system configurations
      test_scenarios = [
        { name: "Complete Sol System", file: "sol-complete.json" },
        { name: "Basic Sol System", file: "sol.json" }
      ]

      test_scenarios.each do |scenario|
        puts "\n--- Testing #{scenario[:name]} ---"

        data_path = Rails.root.join('data', 'json-data', 'star_systems', scenario[:file])
        next unless File.exist?(data_path)

        data = JSON.parse(File.read(data_path))
        analyzer = AISolSystemAnalyzer.new(data)
        analyzer.analyze_system

        selector = AIPatternSelector.new(analyzer)
        patterns = selector.identify_patterns

        puts "Patterns identified: #{patterns.keys.join(', ')}"
        puts "Total patterns: #{patterns.length}"

        recommendations = selector.generate_recommendations
        puts "Recommendations generated: #{recommendations.length}"
      end
    end

    desc "Validate Sol system data format and completeness"
    task validate: :environment do
      require 'json'

      puts "=== Sol System Data Validation ==="

      sol_data_path = Rails.root.join('data', 'json-data', 'star_systems', 'sol-complete.json')
      unless File.exist?(sol_data_path)
        puts "ERROR: sol-complete.json not found"
        exit 1
      end

      begin
        data = JSON.parse(File.read(sol_data_path))

        # Validate required top-level keys
        required_keys = ['galaxy', 'id', 'name', 'stars', 'celestial_bodies', 'metadata']
        missing_keys = required_keys - data.keys
        if missing_keys.any?
          puts "ERROR: Missing required keys: #{missing_keys.join(', ')}"
          exit 1
        end

        # Validate celestial bodies structure
        celestial_bodies = data['celestial_bodies']
        puts "Found #{celestial_bodies.length} celestial bodies"

        # Check for required body attributes
        required_body_keys = ['name', 'identifier', 'type', 'mass', 'radius']
        celestial_bodies.each do |body|
          missing_body_keys = required_body_keys - body.keys
          if missing_body_keys.any?
            puts "WARNING: Body #{body['name']} missing keys: #{missing_body_keys.join(', ')}"
          end
        end

        # Validate geological features if present
        bodies_with_features = celestial_bodies.select { |b| b['geological_features'] }
        puts "Bodies with geological features: #{bodies_with_features.map { |b| b['name'] }.join(', ')}"

        puts "✓ Data validation passed"

      rescue JSON::ParserError => e
        puts "ERROR: Invalid JSON format - #{e.message}"
        exit 1
      end
    end

  end
end

# AI Manager Classes
class AISolSystemAnalyzer
  attr_reader :system_data, :system_name, :celestial_bodies_count,
              :planets_count, :moons_count, :dwarf_planets_count

  def initialize(system_data)
    @system_data = system_data
    @system_name = system_data['name']
    @celestial_bodies = system_data['celestial_bodies'] || []
    @celestial_bodies_count = @celestial_bodies.length
  end

  def analyze_system
    @planets_count = @celestial_bodies.count { |b| b['type'] == 'terrestrial_planet' || b['type'] == 'gas_giant' || b['type'] == 'ice_giant' }
    @moons_count = @celestial_bodies.count { |b| b['type'] == 'moon' }
    @dwarf_planets_count = @celestial_bodies.count { |b| b['type'] == 'dwarf_planet' }

    puts "Analyzed system: #{@system_name}"
    puts "- Total bodies: #{@celestial_bodies_count}"
    puts "- Planets: #{@planets_count}"
    puts "- Moons: #{@moons_count}"
    puts "- Dwarf planets: #{@dwarf_planets_count}"
  end

  def get_bodies_by_type(type)
    @celestial_bodies.select { |b| b['type'] == type }
  end

  def get_strategic_bodies
    @celestial_bodies.select do |body|
      # Strategic criteria: habitable, resources, or unique features
      body['biosphere_attributes'] ||
      body['hydrosphere_attributes'] ||
      body['geological_features'] ||
      body['materials']&.any?
    end
  end
end

class AIPatternSelector
  def initialize(analyzer)
    @analyzer = analyzer
  end

  def identify_patterns
    patterns = {}

    # Resource-rich bodies pattern
    resource_bodies = @analyzer.system_data['celestial_bodies'].select do |body|
      body['materials']&.any? || body['geological_features']
    end
    patterns['resource_rich'] = resource_bodies.map { |b| b['name'] }

    # Habitable bodies pattern
    habitable_bodies = @analyzer.system_data['celestial_bodies'].select do |body|
      body['biosphere_attributes'] || body['hydrosphere_attributes']
    end
    patterns['habitable'] = habitable_bodies.map { |b| b['name'] }

    # Geological activity pattern
    active_bodies = @analyzer.system_data['celestial_bodies'].select do |body|
      (body['geological_activity']&.to_i || 0) > 50
    end
    patterns['geologically_active'] = active_bodies.map { |b| b['name'] }

    patterns
  end

  def generate_recommendations
    recommendations = []

    # High priority: Earth and Mars for colonization
    earth = @analyzer.system_data['celestial_bodies'].find { |b| b['name'] == 'Earth' }
    if earth
      recommendations << {
        priority: 'high',
        target: 'Earth',
        reason: 'Existing biosphere and life support infrastructure',
        pattern: 'habitable',
        estimated_cost: 'High (existing infrastructure)'
      }
    end

    mars = @analyzer.system_data['celestial_bodies'].find { |b| b['name'] == 'Mars' }
    if mars
      recommendations << {
        priority: 'high',
        target: 'Mars',
        reason: 'Terraforming potential and resource availability',
        pattern: 'resource_rich',
        estimated_cost: 'Very High (terraforming required)'
      }
    end

    # Medium priority: Moon for resources and research
    luna = @analyzer.system_data['celestial_bodies'].find { |b| b['name'] == 'Luna' }
    if luna
      recommendations << {
        priority: 'medium',
        target: 'Luna',
        reason: 'Helium-3 deposits and proximity to Earth',
        pattern: 'resource_rich',
        estimated_cost: 'Medium'
      }
    end

    # Low priority: Gas giants for fuel harvesting
    gas_giants = @analyzer.get_bodies_by_type('gas_giant')
    gas_giants.each do |giant|
      recommendations << {
        priority: 'low',
        target: giant['name'],
        reason: 'Fuel harvesting potential',
        pattern: 'resource_rich',
        estimated_cost: 'High (orbital infrastructure)'
      }
    end

    recommendations
  end
end

class AISolSystemBuilder
  def initialize(analyzer, selector)
    @analyzer = analyzer
    @selector = selector
  end

  def build_system
    recommendations = @selector.generate_recommendations

    constructions = []
    strategic_locations = []
    resource_priorities = []

    recommendations.each do |rec|
      case rec[:priority]
      when 'high'
        constructions << build_high_priority_construction(rec)
        strategic_locations << rec[:target]
      when 'medium'
        constructions << build_medium_priority_construction(rec)
      when 'low'
        constructions << build_low_priority_construction(rec)
      end

      resource_priorities << rec[:target] if rec[:pattern] == 'resource_rich'
    end

    {
      total_constructions: constructions.length,
      strategic_locations: strategic_locations,
      resource_priorities: resource_priorities,
      constructions: constructions
    }
  end

  private

  def build_high_priority_construction(rec)
    case rec[:target]
    when 'Earth'
      {
        type: 'Orbital Habitat Complex',
        location: 'Earth',
        priority: 'high',
        resources: ['existing_infrastructure', 'orbital_materials'],
        estimated_completion: '2 years'
      }
    when 'Mars'
      {
        type: 'Terraforming Research Station',
        location: 'Mars',
        priority: 'high',
        resources: ['nuclear_reactors', 'greenhouse_modules'],
        estimated_completion: '5 years'
      }
    end
  end

  def build_medium_priority_construction(rec)
    case rec[:target]
    when 'Luna'
      {
        type: 'Helium-3 Mining Operation',
        location: 'Luna',
        priority: 'medium',
        resources: ['mining_equipment', 'processing_facilities'],
        estimated_completion: '3 years'
      }
    end
  end

  def build_low_priority_construction(rec)
    {
      type: 'Orbital Fuel Depot',
      location: rec[:target],
      priority: 'low',
      resources: ['orbital_platforms', 'fuel_processors'],
      estimated_completion: '7 years'
    }
  end
end