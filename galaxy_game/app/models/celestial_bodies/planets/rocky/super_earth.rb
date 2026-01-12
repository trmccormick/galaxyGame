module CelestialBodies
  module Planets
    module Rocky
      class SuperEarth < TerrestrialPlanet
        # Super Earths are larger and more massive than Earth
        validates :mass, numericality: { greater_than: 2e24, less_than: 6e25 }, allow_nil: true
        validates :radius, numericality: { greater_than: 7e6, less_than: 15e6 }, allow_nil: true
        
        # Set STI type
        before_validation :set_sti_type
        
        # Super Earths typically have stronger gravity
        validates :gravity, numericality: { greater_than: 10.0 }, allow_nil: true
        
        # Higher geological activity due to greater internal heat
        def calculate_geological_activity
          base_activity = super
          # Super Earths retain more internal heat
          mass_bonus = (mass.to_f / 5.97e24 - 1) * 20 # +20% for each Earth mass above 1
          [base_activity + mass_bonus, 100.0].min
        end
        
        # Different atmospheric retention capabilities
        def atmospheric_retention_factor
          return 1.0 unless mass.present? && radius.present?
          
          # Calculate escape velocity: v_escape = sqrt(2GM/R)
          escape_velocity = Math.sqrt(2 * GameConstants::GRAVITATIONAL_CONSTANT * mass / radius)
          
          # Normalized to Earth's escape velocity (11.2 km/s)
          escape_factor = escape_velocity / 11200.0
          
          # Higher escape velocity = better gas retention
          [escape_factor, 0.1].max
        end
        
        # Super Earths often have thicker atmospheres
        def expected_atmospheric_pressure
          return 1.0 unless gravity.present?
          
          # Simple scaling with gravity, normalized to Earth
          earth_gravity = 9.8
          gravity_ratio = gravity / earth_gravity
          
          # Pressure scales roughly with gravity
          base_pressure = 1.0 # Earth's pressure in bar
          base_pressure * (gravity_ratio ** 1.3) # Non-linear scaling
        end
        
        # More varied surface features due to stronger tectonic forces
        def surface_features
          features = super
          
          # Add Super Earth specific features
          features << "extreme_mountain_ranges" # Higher gravity creates taller mountains
          features << "deep_ocean_trenches" if hydrosphere.present? && hydrosphere.water_coverage.to_f > 30
          features << "massive_shield_volcanoes" if geosphere.present? && geosphere.geological_activity.to_f > 50
          features << "dense_atmospheric_layers" if atmosphere.present? && atmosphere.pressure.to_f > 1.5
          
          features
        end
        
        # Super Earths may have stronger magnetic fields
        def magnetic_field_strength
          return 0 unless mass.present? && rotational_period.present?
          
          # Earth's magnetic field strength is approximately 0.25-0.65 gauss
          earth_field = 0.5
          
          # Mass and rotation both contribute to dynamo effect
          mass_factor = (mass / 5.97e24) ** 0.5
          rotation_factor = [24.0 / rotational_period.to_f, 0.1].max # Faster rotation = stronger field
          
          earth_field * mass_factor * rotation_factor
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Rocky::SuperEarth'
        end
      end
    end
  end
end