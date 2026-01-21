class SolarSystemsController < ApplicationController
  def index
    @solar_systems = SolarSystem.includes(:stars, :celestial_bodies).order(:name)
  end

  def show
    @solar_system = SolarSystem.includes(:galaxy, :stars, :celestial_bodies).find(params[:id])
    @celestial_bodies = @solar_system.celestial_bodies.includes(:atmosphere).order(:name) if @solar_system
  end
end
