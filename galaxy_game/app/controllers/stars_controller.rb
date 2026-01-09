class StarsController < ApplicationController
  before_action :set_star, only: [:show, :update, :destroy]

  def index
    @stars = CelestialBodies::Star.all
    render json: @stars
  end

  def show
    render json: @star
  end

  def create
    @star = CelestialBodies::Star.new(star_params)
    if @star.save
      render json: @star, status: :created
    else
      render json: @star.errors, status: :unprocessable_entity
    end
  end

  def update
    if @star.update(star_params)
      render json: @star
    else
      render json: @star.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @star.destroy
  end

  private

  def set_star
    @star = CelestialBodies::Star.find(params[:id])
  end

  def star_params
    params.require(:star).permit(:name, :identifier, :type_of_star, :age, :mass, :radius, :temperature, :luminosity, :life, :r_ecosphere, properties: {})
  end
end

