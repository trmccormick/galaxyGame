# frozen_string_literal: true

module Admin
  # Admin controller for celestial body monitoring and testing
  # Provides AI Manager testing interface with SimEarth aesthetic
  class CelestialBodiesController < ApplicationController
    before_action :set_celestial_body, only: [:monitor, :sphere_data, :mission_log, :run_ai_test]

    # GET /admin/celestial_bodies
    # Index page listing all celestial bodies for monitoring selection
    def index
      @celestial_bodies = CelestialBodies::CelestialBody.all.order(:name)
      @total_bodies = @celestial_bodies.count
      @bodies_by_category = @celestial_bodies.group_by(&:body_category)

      # Calculate statistics for major categories
      @category_stats = {
        stars: @bodies_by_category['star']&.count || 0,
        brown_dwarfs: @bodies_by_category['brown_dwarf']&.count || 0,
        planets: count_planet_types,
        moons: count_moon_types,
        minor_bodies: count_minor_body_types,
        other: (@bodies_by_category['alien_life_form']&.count || 0) + (@bodies_by_category['material']&.count || 0)
      }
    end

    private

    def count_planet_types
      planet_categories = ['terrestrial_planet', 'carbon_planet', 'lava_world', 'super_earth',
                          'gas_giant', 'ice_giant', 'hot_jupiter', 'hycean_planet',
                          'ocean_planet', 'water_world']
      planet_categories.sum { |cat| @bodies_by_category[cat]&.count || 0 }
    end

    def count_moon_types
      moon_categories = ['moon', 'large_moon', 'small_moon', 'ice_moon']
      moon_categories.sum { |cat| @bodies_by_category[cat]&.count || 0 }
    end

    def count_minor_body_types
      minor_categories = ['asteroid', 'comet', 'dwarf_planet', 'kuiper_belt_object']
      minor_categories.sum { |cat| @bodies_by_category[cat]&.count || 0 }
    end

    # GET /admin/celestial_bodies/:id/monitor
    # Main monitoring interface with three-panel layout
    def monitor
      @planet_map = @celestial_body.respond_to?(:planet_map) ? @celestial_body.planet_map : nil
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
               else
                 { success: false, error: 'Unknown test type' }
               end

      render json: result
    end

    private

    def set_celestial_body
      @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Celestial body not found'
    end

    def atmosphere_data
      return {} unless @celestial_body.atmosphere

      atmo = @celestial_body.atmosphere
      composition = @celestial_body.atmospheric_composition || {}

      {
        pressure: atmo.pressure&.round(4) || 0,
        temperature: atmo.temperature&.round(2) || 0,
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
        ice_mass: (hydro.water_bodies&.dig('ice', 'mass') || 0),
        total_water: hydro.total_water_mass&.round(2) || 0,
        average_depth: (hydro.water_bodies&.dig('ocean', 'average_depth') || 0),
        ice_coverage: (hydro.water_bodies&.dig('ice', 'percentage') || 0)
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
  end
end
