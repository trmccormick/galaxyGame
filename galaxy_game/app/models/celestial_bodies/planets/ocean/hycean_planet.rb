module CelestialBodies
  module Planets
    module Ocean
      class HyceanPlanet < OceanPlanet
        # Hycean planets are ocean worlds with hydrogen-rich atmospheres
        validates :atmosphere, presence: true
        validate :validate_hydrogen_atmosphere
        
        # Set STI type
        before_validation :set_sti_type
        
        # Hycean planets have different habitability characteristics
        def habitability_factors
          factors = super
          
          # Hycean-specific factors
          if atmosphere.present?
            # The hydrogen blanket creates a greenhouse effect
            factors[:greenhouse_effect] = "strong_hydrogen_blanket"
            
            # Potential for habitable pressure zones
            factors[:pressure_zones] = calculate_pressure_habitability
            
            # Wider temperature range for habitability due to pressure effects
            factors[:habitable_temperature_range] = "expanded"
          end
          
          factors
        end
        
        # Specific surface and atmospheric features
        def surface_features
          features = super
          
          # Add hydrogen-rich atmosphere features
          if atmosphere.present?
            features << "thick_atmospheric_layer"
            features << "hydrogen_dominated_atmosphere"
            features << "strong_greenhouse_effect"
            
            # Potential exotic cloud formations
            features << "exotic_cloud_formations"
            
            # Weather patterns
            features << "extreme_storm_systems" if atmosphere.pressure.to_f > 5.0
          end
          
          features
        end
        
        # Hycean planets can have different ocean compositions
        def ocean_chemistry
          return "unknown" unless hydrosphere.present? && hydrosphere.composition.present?
          
          # Hycean oceans often have dissolved gases from the atmosphere
          if hydrogen_percentage > 20
            "hydrogen_saturated"
          elsif atmosphere.gases.pluck(:name).include?("CH4")
            "methane_rich"
          else
            super
          end
        end
        
        # Unique to hycean planets - estimate habitable layer depth
        def habitable_layer_depth
          return nil unless atmosphere && hydrosphere

          ocean_depth = calculate_average_ocean_depth
          pressure = atmosphere.pressure.to_f
          min_depth = pressure * 100
          max_depth = [ocean_depth * 0.7, min_depth + 5000].max
          {
            minimum_depth: min_depth.round,
            maximum_depth: max_depth.round
          }
        end
        
        private

        def set_sti_type
          self.type = 'CelestialBodies::Planets::Ocean::HyceanPlanet'
        end

        def hydrogen_percentage
          return 0 unless atmosphere.present? && atmosphere.gases.any?
          h2_gas = atmosphere.gases.find_by(name: "H2")
          h2_gas&.percentage.to_f
        end

        def validate_hydrogen_atmosphere
          return unless atmosphere.present?
          if hydrogen_percentage < 10.0
            errors.add(:atmosphere, "must contain at least 10% hydrogen for a Hycean planet")
          end
          if atmosphere.pressure.to_f < 1.0
            errors.add(:atmosphere, "must have significant pressure (>1 atm) for a Hycean planet")
          end
        end

        def calculate_pressure_habitability
          return 0 unless atmosphere.present?
          pressure = atmosphere.pressure.to_f
          if pressure.between?(10, 100)
            3 # Optimal pressure range for exotic biochemistry
          elsif pressure.between?(1, 10) || pressure.between?(100, 1000)
            2 # Potentially habitable with adaptations
          else
            1 # Challenging but not impossible
          end
        end

        def calculate_average_ocean_depth
          # Default depth if no hydrosphere data
          return 50_000 unless hydrosphere && surface_area && surface_area > 0

          # Get ocean coverage area
          ocean_area = hydrosphere.liquid_bodies&.dig('oceans').to_f
          return 50_000 if ocean_area <= 0

          # Calculate volume from mass (assuming water density ~1000 kg/m³)
          water_mass = hydrosphere.total_hydrosphere_mass || 1.2e22
          water_volume = water_mass / 1000.0

          # Average depth = volume / area
          depth = (water_volume / ocean_area).round

          # Sanity check - return reasonable default if calculation seems off
          depth > 0 ? depth : 50_000
        end
      end
    end
  end
end