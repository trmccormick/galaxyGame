# app/models/celestial_bodies/satellites/satellite.rb
module CelestialBodies
  module Satellites
    class Satellite < CelestialBody
      include OrbitalMechanics  # ✅ Include the enhanced concern
      
      # Re-introducing the belongs_to association for the parent celestial body.
      # This links a satellite to its parent (e.g., a planet or another moon).
      belongs_to :parent_celestial_body, class_name: 'CelestialBodies::CelestialBody', 
                 foreign_key: 'parent_celestial_body_id', optional: true
      
      # Common validations for all satellites
      validates :orbital_period, numericality: { greater_than: 0 }, allow_nil: true
      validates :rotational_period, numericality: { greater_than: 0 }, allow_nil: true
      # ❌ REMOVE this validation - conflicts with optional: true
      # validates :parent_celestial_body, presence: true
      
      # ✅ Rotational mechanics for all satellites
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
      
      # ✅ Orbital relationship compatibility
      alias_method :parent_body, :parent_celestial_body
      alias_method :parent_body=, :parent_celestial_body=
      
      def orbits_planet?
        parent_celestial_body.present? && 
        (parent_celestial_body.type.include?('::Planets::') || parent_celestial_body.type.include?('::DwarfPlanet'))
      end
      
      def calculate_tidal_forces
        return 0 unless parent_celestial_body.present? && mass.present? && radius.present?
        
        # Use orbital relationship if available, otherwise fallback
        if orbital_relationship
          orbital_relationship.tidal_heating
        else
          # Fallback calculation
          parent_mass = parent_celestial_body.mass.to_f
          orbital_period_seconds = orbital_period.to_f * 24 * 3600
          return 0 if orbital_period_seconds <= 0
          parent_mass / (orbital_period_seconds ** 2)
        end
      end
      
      def geostationary_orbit_possible?
        return false unless parent_body.present? && orbital_period.present?
        
        parent_rotation = parent_body.rotational_period
        return false unless parent_rotation.present?
        
        orbital_period > parent_rotation
      end
      
      def communication_delay_to_parent
        return 0 unless orbital_distance
        orbital_distance / 299_792_458  # Speed of light delay in seconds
      end
      
      # ✅ Enhanced orbital relationship integration
      def create_orbital_relationship_with(body)
        OrbitalRelationship.create!(
          primary_body: body,
          secondary_body: self,
          relationship_type: 'planet_moon',  # Most satellites orbit planets
          distance: spatial_location&.distance_to(body.spatial_location),
          semi_major_axis: spatial_location&.distance_to(body.spatial_location),
          orbital_period: orbital_period,
          rotational_period: rotational_period
        )
      end
    end
  end
end