module CelestialBodies
  module Planets
    module Ocean
      class OceanPlanet < Planet
        include SolidBodyConcern
        
        # Ocean planets should have significant water
        validates :hydrosphere, presence: true
        validate :validate_minimum_water_coverage
        
        # Common attributes for ocean planets
        before_validation :set_sti_type
        
        # Base habitability factors for ocean planets
        def habitability_factors
          factors = {}
          
          if hydrosphere.present?
            # Base water-related factors
            water_coverage = hydrosphere.water_coverage.to_f
            factors[:aquatic_environment] = water_coverage > 50 ? "dominant" : "significant"
            
            # Chemical composition of ocean
            if hydrosphere.composition.present?
              factors[:water_chemistry] = analyze_water_chemistry
            end
          end
          
          # Temperature effects on habitability
          if surface_temperature.present?
            if surface_temperature.between?(273, 373)
              factors[:temperature_state] = "liquid_water_possible"
            elsif surface_temperature < 273
              factors[:temperature_state] = "frozen_surface"
            else
              factors[:temperature_state] = "vapor_dominated"
            end
          end
          
          factors
        end
        
        # Basic ocean planet features
        def surface_features
          features = []
          
          if hydrosphere.present?
            water_coverage = hydrosphere.water_coverage.to_f
            
            # Basic water features
            features << "significant_bodies_of_water"
            features << "coastal_zones"
            
            if water_coverage > 70
              features << "ocean_dominated"
            end
            
            # Temperature dependent features
            if surface_temperature.present?
              if surface_temperature < 273
                features << "ice_formations"
              elsif surface_temperature > 373
                features << "vapor_clouds"
              else
                features << "liquid_oceans"
              end
            end
          end
          
          features
        end
        
        # Common calculation for all ocean planets
        def water_volume
          return 0 unless radius.present? && hydrosphere.present?
          
          planet_volume = (4.0/3.0) * Math::PI * (radius**3)
          water_percentage = hydrosphere.water_coverage.to_f / 100.0
          
          # Estimate water layer thickness
          water_layer_ratio = water_percentage * 0.05 # Rough approximation
          water_volume = planet_volume * water_layer_ratio
          
          water_volume.to_f
        end
        
        protected
        
        def analyze_water_chemistry
          return "unknown" unless hydrosphere.composition.present?
          
          composition = hydrosphere.composition
          
          if composition["salts"].to_f > 10
            "highly_saline"
          elsif composition["salts"].to_f > 3
            "moderately_saline"
          else
            "low_salinity"
          end
        end
        
        def validate_minimum_water_coverage
          return unless hydrosphere.present?
          
          if hydrosphere.water_coverage.to_f < 30.0
            errors.add(:hydrosphere, "water coverage must be at least 30% for an ocean planet")
          end
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Ocean::OceanPlanet' if self.class == OceanPlanet
        end
      end
    end
  end
end