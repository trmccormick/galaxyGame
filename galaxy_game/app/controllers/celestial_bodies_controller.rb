class CelestialBodiesController < ApplicationController
  before_action :set_celestial_body, only: [:show, :edit, :update, :destroy, :map, :geological_features]

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

  # GET /celestial_bodies/new
  def new
    @celestial_body = CelestialBodies::Planets::Rocky::TerrestrialPlanet.new
  end

  # GET /celestial_bodies/:id/edit
  def edit
    # @celestial_body is set by before_action
    Rails.logger.info "Edit action - celestial_body: #{@celestial_body.inspect}"
  end

  # POST /celestial_bodies
  def create
    @celestial_body = CelestialBodies::CelestialBody.new(celestial_body_params)
    if @celestial_body.save
      respond_to do |format|
        format.html { redirect_to celestial_body_path(@celestial_body), notice: 'Celestial body was successfully created.' }
        format.json { render json: @celestial_body, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @celestial_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /celestial_bodies/:id
  def update
    if @celestial_body.update(celestial_body_params)
      respond_to do |format|
        format.html { redirect_to celestial_body_path(@celestial_body), notice: 'Celestial body was successfully updated.' }
        format.json { render json: @celestial_body }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @celestial_body.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /celestial_bodies/:id
  def destroy
    @celestial_body.destroy
    respond_to do |format|
      format.html { redirect_to celestial_bodies_url, notice: 'Celestial body was successfully destroyed.' }
      format.json { head :no_content }
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

  # Only allow a list of trusted parameters through.
  def celestial_body_params
    params.require(:celestial_body).permit(:name, :size, :gravity, :density, :radius, :orbital_period, :mass, :known_pressure, :temperature, :biomes, :status, :gas_quantities, :materials, :atmosphere, :surface_temperature)
  end
end