# frozen_string_literal: true

module Admin
  # Admin galaxies controller
  # Provides overview of all galaxies and their solar systems
  class GalaxiesController < ApplicationController
    def index
      @galaxies = Galaxy.includes(:solar_systems)
                        .order(:name)

      @galaxy_stats = calculate_galaxy_stats
    end

    def show
      @galaxy = Galaxy.includes(solar_systems: [:stars, :celestial_bodies])
                      .find(params[:id])

      @solar_systems = @galaxy.solar_systems
                              .includes(:stars, :celestial_bodies)
                              .order(:name)
    end

    private

    def calculate_galaxy_stats
      {
        total_galaxies: Galaxy.count,
        total_systems: SolarSystem.count,
        avg_systems_per_galaxy: average_systems_per_galaxy,
        galaxy_types: galaxy_type_breakdown
      }
    end

    def average_systems_per_galaxy
      total_galaxies = Galaxy.count
      total_systems = SolarSystem.count
      total_galaxies.positive? ? (total_systems.to_f / total_galaxies).round(1) : 0
    end

    def galaxy_type_breakdown
      Galaxy.group(:galaxy_type).count.transform_keys { |key| key&.humanize || 'Unknown' }
    end
  end
end