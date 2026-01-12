# app/models/celestial_bodies/planets/rocky/rocky_planet.rb
module CelestialBodies
  module Planets
    module Rocky
      class RockyPlanet < Planet
        include SolidBodyConcern
        
        # Rocky planet specific attributes and behavior
        validates :density, numericality: { greater_than: 3.0 }, allow_nil: true
        
        def calculate_geological_activity
          # Basic formula based on mass and age
          # More mass = more internal heat = more activity
          # Older planet = less activity
          return 50 unless age.present? # Default value if age unknown
          
          age_factor = [1.0 - (age / 10.0e9), 0.1].max
          mass_factor = [earth_masses, 0.1].max
          
          activity_score = 50 * mass_factor * age_factor
          [activity_score, 100.0].min
        end
        
        def potential_for_plate_tectonics
          return 0 unless mass.present? && radius.present?
          
          # Larger planets with moderate density have better potential for plate tectonics
          mass_factor = [earth_masses, 0.1].max
          radius_factor = [earth_radii, 0.1].max
          
          # Equation based on planetary physics - more mass, appropriate radius = more likely to have plate tectonics
          tectonic_potential = 50 * (mass_factor * 0.7 + radius_factor * 0.3)
          [tectonic_potential, 100.0].min
        end
        
        def dominant_surface_feature
          return :unknown unless hydrosphere.present? && atmosphere.present?
          
          water_coverage = hydrosphere.water_coverage.to_f
          average_temperature = surface_temperature.to_f
          has_atmosphere = atmosphere.gases.any?
          
          case
          when water_coverage > 75
            :ocean_world
          when water_coverage > 40
            :continental
          when average_temperature > 373 && has_atmosphere
            :steam_world
          when average_temperature < 273 && water_coverage > 20
            :ice_world
          when average_temperature > 500
            :molten_surface
          when !has_atmosphere && average_temperature < 200
            :barren
          else
            :mixed_terrain
          end
        end
        
        def estimate_core_size
          return nil unless radius.present? && density.present?
          
          # Estimate core radius as a percentage of total radius
          # Higher density generally means larger core relative to size
          density_factor = [density / 5.5, 0.2].max # 5.5 g/cm³ is Earth's density
          
          # Earth's core is about 55% of its radius
          core_percentage = 0.55 * density_factor
          
          # Return estimated core radius in meters
          (radius * core_percentage).round
        end
      end
    end
  end
end