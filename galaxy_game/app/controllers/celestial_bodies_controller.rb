class CelestialBodiesController < ApplicationController
  # GET /celestial_bodies
  def index
    @celestial_bodies = CelestialBody.all
  end

  # GET /celestial_bodies/:id
  def show
    @celestial_body = CelestialBody.find(params[:id])
  end

  # POST /celestial_bodies
  def create
    @celestial_body = CelestialBody.new(celestial_body_params)
    if @celestial_body.save
      redirect_to @celestial_body, notice: 'Celestial body was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /celestial_bodies/:id
  def update
    @celestial_body = CelestialBody.find(params[:id])
    if @celestial_body.update(celestial_body_params)
      redirect_to @celestial_body, notice: 'Celestial body was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /celestial_bodies/:id
  def destroy
    @celestial_body = CelestialBody.find(params[:id])
    @celestial_body.destroy
    redirect_to celestial_bodies_url, notice: 'Celestial body was successfully destroyed.'
  end

  private

  # Only allow a list of trusted parameters through.
  def celestial_body_params
    params.require(:celestial_body).permit(:name, :size, :gravity, :density, :radius, :orbital_period, :mass, :known_pressure, :temperature, :biomes, :status, :gas_quantities, :materials)
  end
end
  