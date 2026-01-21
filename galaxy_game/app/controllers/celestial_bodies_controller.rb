class CelestialBodiesController < ApplicationController
  before_action :set_celestial_body, only: [:show, :map, :geological_features]

  # GET /celestial_bodies
  def index
    @celestial_bodies = CelestialBodies::CelestialBody.all
    respond_to do |format|
      format.html
      format.json { render json: @celestial_bodies }
    end
  end

  # GET /celestial_bodies/:id
  def show
    respond_to do |format|
      format.html
      format.json { render json: @celestial_body }
    end
  end

  # GET /celestial_bodies/:id/map
  def map
    # Render the planet map viewer
  end

  # GET /celestial_bodies/:id/geological_features
  def geological_features
    # Use the existing lookup service instead of GeologicalFeatureService
    lookup_service = Lookup::PlanetaryGeologicalFeatureLookupService.new(@celestial_body)
    
    features = {
      celestial_body: {
        id: @celestial_body.id,
        name: @celestial_body.name,
        identifier: @celestial_body.identifier
      },
      lava_tubes: lookup_service.features_by_type('lava_tube').map { |f| format_feature(f) },
      craters: lookup_service.features_by_type('crater').map { |f| format_feature(f) },
      strategic_sites: lookup_service.strategic_features.map { |f| format_feature(f) }
    }
    
    render json: features
  end

  private

  def format_feature(feature)
    {
      id: feature['id'],
      name: feature['name'],
      type: feature['feature_type'],
      lat: feature.dig('coordinates', 'latitude'),
      lon: feature.dig('coordinates', 'longitude'),
      priority: feature['priority'],
      strategic_value: feature['strategic_value'],
      dimensions: feature['dimensions'],
      resources: feature['resources'],
      tier: feature['tier'],
      discovered: feature['discovered']
    }
  end

  def set_celestial_body
    Rails.logger.info "set_celestial_body called with params[:id] = #{params[:id]}"
    begin
      @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
      Rails.logger.info "Found celestial_body: #{@celestial_body.class.name}"
    rescue => e
      Rails.logger.error "Error in set_celestial_body: #{e.class.name}: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      raise
    end
  end
end
