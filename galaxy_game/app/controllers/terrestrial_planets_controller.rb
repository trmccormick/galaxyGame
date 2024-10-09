class TerrestrialPlanetsController < ApplicationController
    before_action :set_terrestrial_planet, only: %i[show update destroy]
  
    # GET /terrestrial_planets
    def index
      @terrestrial_planets = TerrestrialPlanet.all
      render json: @terrestrial_planets
    end
  
    # GET /terrestrial_planets/1
    def show
      render json: @terrestrial_planet
    end
  
    # POST /terrestrial_planets
    def create
        @terrestrial_planet = TerrestrialPlanet.new(planet_params)
        if @terrestrial_planet.save
          TerraSim.new.calc_current  # or pass @terrestrial_planet to TerraSim if needed
          render json: @terrestrial_planet, status: :created
        else
          render json: @terrestrial_planet.errors, status: :unprocessable_entity
        end
    end
  
    # PATCH/PUT /terrestrial_planets/1
    def update
      if @terrestrial_planet.update(terrestrial_planet_params)
        render json: @terrestrial_planet
      else
        render json: @terrestrial_planet.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /terrestrial_planets/1
    def destroy
        @terrestrial_planet = TerrestrialPlanet.find(params[:id])
        @terrestrial_planet.destroy
        head :no_content
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_terrestrial_planet
      @terrestrial_planet = TerrestrialPlanet.find(params[:id])
    end
  
    # Only allow a list of trusted parameters through.
    def terrestrial_planet_params
    params.require(:terrestrial_planet).permit(
        :name, :size, :gravity, :density, :orbital_period, :mass, 
        :surface_temperature, :atmosphere_composition, :geological_activity, 
        :biomes, :status, :atmospheric_pressure
    )
    end
  end
  