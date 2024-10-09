class PlanetsController < ApplicationController
    before_action :set_planet, only: [:show, :edit, :update, :destroy, :calculate_habitability]
  
    # GET /planets
    # GET /planets.json
    def index
      @planets = Planet.all
    end
  
    # GET /planets/1
    # GET /planets/1.json
    def show
    end
  
    # GET /planets/new
    def new
      @planet = Planet.new
    end
  
    # GET /planets/1/edit
    def edit
    end
  
    # POST /planets
    # POST /planets.json
    def create
      @planet = Planet.new(planet_params)
  
      respond_to do |format|
        if @planet.save
          format.html { redirect_to @planet, notice: 'Planet was successfully created.' }
          format.json { render :show, status: :created, location: @planet }
        else
          format.html { render :new }
          format.json { render json: @planet.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /planets/1
    # PATCH/PUT /planets/1.json
    def update
      respond_to do |format|
        if @planet.update(planet_params)
          format.html { redirect_to @planet, notice: 'Planet was successfully updated.' }
          format.json { render :show, status: :ok, location: @planet }
        else
          format.html { render :edit }
          format.json { render json: @planet.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /planets/1
    # DELETE /planets/1.json
    def destroy
      @planet.destroy
      respond_to do |format|
        format.html { redirect_to planets_url, notice: 'Planet was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    # POST /planets/1/calculate_habitability
    def calculate_habitability
      @planet.calculate_habitability
      respond_to do |format|
        format.html { redirect_to @planet, notice: 'Habitability was successfully calculated.' }
        format.json { render :show, status: :ok, location: @planet }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_planet
        @planet = Planet.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def planet_params
        params.require(:planet).permit(:type, :surface_temperature, :atmosphere_composition, :geological_activity)
      end
  end
  