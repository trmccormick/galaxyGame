# app/services/ai_manager/earth_map_generator.rb
module AIManager
  class EarthMapGenerator
    attr_reader :learning_data, :template_library

    def initialize
      @learning_data = load_learning_data
      @template_library = load_template_library
      @civ4_processor = Import::Civ4MapProcessor.new
      @freeciv_processor = Import::FreecivMapProcessor.new
    end

    # Main method: Generate Earth map from FreeCiv/Civ4 sources with AI learning
    def generate_earth_map(sources:, planet_conditions: {})
      Rails.logger.info "[EarthMapGenerator] Starting Earth map generation from #{sources.length} sources"

      # Step 1: Process all source maps
      processed_maps = process_source_maps(sources)

      # Step 2: AI analysis and pattern extraction
      analyzed_patterns = analyze_map_patterns(processed_maps)

      # Step 3: Generate unified Earth map
      earth_map = generate_unified_earth_map(processed_maps, analyzed_patterns, planet_conditions)

      # Step 4: Apply AI learning and optimization
      optimized_map = apply_ai_optimizations(earth_map, analyzed_patterns)

      # Step 5: Record learning data for future use
      record_learning_data(optimized_map, sources, planet_conditions)

      # Step 6: Generate Galaxy Game JSON format
      galaxy_game_json = format_for_galaxy_game(optimized_map)

      Rails.logger.info "[EarthMapGenerator] Earth map generation complete"
      galaxy_game_json
    end

    # Analyze imported maps to extract strategic patterns for AI learning
    def analyze_imported_map(map_data, source_type, planet_context = {})
      Rails.logger.info "[EarthMapGenerator] Analyzing #{source_type} map for AI learning"

      case source_type
      when :freeciv
        analysis = analyze_freeciv_patterns(map_data)
      when :civ4
        analysis = analyze_civ4_patterns(map_data)
      else
        raise "Unknown map source type: #{source_type}"
      end

      # Extract strategic insights
      strategic_insights = extract_strategic_insights(analysis, planet_context)

      # Update learning database
      update_learning_database(strategic_insights, source_type)

      strategic_insights
    end

    private

    def process_source_maps(sources)
      processed = []

      sources.each do |source|
        case source[:type]
        when :freeciv
          map_data = @freeciv_processor.process(source[:file_path])
        when :civ4
          map_data = @civ4_processor.process(source[:file_path])
        else
          Rails.logger.warn "[EarthMapGenerator] Unknown source type: #{source[:type]}"
          next
        end

        processed << {
          source: source,
          data: map_data,
          analysis: analyze_imported_map(map_data, source[:type])
        }
      end

      processed
    end

    def analyze_map_patterns(processed_maps)
      patterns = {
        terrain_distribution: {},
        elevation_characteristics: {},
        strategic_markers: {},
        biome_patterns: {},
        resource_patterns: {}
      }

      processed_maps.each do |map|
        # Aggregate terrain distribution patterns
        if map[:data][:biomes]
          map[:data][:biomes].flatten.each do |biome|
            patterns[:terrain_distribution][biome] ||= 0
            patterns[:terrain_distribution][biome] += 1
          end
        end

        # Analyze elevation patterns
        if map[:data][:lithosphere] && map[:data][:lithosphere][:elevation]
          elevation = map[:data][:lithosphere][:elevation].flatten.compact
          patterns[:elevation_characteristics][:min] = [patterns[:elevation_characteristics][:min] || 999, elevation.min].min
          patterns[:elevation_characteristics][:max] = [patterns[:elevation_characteristics][:max] || 0, elevation.max].max
          patterns[:elevation_characteristics][:avg] = elevation.sum.to_f / elevation.size
        end

        # Extract strategic markers from analysis
        if map[:analysis][:strategic_markers]
          patterns[:strategic_markers].merge!(map[:analysis][:strategic_markers])
        end
      end

      patterns
    end

    def generate_unified_earth_map(processed_maps, patterns, planet_conditions)
      # Use the highest quality map as base
      base_map = select_base_map(processed_maps)

      # Apply AI optimizations based on learned patterns
      optimized_grid = optimize_terrain_grid(base_map[:data][:biomes], patterns)

      # Generate elevation if not available
      elevation = base_map[:data][:lithosphere][:elevation] ||
                  generate_elevation_from_patterns(optimized_grid, patterns)

      # Apply Earth-specific conditions
      earth_conditions = default_earth_conditions.merge(planet_conditions)

      {
        grid: optimized_grid,
        elevation: elevation,
        width: base_map[:data][:lithosphere][:width] || optimized_grid.first.size,
        height: base_map[:data][:lithosphere][:height] || optimized_grid.size,
        biomes: optimized_grid, # For compatibility
        strategic_markers: patterns[:strategic_markers],
        planet_conditions: earth_conditions,
        generation_metadata: {
          sources_used: processed_maps.map { |m| m[:source][:file_path] },
          ai_optimizations_applied: true,
          quality_score: calculate_quality_score(processed_maps, patterns)
        }
      }
    end

    def apply_ai_optimizations(earth_map, patterns)
      # Apply learned optimizations
      optimized = earth_map.deep_dup

      # Optimize resource placement based on learned patterns
      if patterns[:resource_patterns][:optimal_placement]
        optimized[:strategic_markers] = optimize_resource_placement(
          optimized[:strategic_markers],
          patterns[:resource_patterns][:optimal_placement]
        )
      end

      # Apply settlement site optimizations
      if patterns[:settlement_patterns]
        optimized[:settlement_sites] = identify_optimal_settlement_sites(
          optimized[:grid],
          patterns[:settlement_patterns]
        )
      end

      optimized
    end

    def record_learning_data(optimized_map, sources, planet_conditions)
      learning_entry = {
        timestamp: Time.current,
        sources: sources.map { |s| { type: s[:type], file: File.basename(s[:file_path]) } },
        planet_conditions: planet_conditions,
        patterns_learned: extract_patterns_from_result(optimized_map),
        quality_metrics: calculate_learning_metrics(optimized_map),
        generation_success: true
      }

      @learning_data << learning_entry
      save_learning_data
    end

    def format_for_galaxy_game(earth_map)
      # Convert to Galaxy Game JSON format
      {
        metadata: {
          name: "Earth",
          type: "terrestrial_habitable",
          source: "ai_generated_from_historical_maps",
          version: "1.0",
          generation_date: Time.current.iso8601,
          ai_learning_applied: true
        },
        planetary_conditions: earth_map[:planet_conditions],
        terrain_data: {
          lithosphere: {
            elevation: earth_map[:elevation],
            structure: infer_geological_structure(earth_map[:elevation]),
            quality: earth_map[:generation_metadata][:quality_score]
          },
          biomes: earth_map[:biomes],
          hydrosphere: generate_hydrosphere_data(earth_map),
          biosphere: generate_biosphere_data(earth_map)
        },
        strategic_markers: earth_map[:strategic_markers],
        ai_insights: {
          learned_patterns: extract_patterns_from_result(earth_map),
          optimization_applied: earth_map[:generation_metadata][:ai_optimizations_applied],
          confidence_score: calculate_confidence_score(earth_map)
        }
      }
    end

    # Analysis methods for different map types
    def analyze_freeciv_patterns(map_data)
      {
        terrain_patterns: analyze_terrain_distribution(map_data[:biomes]),
        biome_transitions: analyze_biome_transitions(map_data[:biomes]),
        strategic_markers: extract_freeciv_strategic_markers(map_data),
        quality_assessment: assess_freeciv_quality(map_data)
      }
    end

    def analyze_civ4_patterns(map_data)
      {
        elevation_patterns: analyze_elevation_distribution(map_data[:lithosphere][:elevation]),
        resource_placement: analyze_resource_patterns(map_data),
        settlement_opportunities: identify_settlement_sites(map_data),
        strategic_markers: extract_civ4_strategic_markers(map_data),
        quality_assessment: assess_civ4_quality(map_data)
      }
    end

    def extract_strategic_insights(analysis, planet_context)
      insights = {
        terrain_preferences: {},
        resource_patterns: {},
        settlement_logic: {},
        terraforming_hints: {}
      }

      # Extract insights based on analysis type
      if analysis[:terrain_patterns]
        insights[:terrain_preferences] = derive_terrain_preferences(analysis[:terrain_patterns])
      end

      if analysis[:resource_placement]
        insights[:resource_patterns] = analysis[:resource_placement]
      end

      if analysis[:settlement_opportunities]
        insights[:settlement_logic] = analysis[:settlement_opportunities]
      end

      insights
    end

    # Helper methods
    def load_learning_data
      learning_file = GalaxyGame::Paths::AI_MANAGER_PATH.join('earth_map_learning.json')
      return [] unless File.exist?(learning_file)

      begin
        JSON.parse(File.read(learning_file), symbolize_names: true)
      rescue JSON::ParserError => e
        Rails.logger.warn "[EarthMapGenerator] Failed to load learning data: #{e.message}"
        []
      end
    end

    def load_template_library
      # Load existing Earth map templates
      template_file = GalaxyGame::Paths::TEMPLATE_PATH.join('earth_templates.json')
      return {} unless File.exist?(template_file)

      begin
        JSON.parse(File.read(template_file), symbolize_names: true)
      rescue JSON::ParserError => e
        Rails.logger.warn "[EarthMapGenerator] Failed to load template library: #{e.message}"
        {}
      end
    end

    def save_learning_data
      learning_file = GalaxyGame::Paths::AI_MANAGER_PATH.join('earth_map_learning.json')
      FileUtils.mkdir_p(File.dirname(learning_file))

      begin
        File.write(learning_file, JSON.pretty_generate(@learning_data))
      rescue => e
        Rails.logger.error "[EarthMapGenerator] Failed to save learning data: #{e.message}"
      end
    end

    def select_base_map(processed_maps)
      # Select highest quality map as base
      processed_maps.max_by do |map|
        quality_score = map[:data][:lithosphere][:quality] == 'high_70_80_percent' ? 80 :
                       map[:data][:lithosphere][:quality] == 'medium_60_70_percent' ? 65 : 50
        quality_score
      end
    end

    def default_earth_conditions
      {
        surface_temperature: 288.0, # Kelvin
        atmospheric_pressure: 1.0,  # bar
        atmospheric_composition: {
          N2: 78.0,
          O2: 21.0,
          Ar: 0.9,
          CO2: 0.04
        },
        hydrosphere_coverage: 71.0, # percentage
        biosphere_density: 1.0,     # fully habitable
        geological_activity: 'moderate'
      }
    end

    # Placeholder methods (to be implemented based on specific analysis needs)
    def analyze_terrain_distribution(biomes) {}; end
    def analyze_biome_transitions(biomes) {}; end
    def extract_freeciv_strategic_markers(data) {}; end
    def assess_freeciv_quality(data); end
    def analyze_elevation_distribution(elevation); end
    def analyze_resource_patterns(data); end
    def identify_settlement_sites(data); end
    def extract_civ4_strategic_markers(data); end
    def assess_civ4_quality(data); end
    def derive_terrain_preferences(patterns); end
    def optimize_terrain_grid(grid, patterns); grid; end
    def generate_elevation_from_patterns(grid, patterns); []; end
    def calculate_quality_score(maps, patterns); 75; end
    def optimize_resource_placement(markers, patterns); markers; end
    def identify_optimal_settlement_sites(grid, patterns); []; end
    def extract_patterns_from_result(map); {}; end
    def calculate_learning_metrics(map); {}; end
    def infer_geological_structure(elevation); {}; end
    def generate_hydrosphere_data(map); {}; end
    def generate_biosphere_data(map); {}; end
    def calculate_confidence_score(map); 0.8; end
    def update_learning_database(insights, source_type); end
  end
end