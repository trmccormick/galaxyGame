module CelestialBodies
  module Satellites
    class LargeMoon < Moon
      include SolidBodyConcern
      
      validates :radius, numericality: { greater_than: 1.0e6 }, allow_nil: true
      before_validation :set_sti_type
      
      # ✅ Now has access to all rotational mechanics from Satellite
      def has_significant_atmosphere?
        atmosphere.present? && atmosphere.pressure.to_f > 0.01
      end
      
      def geological_classification
        activity = calculate_geological_activity
        return :active if activity > 70
        return :moderately_active if activity > 30
        :inactive
      end
      
      # ✅ Enhanced tidal heating using inherited methods
      def calculate_tidal_heating
        base_tidal = calculate_tidal_forces  # From Satellite
        
        # Large moons have more complex tidal interactions
        eccentricity_factor = orbital_relationship&.eccentricity || 0
        size_factor = (radius / 1.737e6) ** 0.5  # Scale by size relative to Moon
        
        heating = base_tidal * (1 + 10 * eccentricity_factor**2) * size_factor
        [heating * 1.0e19, 100.0].min
      end
      
      # ✅ Can use rotational mechanics for geological processes
      def volcanic_activity_level
        tidal_heating = calculate_tidal_heating
        rotation_factor = tidally_locked? ? 1.5 : 1.0  # Tidal locking increases heating
        
        case (tidal_heating * rotation_factor)
        when 0..20 then :none
        when 20..50 then :low
        when 50..80 then :moderate
        else :high
        end
      end
      
      # ✅ Atmospheric retention affected by rotation
      def atmosphere_retention_factor
        base_retention = mass / radius  # Gravity factor
        
        # Rotation affects atmospheric circulation
        rotation_factor = case temperature_variation  # From Satellite
                         when :none then 0.7      # Poor circulation on tidally locked
                         when :normal then 1.0    # Good circulation
                         when :moderate then 0.9  # Moderate circulation
                         when :extreme then 0.6   # Extreme temperature losses
                         end
        
        base_retention * rotation_factor
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::Satellites::LargeMoon'
      end
    end
  end
end