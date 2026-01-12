module CelestialBodies
  module Planets
    module Rocky
      class LavaWorld < RockyPlanet
        # Lava worlds are extremely hot with molten surface
        validates :surface_temperature, numericality: { greater_than: 700 }, allow_nil: true
        
        # Set STI type
        before_validation :set_sti_type
        
        # Lava worlds are often tidally locked or close to their stars
        validates :orbital_period, numericality: { less_than: 100 * 24 * 3600 }, allow_nil: true # Less than 100 days
        
        # Override habitability score - lava worlds are not habitable
        def habitability_score
          0
        end
        
        # Specialized atmospheric composition for lava worlds
        def expected_atmosphere_composition
          {
            'SO2' => 30,
            'CO2' => 45,
            'CO' => 15,
            'O2' => 5,
            'S2' => 5
          }
        end
        
        # Calculate surface cooling rate
        def surface_cooling_rate
          return 0 unless surface_temperature.present? && atmosphere.present?
          
          # Base cooling rate in K per 1000 years
          base_cooling = 0.5
          
          # Factors affecting cooling:
          # 1. Atmosphere thickness (thicker = slower cooling)
          # 2. Distance from star (closer = slower cooling)
          # 3. Current temperature (hotter = faster cooling)
          
          atmo_factor = [1.0 - (atmosphere.pressure.to_f / 10.0), 0.1].max
          
          distance_factor = 1.0
          if star_distances.any?
            dist = star_distances.first.distance.to_f
            distance_factor = [dist / 0.5, 0.2].max # 0.5 AU reference
          end
          
          temp_factor = [surface_temperature.to_f / 1000.0, 0.1].max
          
          # Calculate cooling rate
          cooling_rate = base_cooling * atmo_factor * distance_factor * temp_factor
          
          # Return in K per 1000 years
          cooling_rate
        end
        
        # Special surface features for lava worlds
        def surface_features
          [
            "active_lava_flows",
            "magma_oceans",
            "volcanic_plains",
            "sulfur_lakes",
            "obsidian_formations",
            "continuous_eruptions",
            "silicon_vapor_clouds",
            "metallic_precipitation"
          ]
        end
        
        # Many lava worlds are tidally locked
        def tidally_locked?
          # Estimate based on proximity to star
          # Planets very close to their stars tend to become tidally locked
          return false unless star_distances.any?
          
          distance = star_distances.first.distance.to_f
          star_mass = star_distances.first.star.mass.to_f
          
          # Simple approximation: planets within ~0.1 AU of a solar-mass star
          # are likely to be tidally locked
          tidal_lock_threshold = 0.1 * (star_mass / 1.989e30) # Scale with star mass
          
          distance < tidal_lock_threshold
        end
        
        # Extreme day-night temperature gradient if tidally locked
        def day_night_temperature_difference
          return 0 unless tidally_locked? && surface_temperature.present?
          
          # Day side temperature is the surface temperature
          day_temp = surface_temperature
          
          # Night side temperature depends on atmosphere
          if atmosphere.present? && atmosphere.pressure.to_f > 1.0
            # Thick atmosphere distributes heat better
            night_temp = day_temp * 0.7
          else
            # Thin/no atmosphere means extreme differences
            night_temp = day_temp * 0.2
          end
          
          day_temp - night_temp
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Rocky::LavaWorld'
        end
      end
    end
  end
end