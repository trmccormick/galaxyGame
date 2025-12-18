# app/models/celestial_bodies/features/lava_tube.rb
module CelestialBodies
  module Features
    class LavaTube < BaseFeature
      include HasNaturalOpenings
      
      # Set feature_type automatically
      before_validation :set_feature_type, on: :create
      
      # Dimension accessors
      def length_m
        static_data&.dig('dimensions', 'length_m')
      end
      
      def width_m
        static_data&.dig('dimensions', 'width_m')
      end
      
      def height_m
        static_data&.dig('dimensions', 'height_m')
      end
      
      def estimated_volume_m3
        static_data&.dig('dimensions', 'estimated_volume_m3')
      end
      
      # Attributes
      def natural_shielding
        static_data&.dig('attributes', 'natural_shielding')
      end
      
      def thermal_stability
        static_data&.dig('attributes', 'thermal_stability')
      end
      
      # Conversion suitability
      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end
      
      def suitability_rating
        conversion_suitability['habitat']
      end
      
      def estimated_cost_multiplier
        conversion_suitability['estimated_cost_multiplier'] || 1.0
      end
      
      def advantages
        conversion_suitability['advantages'] || []
      end
      
      def challenges
        conversion_suitability['challenges'] || []
      end
      
      # Priority and strategic value
      def priority
        static_data&.dig('priority')
      end
      
      def strategic_value
        static_data&.dig('strategic_value') || []
      end
      
      # Can we pressurize?
      def can_pressurize?
        enclosed? && all_openings_sealed?
      end
      
      private
      
      def set_feature_type
        self.feature_type = 'lava_tube'
      end
    end
  end
end