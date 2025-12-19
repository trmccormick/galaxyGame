module CelestialBodies
  module Satellites
    class IceMoon < LargeMoon
      # Ice moons typically have lower density
      validates :density, numericality: { less_than: 2.0 }, allow_nil: true
      
      # Set STI type
      before_validation :set_sti_type
      
      # Ice moons often have subsurface oceans
      def initialize(attributes = nil)
        super
        self.hydrosphere ||= build_hydrosphere(
          composition: { 'water' => 95, 'ammonia' => 3, 'salts' => 2 },
          state_distribution: { 'solid' => 95, 'liquid' => 5, 'gas' => 0 }
        )
      end
      
      def has_subsurface_ocean?
        return false unless hydrosphere.present?
        
        # Check for liquid water underneath ice
        has_ice = hydrosphere.ice_coverage.to_f > 50
        has_liquid = hydrosphere.state_distribution&.dig('liquid').to_f > 0
        
        has_ice && has_liquid
      end
      
      def surface_features
        features = super
        
        # Add ice-specific features
        if hydrosphere.present? && hydrosphere.ice_coverage.to_f > 50
          features += ['ice cracks', 'frost plains']
          
          # Check for cryovolcanism
          if calculate_tidal_heating > 30
            features += ['cryovolcanic vents', 'ice geysers']
          end
        end
        
        features.uniq
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::Satellites::IceMoon'
      end
    end
  end
end