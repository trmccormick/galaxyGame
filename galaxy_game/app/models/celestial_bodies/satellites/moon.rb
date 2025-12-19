# app/models/celestial_bodies/satellites/moon.rb
module CelestialBodies
  module Satellites
    class Moon < Satellite
      # Base validations
      validates :orbital_period, numericality: { greater_than: 0 }, allow_nil: true
      validates :rotational_period, numericality: { greater_than: 0 }, allow_nil: true
      
      # Set STI type
      before_validation :set_sti_type
      before_validation :set_default_rotation
      
      # ✅ REMOVE this - it conflicts with Satellite's parent_celestial_body
      # belongs_to :parent_body, class_name: 'CelestialBodies::CelestialBody', 
      #           foreign_key: 'parent_body_id', optional: true
      
      # ✅ Add alias method to maintain compatibility
      alias_method :parent_body, :parent_celestial_body
      alias_method :parent_body=, :parent_celestial_body=
      
      # Shared methods
      def orbits_planet?
        parent_celestial_body.present? && 
        (parent_celestial_body.type.include?('::Planets::') || parent_celestial_body.type.include?('::DwarfPlanet'))
      end
      
      def calculate_tidal_forces
        return 0 unless parent_celestial_body.present? && mass.present? && radius.present? && orbital_period.present?
        
        parent_mass = parent_celestial_body.mass.to_f
        orbital_period_seconds = orbital_period.to_f * 24 * 3600
        
        # Simplified tidal force calculation using orbital period
        tidal_force = parent_mass / (orbital_period_seconds ** 2)
        tidal_force
      end
      
      def tidally_locked?
        return false unless rotational_period.present? && orbital_period.present?
        
        period_ratio = (rotational_period - orbital_period).abs / orbital_period
        period_ratio < 0.05  # Within 5% tolerance
      end
      
      def day_length_hours
        return nil unless rotational_period.present?
        rotational_period * 24  # Convert days to hours
      end
      
      def temperature_variation
        return :extreme if rotational_period.nil? || rotational_period > 100
        return :none if tidally_locked?
        return :normal if rotational_period.between?(0.5, 2.0)  # Earth-like
        return :moderate
      end
      
      def solar_efficiency_factor
        case temperature_variation
        when :none then 0.5      # Tidally locked - only day side works
        when :normal then 1.0    # Good day/night cycle
        when :moderate then 0.8  # Some temperature stress
        when :extreme then 0.3   # Extreme temperature swings
        end
      end
      
      def geostationary_orbit_possible?
        return false unless parent_body.present? && orbital_period.present?
        
        # Check if moon's orbital period could match parent's rotation
        parent_rotation = parent_body.rotational_period
        return false unless parent_rotation.present?
        
        # Must orbit above parent's surface
        orbital_period > parent_rotation
      end
      
      # ✅ Moon-specific behavior (everything else inherited from Satellite)
      def mining_efficiency_factor
        base_efficiency = 1.0
        tidal_factor = (calculate_tidal_forces / 1e20).clamp(0, 2)  # 0-200% bonus
        base_efficiency + tidal_factor
      end
      
      def subsurface_ocean_likely?
        tidally_locked? && calculate_tidal_forces > 1e15  # High tidal heating
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::Satellites::Moon'
      end
      
      def set_default_rotation
        # Default new moons to tidally locked
        if rotational_period.blank? && orbital_period.present?
          self.rotational_period = orbital_period  # Default to tidally locked
        end
      end
    end
  end
end