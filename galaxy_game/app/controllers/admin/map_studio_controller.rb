# frozen_string_literal: true

module Admin
  # AI Map Generation Studio - Comprehensive planetary map generation and management
  # Independent of celestial bodies - generates maps that can be applied to any planet
  class MapStudioController < ApplicationController
    before_action :ensure_map_directories_exist

    def index
      @available_source_maps = find_all_source_maps
      @generated_maps = find_generated_maps
      @map_generation_stats = calculate_generation_stats
      @ai_learning_status = load_ai_learning_status

      # Stats for dashboard
      @source_maps_count = @available_source_maps.size
      @generated_maps_count = @generated_maps.size
      @celestial_bodies_count = ::CelestialBodies::CelestialBody.count
      @recent_generations_count = @generated_maps.select { |m| m[:created_at] && m[:created_at] > 24.hours.ago }.size

      # Recent activities (placeholder for now)
      @recent_activities = load_recent_activities
    end

    # GET /admin/map_studio/generate
    # Show planetary map generation interface
    def generate
      @target_planets = ::CelestialBodies::CelestialBody.all.order(:name)
      @celestial_bodies_options = @target_planets.map { |body| [body.name, body.id] }
      @available_source_maps = find_all_source_maps
      @planet_templates = load_planet_templates
    end

    # POST /admin/map_studio/generate_map
    # Generate a new planetary map using AI analysis
    def generate_map
      planet_id = params[:planet_id]
      # Accept both parameter names for compatibility
      selected_maps = params[:selected_maps] || params[:source_map_ids] || []
      generation_options = params[:generation_options] || {}

      # Add debug logging
      Rails.logger.info "=== MAP GENERATION DEBUG ==="
      Rails.logger.info "Received parameters: #{params.inspect}"
      Rails.logger.info "selected_maps: #{params[:selected_maps].inspect}"
      Rails.logger.info "source_map_ids: #{params[:source_map_ids].inspect}"
      Rails.logger.info "Using: #{selected_maps.inspect}"

      unless planet_id.present?
        redirect_to admin_map_studio_generate_path,
                    alert: 'Please select a target planet.'
        return
      end

      planet = ::CelestialBodies::CelestialBody.find(planet_id)

      @planet = planet

      begin
        # Initialize map generator
        generator = AIManager::PlanetaryMapGenerator.new

        # Prepare source maps
        sources = prepare_map_sources(selected_maps)

        # Add logging
        Rails.logger.info "Prepared #{sources.size} sources"

        # Validate sources
        if sources.empty? && selected_maps.any?
          # User selected maps but none processed successfully
          redirect_to admin_map_studio_generate_path,
                      alert: "Failed to process selected maps. Please check map files."
          return
        end

        # Generate planetary map
        generated_map = generator.generate_planetary_map(
          planet: planet,
          sources: sources,
          options: generation_options
        )

        # Save generated map
        saved_map = save_generated_map(generated_map, planet, sources)

        notice_message = if sources.empty?
          "Generated procedural map for #{planet.name}. No source maps used. Map saved as '#{saved_map[:filename]}'."
        else
          "Successfully generated #{planet.name} map using #{sources.size} source map(s). Map saved as '#{saved_map[:filename]}'."
        end

        redirect_to admin_map_studio_path, notice: notice_message

      rescue => e
        Rails.logger.error "Map generation error: #{e.message}\n#{e.backtrace.join("\n")}"
        redirect_to admin_map_studio_generate_path,
                    alert: "Map generation failed: #{e.message}"
      end
    end

    # GET /admin/map_studio/browse
    # Browse all generated maps
    def browse
      @generated_maps = find_generated_maps
      @map_stats = calculate_map_stats
    end

    # POST /admin/map_studio/apply_map/:id
    # Apply a generated map to a celestial body
    def apply_map
      map_filename = params[:id] || params[:map_filename]
      celestial_body_id = params[:celestial_body_id]

      # If no celestial body selected, show selection form
      unless celestial_body_id.present?
        @map_filename = map_filename
        @celestial_bodies = ::CelestialBodies::CelestialBody.all.order(:name)
        render :select_celestial_body_for_map
        return
      end

      unless map_filename.present?
        redirect_to admin_map_studio_browse_path,
                    alert: 'Map filename is required.'
        return
      end

      begin
        # Load the generated map
        map_path = GalaxyGame::Paths::GENERATED_MAPS_PATH.join(map_filename)
        map_data = JSON.parse(File.read(map_path))

        # Apply to celestial body
        celestial_body = ::CelestialBodies::CelestialBody.find(celestial_body_id)
        apply_map_to_celestial_body(celestial_body, map_data)

        redirect_to monitor_admin_celestial_body_path(celestial_body),
                    notice: "Successfully applied map '#{map_filename}' to #{celestial_body.name}."

      rescue => e
        Rails.logger.error "Map application error: #{e.message}"
        redirect_to admin_map_studio_browse_path,
                    alert: "Failed to apply map: #{e.message}"
      end
    end

    # GET /admin/map_studio/analyze/:id
    # Analyze a generated map
    def analyze
      map_id = params[:id]
      @map = load_generated_map_by_id(map_id)
      @map[:id] = map_id # Add id for view compatibility
      @map[:quality_score] = calculate_map_quality(@map) # Add quality score for view
      @map[:description] = generate_map_description(@map, {}) # Add description for view
      @analysis = analyze_map_quality(@map) if @map

      respond_to do |format|
        format.html # renders analyze.html.erb
        format.json { render json: { map: @map, analysis: @analysis } }
      end
    end

    private

    def ensure_map_directories_exist
      GalaxyGame::Paths::GENERATED_MAPS_PATH.mkpath unless GalaxyGame::Paths::GENERATED_MAPS_PATH.exist?
    end

    def find_all_source_maps
      maps = []

      # Find FreeCiv maps
      freeciv_dir = GalaxyGame::Paths::FREECIV_MAPS_PATH
      if Dir.exist?(freeciv_dir)
        Dir.glob("#{freeciv_dir}/**/*.sav").each do |file_path|
          relative_path = Pathname.new(file_path).relative_path_from(freeciv_dir).to_s
          maps << {
            type: :freeciv,
            name: File.basename(file_path, '.sav').humanize,
            filename: File.basename(file_path),
            path: file_path,
            size: File.size(file_path),
            folder: File.dirname(relative_path) == '.' ? nil : File.dirname(relative_path)
          }
        end
      end

      # Find Civ4 maps
      civ4_dir = GalaxyGame::Paths::CIV4_MAPS_PATH
      if Dir.exist?(civ4_dir)
        civ4_patterns = ['*.Civ4WorldBuilderSave', '*.CivBeyondSwordWBSave', '*.CivWarlordsWBSave']
        civ4_files = civ4_patterns.flat_map { |pattern| Dir.glob("#{civ4_dir}/**/#{pattern}") }
        civ4_files.each do |file_path|
          relative_path = Pathname.new(file_path).relative_path_from(civ4_dir).to_s
          maps << {
            type: :civ4,
            name: File.basename(file_path, File.extname(file_path)).humanize,
            filename: File.basename(file_path),
            path: file_path,
            size: File.size(file_path),
            folder: File.dirname(relative_path) == '.' ? nil : File.dirname(relative_path)
          }
        end
      end

      maps.sort_by { |m| m[:name] }
    end

    def find_generated_maps
      generated_dir = GalaxyGame::Paths::GENERATED_MAPS_PATH
      return [] unless Dir.exist?(generated_dir)

      Dir.glob("#{generated_dir}/*.json").map do |file_path|
        filename = File.basename(file_path)
        metadata = extract_map_metadata(filename)

        # Load the actual map data to get more details
        map_data = begin
          JSON.parse(File.read(file_path), symbolize_names: true)
        rescue
          {}
        end

        {
          id: filename, # Use filename as ID
          name: metadata[:planet_name],
          filename: filename,
          path: file_path,
          size: File.size(file_path),
          created_at: File.ctime(file_path),
          modified_at: File.mtime(file_path),
          planet_name: metadata[:planet_name],
          planet_type: metadata[:planet_type],
          source_maps: map_data.dig(:metadata, :source_maps) || [],
          generation_options: map_data.dig(:metadata, :generation_options) || {},
          quality_score: calculate_map_quality(map_data),
          description: generate_map_description(map_data, metadata),
          biome_focus: determine_biome_focus(map_data),
          complexity: determine_complexity(map_data)
        }
      end.sort_by { |m| m[:created_at] }.reverse
    end

    def calculate_generation_stats
      maps = find_generated_maps
      {
        total_generated: maps.size,
        by_planet_type: maps.group_by { |m| m[:planet_type] }.transform_values(&:size),
        recent_generations: maps.first(5),
        average_sources_used: maps.empty? ? 0 : maps.sum { |m| m[:source_maps]&.size || 0 }.to_f / maps.size
      }
    end

    def load_ai_learning_status
      learning_file = Rails.root.join('data', 'ai_learning', 'planetary_map_learning.json')
      return {} unless File.exist?(learning_file)

      JSON.parse(File.read(learning_file), symbolize_names: true)
    rescue
      {}
    end

    def prepare_map_sources(selected_map_ids)
      sources = []

      selected_map_ids.each do |map_id|
        type, filename = map_id.split(':', 2)
        next unless type && filename

        # Find the file path
        file_path = find_map_file_path(type.to_sym, filename)
        next unless file_path && File.exist?(file_path)

        # Process the map
        begin
          case type.to_sym
          when :freeciv
            processor = Import::FreecivMapProcessor.new
            map_data = processor.process(file_path)
          when :civ4
            processor = Import::Civ4MapProcessor.new
            map_data = processor.process(file_path)
          else
            next
          end

          sources << {
            type: type.to_sym,
            filename: filename,
            path: file_path,
            data: map_data
          }
        rescue => e
          Rails.logger.warn "Failed to process source map #{filename}: #{e.message}"
        end
      end

      sources
    end

    def save_generated_map(map_data, planet, sources)
      timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
      filename = "#{planet.name.downcase}_#{timestamp}.json"

      # Add metadata
      map_data[:metadata] ||= {}
      map_data[:metadata].merge!(
        generated_at: Time.current.iso8601,
        planet_name: planet.name,
        planet_type: planet.type,
        planet_id: planet.id,
        source_maps: sources.map { |s| { type: s[:type], filename: s[:filename] } },
        generation_options: {}
      )

      # Save to generated maps directory
      File.write(GalaxyGame::Paths::GENERATED_MAPS_PATH.join(filename), JSON.pretty_generate(map_data))

      { filename: filename, path: GalaxyGame::Paths::GENERATED_MAPS_PATH.join(filename) }
    end

    def apply_map_to_celestial_body(celestial_body, map_data)
      # Ensure geosphere exists
      geosphere = celestial_body.geosphere || celestial_body.build_geosphere

      # Apply terrain map
      if map_data['terrain_grid']
        terrain_map_data = {
          grid: map_data['terrain_grid'],
          width: map_data.dig('metadata', 'width') || map_data['terrain_grid'].first&.size || 0,
          height: map_data.dig('metadata', 'height') || map_data['terrain_grid'].size,
          biome_counts: map_data['biome_counts'] || {}
        }
        geosphere.update!(terrain_map: terrain_map_data)
      end

      # Store metadata
      celestial_body.properties['applied_map'] = map_data['metadata']
      celestial_body.properties['map_source'] = 'ai_generated'
      celestial_body.save!
    end

    def extract_map_metadata(filename)
      # Extract metadata from filename: planetname_timestamp.json
      base = File.basename(filename, '.json')
      parts = base.split('_')

      if parts.size >= 2
        planet_name = parts[0..-2].join('_').humanize
        timestamp = parts.last
        planet_type = infer_planet_type_from_name(planet_name)
      else
        planet_name = base.humanize
        planet_type = 'unknown'
      end

      {
        planet_name: planet_name,
        planet_type: planet_type,
        timestamp: timestamp
      }
    end

    def infer_planet_type_from_name(name)
      name_lower = name.downcase
      case
      when name_lower.include?('earth') then 'terrestrial'
      when name_lower.include?('mars') then 'rocky'
      when name_lower.include?('venus') then 'rocky'
      when name_lower.include?('moon') || name_lower.include?('luna') then 'satellite'
      when name_lower.include?('gas') || name_lower.include?('jupiter') then 'gaseous'
      else 'unknown'
      end
    end

    def calculate_map_quality(map_data)
      return 8 if map_data.empty? # Default quality for maps without detailed data

      quality = 5 # Base quality

      # Check for terrain grid
      quality += 2 if map_data[:terrain_grid].is_a?(Array) && !map_data[:terrain_grid].empty?

      # Check for biome data
      quality += 1 if map_data[:biome_counts].is_a?(Hash) && !map_data[:biome_counts].empty?

      # Check for metadata
      quality += 1 if map_data[:metadata].is_a?(Hash)

      # Check for source maps
      quality += 1 if map_data.dig(:metadata, :source_maps).is_a?(Array) && !map_data.dig(:metadata, :source_maps).empty?

      [quality, 10].min # Cap at 10
    end

    def generate_map_description(map_data, metadata)
      sources = map_data.dig(:metadata, :source_maps) || []
      source_count = sources.size

      description = "AI-generated planetary map for #{metadata[:planet_name]}"
      description += " using #{source_count} source map#{source_count == 1 ? '' : 's'}"

      if map_data[:terrain_grid]
        height = map_data[:terrain_grid].size
        width = map_data[:terrain_grid].first&.size || 0
        description += ". Terrain grid: #{width}x#{height}"
      end

      if map_data[:biome_counts]
        biome_count = map_data[:biome_counts].size
        description += ". #{biome_count} biome type#{biome_count == 1 ? '' : 's'} detected"
      end

      description
    end

    def determine_biome_focus(map_data)
      biomes = map_data[:biome_counts] || {}
      return "Unknown" if biomes.empty?

      # Find the most common biome
      primary_biome = biomes.max_by { |k, v| v }&.first
      primary_biome&.to_s&.humanize || "Mixed"
    end

    def determine_complexity(map_data)
      grid = map_data[:terrain_grid]
      return "Low" unless grid.is_a?(Array)

      size = grid.size * (grid.first&.size || 0)
      biomes = (map_data[:biome_counts] || {}).size

      case
      when size > 10000 && biomes > 5 then "High"
      when size > 5000 && biomes > 3 then "Medium"
      else "Low"
      end
    end

    def calculate_map_stats
      maps = find_generated_maps
      {
        total_maps: maps.size,
        by_type: maps.group_by { |m| m[:planet_type] }.transform_values(&:size),
        average_size: maps.empty? ? 0 : maps.sum { |m| m[:size] }.to_f / maps.size,
        newest_map: maps.first,
        oldest_map: maps.last
      }
    end

    def load_generated_map(filename)
      path = GalaxyGame::Paths::GENERATED_MAPS_PATH.join(filename)
      JSON.parse(File.read(path), symbolize_names: true)
    rescue
      {}
    end

    def analyze_map_quality(map_data)
      # Basic quality analysis
      {
        terrain_diversity: calculate_terrain_diversity(map_data),
        resource_balance: calculate_resource_balance(map_data),
        strategic_features: analyze_strategic_features(map_data),
        overall_score: 0.75 # Placeholder
      }
    end

    def calculate_terrain_diversity(map_data)
      return 0 unless map_data[:terrain_grid]

      terrain_types = map_data[:terrain_grid].flatten.uniq
      terrain_types.size.to_f / 10.0 # Normalize to 0-1 scale
    end

    def calculate_resource_balance(map_data)
      # Placeholder - would analyze resource distribution
      0.7
    end

    def analyze_strategic_features(map_data)
      # Placeholder - would analyze strategic locations
      { coastal_sites: 0, river_valleys: 0, mountain_passes: 0 }
    end

    def find_map_file_path(type, filename)
      base_dir = case type
                 when :freeciv
                   GalaxyGame::Paths::FREECIV_MAPS_PATH
                 when :civ4
                   GalaxyGame::Paths::CIV4_MAPS_PATH
                 else
                   return nil
                 end

      # Search recursively for the file
      Dir.glob("#{base_dir}/**/#{filename}").first
    end

    def load_planet_templates
      # Load predefined planet templates for generation
      [
        {
          name: 'Earth-like',
          conditions: {
            surface_temperature: 288.0,
            atmospheric_pressure: 1.0,
            hydrosphere_coverage: 71.0,
            biosphere_density: 1.0
          }
        },
        {
          name: 'Mars-like',
          conditions: {
            surface_temperature: 210.0,
            atmospheric_pressure: 0.006,
            hydrosphere_coverage: 0.0,
            biosphere_density: 0.0
          }
        },
        {
          name: 'Venus-like',
          conditions: {
            surface_temperature: 737.0,
            atmospheric_pressure: 92.0,
            hydrosphere_coverage: 0.0,
            biosphere_density: 0.0
          }
        }
      ]
    end

    private

    def load_recent_activities
      # Placeholder for recent map generation activities
      # In a real implementation, this would load from a database or log file
      [
        {
          name: 'Map Generation Started',
          details: 'AI analysis of FreeCiv and Civ4 source maps initiated',
          time: '2 minutes ago'
        },
        {
          name: 'Source Maps Discovered',
          details: 'Found 14 source maps (3 FreeCiv, 11 Civ4) available for generation',
          time: '5 minutes ago'
        },
        {
          name: 'Directory Structure Verified',
          details: 'Generated maps directory created at /data/maps/galaxy_game',
          time: '10 minutes ago'
        }
      ]
    end

    def load_generated_map_by_id(map_id)
      # Ensure the map_id includes .json extension
      filename = map_id.end_with?('.json') ? map_id : "#{map_id}.json"
      load_generated_map(filename)
    end
  end
end