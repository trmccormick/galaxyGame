# app/models/celestial_bodies/features/cave.rb
module CelestialBodies
  module Features
    class Cave < BaseFeature
      include HasNaturalOpenings
      
      before_validation :set_feature_type, on: :create
      
      def depth_m
        static_data&.dig('dimensions', 'depth_m')
      end
      
      def network_size_m
        static_data&.dig('dimensions', 'network_size_m')
      end
      
      def volume_m3
        static_data&.dig('dimensions', 'volume_m3')
      end
      
      def cave_type
        static_data&.dig('cave_type') # e.g., 'limestone', 'lava', 'ice'
      end
      
      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end
      
      def can_pressurize?
        enclosed? && all_openings_sealed?
      end
      
      private
      
      def set_feature_type
        self.feature_type = 'cave'
      end
    end
  end
end