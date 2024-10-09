class CelestialBodiesController < ApplicationController
  # GET /celestial_bodies
  def index
    @celestial_bodies = CelestialBody.all
    render json: @celestial_bodies
  end

  # GET /celestial_bodies/:id
  def show
    @celestial_body = CelestialBody.find(params[:id])
    render json: @celestial_body
  end

  # POST /celestial_bodies
  def create
    @celestial_body = CelestialBody.new(celestial_body_params)
    if @celestial_body.save
      render json: @celestial_body, status: :created
    else
      render json: @celestial_body.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /celestial_bodies/:id
  def update
    @celestial_body = CelestialBody.find(params[:id])
    if @celestial_body.update(celestial_body_params)
      render json: @celestial_body
    else
      render json: @celestial_body.errors, status: :unprocessable_entity
    end
  end

  # DELETE /celestial_bodies/:id
  def destroy
    @celestial_body = CelestialBody.find(params[:id])
    @celestial_body.destroy
    head :no_content
  end

  private

  # Only allow a list of trusted parameters through.
  def celestial_body_params
    params.require(:celestial_body).permit(:name, :size, :gravity, :density, :radius, :orbital_period, :mass, :known_pressure, :temperature, :biomes, :status, :gas_quantities, :materials)
  end
end