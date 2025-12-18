# app/models/celestial_bodies/features/valley.rb
module CelestialBodies
  module Features
    class Valley < BaseFeature
      include HasNaturalOpenings
      
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
        static_data&.dig('formation')
      end
      
      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end
      
      # Override to use predefined segments from static data
      def calculate_construction_segments
        segments_data = static_data&.dig('segments') || []
        return super if segments_data.empty?
        
        segments_data.map do |segment|
          {
            name: segment['name'],
            length_m: segment['length_m'],
            width_m: segment['width_m'] || width_m
          }
        end
      end

      private
      
      def set_feature_type
        self.feature_type = 'valley'
      end
    end
  end
end