# app/models/celestial_bodies/features/canyon.rb
module CelestialBodies
  module Features
    class Canyon < BaseFeature
      include HasNaturalOpenings

      attr_accessor :static_data

      before_validation :set_feature_type, on: :create

      def length_m
        static_data&.dig('dimensions', 'length_m')
      end

      def width_m
        static_data&.dig('dimensions', 'width_m')
      end

      def depth_m
        static_data&.dig('dimensions', 'depth_m')
      end

      def volume_m3
        static_data&.dig('dimensions', 'volume_m3')
      end

      def formation
        static_data&.dig('formation') # e.g., 'tectonic_rifting', 'erosion'
      end

      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end

      def segments
        static_data&.dig('segments') || []
      end

      # Canyons might have sections that can be sealed
      def can_pressurize_section?
        enclosed? && all_openings_sealed?
      end

      private

      def set_feature_type
        self.feature_type = 'canyon'
      end
    end
  end
end