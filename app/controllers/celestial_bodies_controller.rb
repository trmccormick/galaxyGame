class CelestialBodiesController < ApplicationController
  def index
    @celestial_bodies = CelestialBody.all
    render json: @celestial_bodies
  end

  def show
    @celestial_body = CelestialBody.find(params[:id])
    render json: @celestial_body
  end

  def create
    @celestial_body = CelestialBody.new(celestial_body_params)
    if @celestial_body.save
      render json: @celestial_body, status: :created
    else
      render json: @celestial_body.errors, status: :unprocessable_entity
    end
  end

  def update
    @celestial_body = CelestialBody.find(params[:id])
    if @celestial_body.update(celestial_body_params)
      render json: @celestial_body
    else
      render json: @celestial_body.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @celestial_body = CelestialBody.find(params[:id])
    @celestial_body.destroy
    head :no_content
  end

  private

  def celestial_body_params
    params.require(:celestial_body).permit(:name, :type, :mass, :diameter)
  end
end