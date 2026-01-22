# frozen_string_literal: true

module Admin
  # Admin solar systems controller
  # Provides hierarchical navigation for solar systems within galaxies
  class SolarSystemsController < ApplicationController
    def index
    @solar_systems = safe_query(SolarSystem.includes(:galaxy, :stars, :celestial_bodies)
                                         .order('galaxies.name, solar_systems.name')
                                         .limit(100))
    @galaxies = safe_query(Galaxy.includes(:solar_systems).order(:name))
    @system_stats = calculate_system_stats
  end

  def show
    @solar_system = safe_find(SolarSystem, params[:id], includes: [:galaxy, :stars, :celestial_bodies])
    @celestial_bodies = safe_query(@solar_system.celestial_bodies.includes(:atmosphere).order(:name)) if @solar_system
  end

  private

    def calculate_system_stats
      {
        total_systems: safe_count(SolarSystem),
        systems_with_stars: safe_count(SolarSystem.joins(:stars).distinct),
        habitable_systems: count_habitable_systems,
        total_galaxies: safe_count(Galaxy),
        avg_bodies_per_system: average_bodies_per_system
      }
    rescue StandardError => e
      Rails.logger.error "Error calculating system stats: #{e.message}"
      {
        total_systems: 0,
        systems_with_stars: 0,
        habitable_systems: 0,
        total_galaxies: 0,
        avg_bodies_per_system: 0
      }
    end

    def safe_count(query)
      query.count
    rescue StandardError
      0
    end

    def safe_query(query)
      query.to_a
    rescue StandardError
      []
    end

    def safe_find(model, id, includes: [])
      if includes.any?
        model.includes(*includes).find(id)
      else
        model.find(id)
      end
    rescue StandardError
      nil
    end

    def count_habitable_systems
      # Systems with at least one habitable planet
      SolarSystem.joins(:celestial_bodies)
                 .where(celestial_bodies: { body_type: ['terrestrial_planet', 'super_earth'] })
                 .where('celestial_bodies.surface_temperature > ? AND celestial_bodies.surface_temperature < ?',
                        250, 350)
                 .distinct.count
    rescue StandardError
      0
    end

    def average_bodies_per_system
      total_bodies = safe_count(CelestialBodies::CelestialBody)
      total_systems = safe_count(SolarSystem)
      total_systems.positive? ? (total_bodies.to_f / total_systems).round(1) : 0
    rescue StandardError
      0
    end
  end
end