module CelestialBodies
  module Planets
    module Ocean
      class WaterWorld < OceanPlanet
        # Water worlds have more extreme water coverage
        validate :validate_water_world_coverage
        
        # Set STI type
        before_validation :set_sti_type
        
        # Override and extend parent methods
        def habitability_factors
          factors = super
          
          # Additional water world specific factors
          if hydrosphere.present?
            # Ocean depth affects pressure and temperature gradients
            factors[:depth_zones] = calculate_depth_zones
            
            # More water = potentially more diverse aquatic ecosystems
            factors[:aquatic_life_potential] = hydrosphere.water_coverage.to_f / 20.0
          end
          
          factors
        end
        
        # Override with more specific water world features
        def surface_features
          features = super
          
          # Remove generic features that don't apply
          features.delete("significant_bodies_of_water")
          features.delete("coastal_zones")
          
          # Add water world specific features
          features << "global_ocean"
          features << "seafloor_terrain"
          
          # Island formations if less than 100% water
          if hydrosphere.water_coverage.to_f < 98
            features << "scattered_islands"
            features << "archipelagos"
          else
            features << "no_exposed_land"
          end
          
          # Underwater features
          features << "oceanic_trenches"
          features << "underwater_mountains"
          
          # Extreme water coverage features
          if hydrosphere.water_coverage.to_f >= 95
            features << "pelagic_world"
          end
          
          # Atmosphere-ocean interactions
          if atmosphere.present? && atmosphere.pressure.to_f > 0.5
            features << "storm_systems"
            features << "oceanic_currents"
          end
          
          features
        end
        
        # Calculate ocean depth based on planet characteristics
        def average_ocean_depth
          return 0 unless hydrosphere.present? && radius.present?
          
          # Base calculation from planet size and water content
          planet_radius_km = radius / 1000.0
          water_volume_factor = hydrosphere.water_coverage.to_f / 100.0
          
          # Scaling factor - larger planets can have deeper oceans
          size_factor = [planet_radius_km / 6371.0, 0.5].max # Normalized to Earth
          
          # Typical ocean depths range from 3-11 km on Earth
          base_depth = 5000 # 5 km base depth
          calculated_depth = base_depth * size_factor * water_volume_factor * 1.5
          
          # Cap at reasonable values
          [calculated_depth, 20000].min # Maximum 20 km depth
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Ocean::WaterWorld'
        end
        
        def validate_water_world_coverage
          return unless hydrosphere.present?
          
          if hydrosphere.water_coverage.to_f < 65.0
            errors.add(:hydrosphere, "water coverage must be at least 65% for a water world")
          end
        end
        
        def calculate_depth_zones
          depth = average_ocean_depth
          
          if depth < 5000
            1
          elsif depth < 10000
            2
          elsif depth < 15000
            3
          else
            4
          end
        end
      end
    end
  end
end