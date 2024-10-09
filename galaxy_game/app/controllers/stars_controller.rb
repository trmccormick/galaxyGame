class StarsController < ApplicationController
  before_action :set_star, only: [:show, :update, :destroy]

  def index
    @stars = Star.all
    render json: @stars
  end

  def show
    render json: @star
  end

  def create
    @star = Star.new(star_params)
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
    @star = Star.find(params[:id])
  end

  def star_params
    params.require(:star).permit(:name, :type_of_star, :age, :mass, :radius, :temperature, :luminosity, :life, :r_ecosphere)
  end
end

