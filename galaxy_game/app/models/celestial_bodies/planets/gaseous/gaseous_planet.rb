# app/models/celestial_bodies/planets/gaseous/gaseous_planet.rb
module CelestialBodies
  module Planets
    module Gaseous
      class GaseousPlanet < Planet
        # Gaseous planet specific attributes
        validates :density, numericality: { less_than: 2.0 }, allow_nil: true
        
        # Methods to define the characteristics of gaseous planets
        def has_solid_surface?
          false
        end
        
        def calculate_bands
          return 2 if rotational_period.nil?
          
          # Faster rotation = more bands (simple approximation)
          if rotational_period < 15 * 3600 # 15 hours in seconds
            rand(6..12) # Many bands like Jupiter
          else
            rand(2..5)  # Fewer bands
          end
        end
        
        # Method to calculate blackbody temperature
        def calculate_blackbody_temperature
          return 100 unless solar_system&.primary_star && semi_major_axis # Default if no star data
          
          star = solar_system.primary_star
          # Basic blackbody calculation
          star.temperature * Math.sqrt(star.radius / (2 * semi_major_axis * 1.496e11))
        end
      end
    end
  end
end