# app/models/celestial_bodies/features/access_point.rb
module CelestialBodies
  module Features
    class AccessPoint < BaseFeature
      # Can belong to any feature with openings (lava tubes, caves, canyons, etc.)
      belongs_to :parent_feature, class_name: 'CelestialBodies::Features::BaseFeature',
                 foreign_key: :parent_feature_id, optional: true
      
      before_validation :set_feature_type, on: :create
      
      def opening_type
        static_data&.dig('opening_type') || parent_opening_data&.dig('opening_type')
      end
      
      def diameter_m
        static_data&.dig('diameter_m') || parent_opening_data&.dig('diameter_m')
      end
      
      def length_m
        static_data&.dig('length_m') || parent_opening_data&.dig('length_m')
      end
      
      def width_m
        static_data&.dig('width_m') || parent_opening_data&.dig('width_m')
      end
      
      def depth_m
        static_data&.dig('depth_m') || parent_opening_data&.dig('depth_m')
      end
      
      def area_m2
        if length_m && width_m
          length_m * width_m
        elsif diameter_m
          Math::PI * (diameter_m / 2.0) ** 2
        end
      end
      
      def location
        static_data&.dig('location') || parent_opening_data&.dig('location')
      end
      
      # Get parent feature (could be lava tube, cave, canyon, etc.)
      def parent_structure
        parent_feature
      end
      
      # Check if sealed
      def sealed?
        enclosed? || pressurized?
      end
      
      private
      
      def set_feature_type
        self.feature_type = 'access_point'
      end
      
      # Try to get data from parent feature's natural_openings
      def parent_opening_data
        return nil unless parent_feature
        return nil unless parent_feature.respond_to?(:natural_openings)
        
        parent_feature.natural_openings.find do |opening|
          opening['opening_type'] != 'skylight'
        end
      end
    end
  end
end