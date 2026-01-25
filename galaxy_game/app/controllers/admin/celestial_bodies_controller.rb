# frozen_string_literal: true

require_dependency 'celestial_bodies/celestial_body'

module Admin
  # Admin controller for celestial body monitoring and testing
  # Provides AI Manager testing interface with SimEarth aesthetic
  class CelestialBodiesController < ApplicationController
    before_action :set_celestial_body, only: [:monitor, :sphere_data, :mission_log, :run_ai_test, :edit, :update, :import_freeciv_for_body]

    # GET /admin/celestial_bodies
    # Index page listing all celestial bodies for monitoring selection
    def index
      @celestial_bodies = ::CelestialBodies::CelestialBody.all.order(:name)
      @bodies = @celestial_bodies # Alias for view compatibility
      @total_bodies = @celestial_bodies.count + ::CelestialBodies::Star.count
      @bodies_by_type = @celestial_bodies.group_by(&:body_category)

      # Calculate habitable count
      @habitable_count = @celestial_bodies.select do |body|
        body.atmosphere&.habitable? || body.respond_to?(:habitable?) && body.habitable?
      end.count

      # Calculate statistics for major categories
      @category_stats = {
        stars: ::CelestialBodies::Star.count,
        brown_dwarfs: @bodies_by_type['brown_dwarf']&.count || 0,
        planets: count_planet_types,
        moons: count_moon_types,
        minor_bodies: count_minor_body_types,
        other: (@bodies_by_type['alien_life_form']&.count || 0) + (@bodies_by_type['material']&.count || 0)
      }
    end

    def count_planet_types
      planet_categories = ['terrestrial_planet', 'carbon_planet', 'lava_world', 'super_earth',
                          'gas_giant', 'ice_giant', 'hot_jupiter', 'hycean_planet',
                          'ocean_planet', 'water_world']
      planet_categories.sum { |cat| @bodies_by_type[cat]&.count || 0 }
    end

    def count_moon_types
      moon_categories = ['moon', 'large_moon', 'small_moon', 'ice_moon']
      moon_categories.sum { |cat| @bodies_by_type[cat]&.count || 0 }
    end

    def count_minor_body_types
      minor_categories = ['asteroid', 'comet', 'dwarf_planet', 'kuiper_belt_object']
      minor_categories.sum { |cat| @bodies_by_type[cat]&.count || 0 }
    end

    # GET /admin/celestial_bodies/:id/monitor
    # Main monitoring interface with three-panel layout
    def monitor
      @geological_features = load_geological_features
      @ai_missions = load_ai_missions
      @sphere_summary = build_sphere_summary
    end

    # GET /admin/celestial_bodies/:id/sphere_data
    # JSON endpoint for real-time sphere data updates
    def sphere_data
      render json: {
        atmosphere: atmosphere_data,
        hydrosphere: hydrosphere_data,
        geosphere: geosphere_data,
        biosphere: biosphere_data,
        planet_info: planet_info_data
      }
    end

    # GET /admin/celestial_bodies/:id/mission_log
    # JSON endpoint for AI mission activity
    def mission_log
      missions = load_ai_missions
      
      render json: {
        missions: missions.map do |mission|
          {
            id: mission[:id],
            type: mission[:type],
            status: mission[:status],
            start_time: mission[:start_time],
            target_body: mission[:target_body],
            progress: mission[:progress],
            messages: mission[:messages]
          }
        end,
        total_missions: missions.count,
        active_missions: missions.count { |m| m[:status] == 'active' }
      }
    end

    # POST /admin/celestial_bodies/:id/run_ai_test
    # Trigger AI Manager test mission
    def run_ai_test
      test_type = params[:test_type] || 'resource_extraction'
      
      result = case test_type
               when 'resource_extraction'
                 run_resource_extraction_test
               when 'base_construction'
                 run_base_construction_test
               when 'isru_pipeline'
                 run_isru_pipeline_test
               when 'gcc_bootstrap'
                 run_gcc_bootstrap_test
               else
                 { success: false, error: 'Unknown test type' }
               end

      render json: result
    end

    # GET /admin/celestial_bodies/:id/edit
    # Admin interface for editing celestial body names and aliases only
    def edit
      # Only allow editing name and aliases - properties come from JSON/StarSim
    end

    # PATCH/PUT /admin/celestial_bodies/:id
    # Update celestial body name and aliases only
    def update
      if @celestial_body.update(celestial_body_admin_params)
        redirect_to monitor_admin_celestial_body_path(@celestial_body), 
                    notice: 'Celestial body name/aliases updated successfully.'
      else
        render :edit, alert: 'Failed to update celestial body.'
      end
    end

    # GET /admin/celestial_bodies/import_freeciv
    # Show FreeCiv SAV file import interface
    def import_freeciv
      @solar_systems = ::SolarSystem.all.order(:name)
    end

    # POST /admin/celestial_bodies/import_freeciv
    # Process uploaded FreeCiv SAV file and create planetary body
    def process_freeciv_import
      uploaded_file = params[:sav_file]
      planet_name = params[:planet_name].presence || "Imported FreeCiv World"
      solar_system_id = params[:solar_system_id]

      unless uploaded_file.present?
        redirect_to import_freeciv_admin_celestial_bodies_path,
                    alert: 'Please select a SAV file to upload.'
        return
      end

      unless solar_system_id.present?
        redirect_to import_freeciv_admin_celestial_bodies_path,
                    alert: 'Please select a solar system for the imported planet.'
        return
      end

      # Save uploaded file temporarily
      temp_file = save_uploaded_file(uploaded_file)

      begin
        # Parse the SAV file
        import_service = Import::FreecivSavImportService.new(temp_file.path)
        freeciv_data = import_service.import

        unless freeciv_data
          redirect_to import_freeciv_admin_celestial_bodies_path,
                      alert: "Failed to parse SAV file: #{import_service.errors.join(', ')}"
          return
        end

        # Convert to Galaxy Game format
        converter = Import::FreecivToGalaxyConverter.new(freeciv_data)
        planet_data = converter.convert_to_planetary_body(
          name: planet_name,
          solar_system: ::SolarSystem.find(solar_system_id)
        )

        unless planet_data
          redirect_to import_freeciv_admin_celestial_bodies_path,
                      alert: "Failed to convert terrain data: #{converter.errors.join(', ')}"
          return
        end

        # Create the planetary body using SystemBuilderService
        builder = StarSim::SystemBuilderService.new(name: planet_name, debug_mode: true)

        # Manually create the celestial body since we're importing
        create_imported_planetary_body(planet_data)

        redirect_to admin_celestial_bodies_path,
                    notice: "Successfully imported FreeCiv world '#{planet_name}' with #{freeciv_data[:width]}x#{freeciv_data[:height]} terrain grid."

      rescue => e
        Rails.logger.error "FreeCiv import error: #{e.message}\n#{e.backtrace.join("\n")}"
        redirect_to import_freeciv_admin_celestial_bodies_path,
                    alert: "Import failed: #{e.message}"
      ensure
        # Clean up temp file
        temp_file.unlink if temp_file
      end
    end

    # POST /admin/celestial_bodies/:id/import_freeciv_for_body
    # Import FreeCiv terrain data for an existing celestial body
    def import_freeciv_for_body
      uploaded_file = params[:sav_file]

      unless uploaded_file.present?
        redirect_to edit_admin_celestial_body_path(@celestial_body),
                    alert: 'Please select a SAV file to upload.'
        return
      end

      # Save uploaded file temporarily
      temp_file = save_uploaded_file(uploaded_file)

      begin
        # Parse the SAV file (this contains terraformed terrain)
        import_service = Import::FreecivSavImportService.new(temp_file.path)
        terraformed_data = import_service.import

        unless terraformed_data
          redirect_to edit_admin_celestial_body_path(@celestial_body),
                      alert: "Failed to parse SAV file: #{import_service.errors.join(', ')}"
          return
        end

        # Generate barren terrain from terraformed blueprint
        planet_characteristics = {
          name: @celestial_body.name,
          type: @celestial_body.celestial_body_type,
          body_category: @celestial_body.body_category,
          surface_temperature: @celestial_body.surface_temperature,
          atmosphere: @celestial_body.atmosphere&.attributes,
          hydrosphere: @celestial_body.hydrosphere&.attributes,
          properties: @celestial_body.properties
        }
        terraforming_service = Import::TerrainTerraformingService.new(terraformed_data, planet_characteristics)
        barren_data = terraforming_service.generate_barren_terrain

        unless barren_data
          redirect_to edit_admin_celestial_body_path(@celestial_body),
                      alert: "Failed to generate barren terrain: #{terraforming_service.errors.join(', ')}"
          return
        end

        # Update the existing celestial body's terrain data with barren version
        update_body_terrain_data(@celestial_body, barren_data, terraformed_data)

        redirect_to monitor_admin_celestial_body_path(@celestial_body),
                    notice: "Successfully imported terraformed blueprint for '#{@celestial_body.name}'. Barren terrain generated with #{barren_data[:width]}x#{barren_data[:height]} grid. Game will terraform naturally toward target state."

      rescue => e
        Rails.logger.error "FreeCiv import for body error: #{e.message}\n#{e.backtrace.join("\n")}"
        redirect_to edit_admin_celestial_body_path(@celestial_body),
                    alert: "Import failed: #{e.message}"
      ensure
        # Clean up temp file
        temp_file.unlink if temp_file
      end
    end

    private

    def set_celestial_body
      @celestial_body = ::CelestialBodies::CelestialBody.includes(:geosphere).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Celestial body not found'
    end

    # Only allow name and aliases to be edited through admin
    # Properties come from JSON data, known info, or StarSim generation
    def celestial_body_admin_params
      # Handle different param keys based on the celestial body type
      permitted_params = params.permit(
        celestial_body: [:name, :aliases],
        celestial_bodies_planets_rocky_terrestrial_planet: [:name, :aliases],
        # Add other types as needed
      )
      
      # Extract the actual params from whichever key is present
      celestial_body_params = permitted_params[:celestial_body] || 
                             permitted_params[:celestial_bodies_planets_rocky_terrestrial_planet] ||
                             {}
      
      celestial_body_params
    end

    def atmosphere_data
      return {} unless @celestial_body.atmosphere

      atmo = @celestial_body.atmosphere
      composition = @celestial_body.atmospheric_composition || {}

      # Get temperature from temperature column, temperature_data, or celestial body surface temperature
      temperature = atmo.temperature
      if temperature.nil? && atmo.temperature_data.present?
        temperature = atmo.temperature_data['tropical_temperature'] || atmo.temperature_data['surface_temperature']
      end
      temperature ||= @celestial_body.surface_temperature

      {
        pressure: atmo.pressure&.round(4) || 0,
        temperature: temperature&.round(2) || 0,
        total_mass: atmo.total_atmospheric_mass&.round(2) || 0,
        composition: composition,
        scale_height: atmo.scale_height&.round(2),
        habitable: atmo.respond_to?(:habitable?) ? atmo.habitable? : false
      }
    end

    def hydrosphere_data
      return {} unless @celestial_body.hydrosphere

      hydro = @celestial_body.hydrosphere

      {
        water_coverage: (hydro.water_bodies&.dig('ocean', 'percentage') || 0),
        ocean_mass: (hydro.water_bodies&.dig('ocean', 'mass') || 0),
        ice_mass: (hydro.water_bodies&.dig('ice_caps', 'volume') || 0),
        total_water: hydro.total_water_mass&.round(2) || 0,
        average_depth: (hydro.water_bodies&.dig('ocean', 'average_depth') || 0),
        ice_coverage: (hydro.water_bodies&.dig('ice_caps', 'coverage') || 0)
      }
    end

    def geosphere_data
      return {} unless @celestial_body.geosphere

      geo = @celestial_body.geosphere
      activity_level = geo.geological_activity.to_i rescue 0

      {
        geological_activity: activity_level,
        tectonic_active: geo.tectonic_activity || false,
        volcanic_activity: (activity_level > 50 ? 'moderate' : 'low'),
        core_composition: geo.core_composition || {},
        crust_composition: geo.crust_composition || {},
        magnetic_field: 0 # Not in schema, placeholder
      }
    end

    def biosphere_data
      return {} unless @celestial_body.biosphere

      bio = @celestial_body.biosphere

      {
        biodiversity_index: (bio.biodiversity_index * 100)&.round(2) || 0,
        habitable_ratio: (bio.habitable_ratio * 100)&.round(2) || 0,
        life_forms_count: 0, # Not in schema
        biomass: 0, # Not in schema  
        primary_producers: 0 # Not in schema
      }
    end

    def planet_info_data
      {
        id: @celestial_body.id,
        name: @celestial_body.name,
        type: @celestial_body.type,
        mass: @celestial_body.mass,
        radius: @celestial_body.radius,
        gravity: @celestial_body.gravity&.round(3),
        surface_temperature: @celestial_body.surface_temperature&.round(2),
        orbital_period: @celestial_body.orbital_period&.round(2)
      }
    end

    def load_geological_features
      return [] unless @celestial_body.geosphere

      service = Lookup::PlanetaryGeologicalFeatureLookupService.new
      features = service.features_for_body_type(@celestial_body.type)

      features.map do |feature|
        {
          name: feature['name'],
          type: feature['type'],
          description: feature['description'],
          formation: feature['formation_process']
        }
      end
    rescue StandardError => e
      Rails.logger.error "Error loading geological features: #{e.message}"
      []
    end

    def load_ai_missions
      # Load AI missions for this celestial body
      # This will integrate with your AI Manager once implemented
      # For now, return test data structure
      [
        {
          id: 1,
          type: 'Resource Extraction',
          status: 'active',
          start_time: 2.hours.ago,
          target_body: @celestial_body.name,
          progress: 45,
          messages: [
            { time: 2.hours.ago, level: 'info', text: 'Mission initialized' },
            { time: 1.hour.ago, level: 'success', text: 'ISRU systems deployed' },
            { time: 30.minutes.ago, level: 'info', text: 'Oxygen production: 500kg/month' }
          ]
        }
      ]
    end

    def build_sphere_summary
      {
        atmosphere: @celestial_body.atmosphere.present?,
        hydrosphere: @celestial_body.hydrosphere.present?,
        geosphere: @celestial_body.geosphere.present?,
        biosphere: @celestial_body.biosphere.present?
      }
    end

    def run_resource_extraction_test
      # Simulate AI Manager resource extraction test
      # This will integrate with your rake tasks
      {
        success: true,
        test_type: 'resource_extraction',
        duration: '45 minutes',
        resources_extracted: {
          oxygen: 500,
          water: 200,
          regolith: 1000
        },
        isru_efficiency: 0.85,
        message: 'Resource extraction test completed successfully'
      }
    end

    def run_base_construction_test
      # Simulate AI Manager base construction test
      # This will integrate with your multi_mission_lunar_base_pipeline rake task
      {
        success: true,
        test_type: 'base_construction',
        phases_completed: 3,
        total_phases: 5,
        construction_time: '120 days',
        settlement_gcc: 95_000,
        message: 'Base construction test in progress - Phase 3/5 complete'
      }
    end

    def run_isru_pipeline_test
      # Simulate ISRU pipeline test
      # This will integrate with your isru_focused rake task
      {
        success: true,
        test_type: 'isru_pipeline',
        oxygen_produced: 10_000,
        water_produced: 5_000,
        fuel_produced: 2_000,
        earth_imports_reduced: 95,
        message: 'ISRU pipeline test completed - 95% Earth import reduction achieved'
      }
    end

    def run_gcc_bootstrap_test
      # AI Manager GCC Satellite Bootstrap Test
      # Tests if AI can recognize need for GCC generation and deploy mining satellite

      begin
        Rails.logger.info "AI Manager: Starting GCC bootstrap analysis"

        # Phase 1: System State Analysis
        gcc_satellites = Craft::Satellite::BaseSatellite.where("operational_data->>'craft_type' = ?", 'crypto_mining_satellite')
        gcc_generation_active = gcc_satellites.any?

        gcc_currency = Currency.find_by(symbol: 'GCC')
        usd_currency = Currency.find_by(symbol: 'USD')
        total_gcc_economy = Account.where(currency: gcc_currency).sum(:balance)

        bootstrap_needed = !gcc_generation_active && total_gcc_economy == 0

        Rails.logger.info "AI Manager: System analysis complete - Bootstrap needed: #{bootstrap_needed}"

        if bootstrap_needed
          Rails.logger.info "AI Manager: Bootstrap required - No GCC generation detected"

          # Phase 2: AI Decision Making
          learned_patterns = load_learned_patterns_for_ai
          gcc_pattern = find_gcc_deployment_pattern(learned_patterns)

          if gcc_pattern
            Rails.logger.info "AI Manager: Selected deployment pattern: #{gcc_pattern['name'] || 'GCC Satellite Deployment'}"
          else
            Rails.logger.info "AI Manager: Using default GCC deployment pattern"
          end

          # Phase 3: Execute Bootstrap
          Rails.logger.info "AI Manager: Executing GCC satellite deployment"

          bootstrap_result = execute_gcc_bootstrap_deployment

          if bootstrap_result[:success]
            Rails.logger.info "AI Manager: GCC bootstrap successful - Economy initialized"

            {
              success: true,
              test_type: 'gcc_bootstrap',
              bootstrap_completed: true,
              satellite_deployed: bootstrap_result[:satellite_name],
              gcc_generation_started: bootstrap_result[:mining_active],
              economic_bootstrapped: true,
              costs_incurred: bootstrap_result[:costs],
              message: 'GCC bootstrap successful - AI Manager initialized economy with mining satellite'
            }
          else
            Rails.logger.error "AI Manager: GCC bootstrap failed - #{bootstrap_result[:error]}"

            {
              success: false,
              test_type: 'gcc_bootstrap',
              bootstrap_completed: false,
              error: bootstrap_result[:error],
              message: 'GCC bootstrap failed - AI Manager unable to initialize economy'
            }
          end
        else
          Rails.logger.info "AI Manager: Bootstrap not required - GCC generation already active"

          {
            success: true,
            test_type: 'gcc_bootstrap',
            bootstrap_completed: false,
            reason: 'not_needed',
            message: 'GCC bootstrap not required - Economy already initialized'
          }
        end

      rescue => e
        Rails.logger.error "AI Manager: GCC bootstrap test error: #{e.message}"

        {
          success: false,
          test_type: 'gcc_bootstrap',
          error: e.message,
          message: 'GCC bootstrap test failed with error'
        }
      end
    end

    # Save uploaded file to temporary location
    def save_uploaded_file(uploaded_file)
      temp_file = Tempfile.new(['freeciv_import', '.sav'])
      temp_file.binmode
      temp_file.write(uploaded_file.read)
      temp_file.rewind
      temp_file
    end

    # Create a planetary body from imported FreeCiv data
    def create_imported_planetary_body(planet_data)
      # Determine the correct model class
      model_class = determine_model_class_from_data(planet_data)

      # Create the celestial body
      body = model_class.create!(planet_data.except(:atmosphere, :hydrosphere, :terrain_grid, :terrain_analysis))

      # Create associated data
      create_atmosphere_from_import(body, planet_data[:atmosphere]) if planet_data[:atmosphere]
      create_hydrosphere_from_import(body, planet_data[:hydrosphere]) if planet_data[:hydrosphere]

      # Store terrain grid in geosphere for rendering
      if body.geosphere && planet_data[:terrain_grid]
        terrain_map_data = {
          grid: planet_data[:terrain_grid],
          width: planet_data.dig(:properties, 'grid_width') || planet_data[:terrain_grid].first&.size || 0,
          height: planet_data.dig(:properties, 'grid_height') || planet_data[:terrain_grid].size,
          biome_counts: planet_data.dig(:properties, 'biome_counts') || {}
        }
        body.geosphere.update!(terrain_map: terrain_map_data)
      end

      # Store terrain grid in properties for later use
      body.properties['terrain_grid'] = planet_data[:terrain_grid]
      body.properties['terrain_analysis'] = planet_data[:terrain_analysis]
      body.save!

      body
    end

    # Update terrain data for an existing celestial body
    def update_body_terrain_data(body, barren_data, terraformed_data = nil)
      # Ensure geosphere exists for terrain storage
      unless body.geosphere
        body.create_geosphere!(
          crust_composition: {},
          mantle_composition: {},
          core_composition: {},
          total_crust_mass: 0.0,
          total_mantle_mass: 0.0,
          total_core_mass: 0.0,
          temperature: body.surface_temperature || 288,
          pressure: body.atmosphere&.pressure || 1.0,
          geological_activity: 50.0,
          tectonic_activity: false
        )
      end

      # Store barren terrain grid in geosphere for rendering
      terrain_map_data = {
        grid: barren_data[:grid],
        width: barren_data[:width],
        height: barren_data[:height],
        biome_counts: barren_data[:biome_counts] || {}
      }
      body.geosphere.update!(terrain_map: terrain_map_data)

      # Store barren terrain grid in properties for backup
      body.properties['terrain_grid'] = barren_data[:grid]
      body.properties['terrain_analysis'] = barren_data[:terrain_analysis]
      body.properties['grid_width'] = barren_data[:width]
      body.properties['grid_height'] = barren_data[:height]
      body.properties['biome_counts'] = barren_data[:biome_counts]
      body.properties['source'] = 'freeciv_import'
      body.properties['original_format'] = 'sav'

      # Store terraforming target metadata if terraformed data is available
      if terraformed_data
        body.properties['terraforming_target'] = {
          grid: terraformed_data[:grid],
          width: terraformed_data[:width],
          height: terraformed_data[:height],
          biome_counts: terraformed_data[:biome_counts],
          strategic_markers: terraformed_data[:strategic_markers],
          source_file: terraformed_data[:source_file]
        }
        body.properties['terraforming_progress'] = 0.0 # Start at 0%
      end

      # Store barren terrain strategic markers
      if barren_data[:strategic_markers]
        body.properties['strategic_markers'] = barren_data[:strategic_markers]
      end

      # Store hydrosphere analysis
      if barren_data[:hydrosphere_analysis]
        body.properties['hydrosphere_analysis'] = barren_data[:hydrosphere_analysis]
      end

      body.save!
    end

    # Determine model class from planet data
    def determine_model_class_from_data(planet_data)
      case planet_data[:type]
      when 'ocean_planet'
        CelestialBodies::Planets::Ocean::OceanPlanet
      when 'water_world'
        CelestialBodies::Planets::Ocean::WaterWorld
      else
        CelestialBodies::Planets::Rocky::TerrestrialPlanet
      end
    end

    # Create atmosphere from imported data
    def create_atmosphere_from_import(body, atmosphere_data)
      body.create_atmosphere!(
        composition: atmosphere_data[:composition],
        pressure: atmosphere_data[:pressure],
        total_atmospheric_mass: atmosphere_data[:total_atmospheric_mass]
      )
    end

    # Create hydrosphere from imported data
    def create_hydrosphere_from_import(body, hydrosphere_data)
      body.create_hydrosphere!(
        water_coverage: hydrosphere_data[:water_coverage],
        composition: hydrosphere_data[:composition],
        state_distribution: hydrosphere_data[:state_distribution]
      )
    end

    private

    def load_learned_patterns_for_ai
      pattern_file = Rails.root.join('data', 'json-data', 'ai-manager', 'learned_patterns.json')
      if File.exist?(pattern_file)
        JSON.parse(File.read(pattern_file))
      else
        {}
      end
    end

    def find_gcc_deployment_pattern(learned_patterns)
      # Look for GCC-related patterns
      gcc_patterns = learned_patterns.select do |key, pattern|
        key.include?('gcc') || key.include?('mining') || key.include?('crypto') ||
        (pattern['name'] && (pattern['name'].include?('GCC') || pattern['name'].include?('mining')))
      end

      # Return first GCC pattern found, or nil
      gcc_patterns.values.first
    end

    def execute_gcc_bootstrap_deployment
      begin
        Rails.logger.info "AI Manager: Setting up bootstrap organizations"

        # Setup organizations and funding
        setup_bootstrap_organizations_for_ai

        # Load mission data
        mission_data = load_gcc_mission_data_for_ai

        # Build satellite
        Rails.logger.info "AI Manager: Building GCC mining satellite"
        satellite = build_gcc_satellite_for_ai(mission_data)

        # Fit components
        Rails.logger.info "AI Manager: Fitting satellite components"
        fit_gcc_satellite_for_ai(satellite, mission_data)

        # Calculate and pay costs
        Rails.logger.info "AI Manager: Calculating deployment costs"
        cost_result = calculate_gcc_deployment_costs_for_ai(satellite)

        # Deploy and activate
        Rails.logger.info "AI Manager: Processing launch and deployment"
        deployment_result = deploy_gcc_satellite_for_ai(satellite)

        # Start mining operations
        Rails.logger.info "AI Manager: Starting GCC mining operations"
        mining_result = start_gcc_mining_for_ai(satellite, mission_data)

        Rails.logger.info "AI Manager: GCC bootstrap deployment completed successfully"

        {
          success: true,
          satellite_name: satellite.name,
          mining_active: mining_result[:mining_rate] > 0,
          costs: cost_result
        }

      rescue => e
        Rails.logger.error "AI Manager: Bootstrap deployment failed: #{e.message}"
        { success: false, error: e.message }
      end
    end

    def setup_bootstrap_organizations_for_ai
      @ldc_bootstrap = Organizations::BaseOrganization.find_or_create_by!(name: 'Lunar Development Corporation', identifier: 'LDC', organization_type: :corporation)
      @astrolift_bootstrap = Organizations::BaseOrganization.find_or_create_by!(name: 'AstroLift', identifier: 'ASTROLIFT', organization_type: :corporation)

      @gcc_currency_bootstrap = Currency.find_by(symbol: 'GCC')
      @usd_currency_bootstrap = Currency.find_by(symbol: 'USD')

      @ldc_gcc_account_bootstrap = Account.find_or_create_for_entity_and_currency(accountable_entity: @ldc_bootstrap, currency: @gcc_currency_bootstrap)
      @ldc_usd_account_bootstrap = Account.find_or_create_for_entity_and_currency(accountable_entity: @ldc_bootstrap, currency: @usd_currency_bootstrap)
      @astrolift_gcc_account_bootstrap = Account.find_or_create_for_entity_and_currency(accountable_entity: @astrolift_bootstrap, currency: @gcc_currency_bootstrap)
      @astrolift_usd_account_bootstrap = Account.find_or_create_for_entity_and_currency(accountable_entity: @astrolift_bootstrap, currency: @usd_currency_bootstrap)

      # Provide initial funding
      @ldc_gcc_account_bootstrap.deposit(100_000.00, "AI Bootstrap Initial GCC Fund")
      @ldc_usd_account_bootstrap.deposit(50_000.00, "AI Bootstrap Initial USD Fund")
      @astrolift_usd_account_bootstrap.deposit(20_000.00, "Launch Provider Working Capital")
    end

    def load_gcc_mission_data_for_ai
      manifest_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'crypto_mining_satellite_01_manifest_v2.json')
      task_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'gcc_satellite_mining_tasks_v1.json')

      manifest = JSON.parse(File.read(manifest_path), symbolize_names: true)
      tasks = File.exist?(task_path) ? JSON.parse(File.read(task_path), symbolize_names: true) : []

      { manifest: manifest, tasks: tasks }
    end

    def build_gcc_satellite_for_ai(mission_data)
      earth = CelestialBodies::CelestialBody.find_or_create_by!(name: 'Earth', celestial_body_type: 'terrestrial_planet', identifier: 'EARTH')
      orbit_location = Location::CelestialLocation.find_or_create_by!(coordinates: "0.00°N 0.00°E", celestial_body: earth)

      satellite = CraftFactoryService.build_from_blueprint(
        blueprint_id: mission_data[:manifest].dig(:craft, :blueprint_id),
        variant_data: mission_data[:manifest][:variant_data],
        owner: @ldc_bootstrap,
        location: orbit_location
      )

      raise "Satellite build failed" unless satellite&.persisted?

      if mission_data[:manifest][:operational_data]
        satellite.update!(operational_data: mission_data[:manifest][:operational_data])
      end

      orbit_location.update!(locationable: satellite)
      satellite.reload

      # Deploy to orbit
      valid_locations = satellite.operational_data.dig('deployment', 'deployment_locations') || []
      if valid_locations.include?('orbital')
        satellite.deploy('orbital', celestial_body: earth)
      else
        satellite.deploy('orbital', celestial_body: earth)
      end

      satellite
    end

    def fit_gcc_satellite_for_ai(satellite, mission_data)
      fit_data = mission_data[:manifest][:operational_data]['recommended_fit'] ||
                 mission_data[:manifest].dig(:variant_data, :recommended_fit) ||
                 satellite.operational_data['recommended_fit']

      if fit_data
        # Fit units
        if fit_data['units']
          fit_data['units'].each do |unit_data|
            result = FittingResult.fit_unit_to_craft(satellite, unit_data)
            Rails.logger.debug "AI Manager: Fitted unit #{unit_data['name'] || unit_data['unit_type']} - #{result.success? ? 'success' : 'failed'}"
          end
        end

        # Fit modules
        if fit_data['modules']
          fit_data['modules'].each do |module_data|
            result = FittingResult.fit_module_to_craft(satellite, module_data)
            Rails.logger.debug "AI Manager: Fitted module #{module_data['name'] || module_data['module_type']} - #{result.success? ? 'success' : 'failed'}"
          end
        end

        # Fit rigs
        if fit_data['rigs']
          fit_data['rigs'].each do |rig_data|
            result = FittingResult.fit_rig_to_craft(satellite, rig_data)
            Rails.logger.debug "AI Manager: Fitted rig #{rig_data['name'] || rig_data['rig_type']} - #{result.success? ? 'success' : 'failed'}"
          end
        end
      end

      satellite.reload
    end

    def calculate_gcc_deployment_costs_for_ai(satellite)
      # Construction cost
      construction_cost = satellite.base_units.sum { |unit| unit.operational_data.dig('cost', 'gcc') || 0 } +
                         satellite.modules.sum { |mod| mod.operational_data.dig('cost', 'gcc') || 0 } +
                         satellite.rigs.sum { |rig| rig.operational_data.dig('cost', 'gcc') || 0 }

      # Launch cost based on mass
      mass_kg = satellite.mass_kg
      launch_cost_per_kg = 544.22 # $/kg
      launch_cost_usd = mass_kg * launch_cost_per_kg

      { construction_gcc: construction_cost, launch_usd: launch_cost_usd, total: construction_cost + launch_cost_usd }
    end

    def deploy_gcc_satellite_for_ai(satellite)
      # Pay for launch using LaunchPaymentService
      launch_config = {
        pricing: {
          cost_per_kg: 544.22,
          currency: 'USD',
          include_construction: true,
          construction_multiplier: 0.8
        },
        payment: {
          methods: [
            { currency: 'GCC', max_percentage: 50 },
            { currency: 'USD', max_percentage: 100 }
          ],
          allow_bonds: true,
          bond_terms: {
            maturity_days: 180,
            description: "GCC Satellite Launch Bond"
          }
        }
      }

      LaunchPaymentService.pay_for_launch!(
        craft: satellite,
        customer_accounts: { gcc: @ldc_gcc_account_bootstrap, usd: @ldc_usd_account_bootstrap },
        provider_accounts: { gcc: @astrolift_gcc_account_bootstrap, usd: @astrolift_usd_account_bootstrap },
        launch_config: launch_config
      )

      { success: true }
    end

    def start_gcc_mining_for_ai(satellite, mission_data)
      # Run mission tasks
      if mission_data[:tasks].any?
        MissionTaskRunnerService.run(
          satellite: satellite,
          tasks: mission_data[:tasks],
          accounts: { ldc: @ldc_gcc_account_bootstrap, astrolift: @astrolift_gcc_account_bootstrap }
        )
      end

      # Check mining systems
      mining_units = satellite.base_units.select { |u| u.unit_type.include?('mining') }
      initial_mining = mining_units.sum { |unit| unit.operational_data.dig('mining', 'base_yield') || 0 }

      { mining_rate: initial_mining, units: mining_units.size }
    end
  end
end
