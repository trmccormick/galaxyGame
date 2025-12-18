# app/models/celestial_bodies/features/skylight.rb
module CelestialBodies
  module Features
    class Skylight < BaseFeature
      # Can belong to any feature with openings (lava tubes, caves, canyons, etc.)
      belongs_to :parent_feature, class_name: 'CelestialBodies::Features::BaseFeature',
                 foreign_key: :parent_feature_id, optional: true
      
      before_validation :set_feature_type, on: :create
      
      def diameter_m
        static_data&.dig('diameter_m') || parent_opening_data&.dig('diameter_m')
      end
      
      def depth_m
        static_data&.dig('depth_m') || parent_opening_data&.dig('depth_m')
      end
      
      def area_m2
        return nil unless diameter_m
        Math::PI * (diameter_m / 2.0) ** 2
      end
      
      def location
        static_data&.dig('location') || parent_opening_data&.dig('location')
      end
      
      # Alias for parent lava tube (for specs and API compatibility)
      def parent_lava_tube
        parent_feature
      end
      # Get parent feature (could be lava tube, cave, canyon, etc.)
      def parent_structure
        parent_feature
      end
      
      # Check if sealed/covered
      def covered?
        enclosed? || pressurized?
      end
      
      private
      
      def set_feature_type
        self.feature_type = 'skylight'
      end
      
      # Try to get data from parent feature's natural_openings
      def parent_opening_data
        return nil unless parent_feature
        return nil unless parent_feature.respond_to?(:natural_openings)
        
        parent_feature.natural_openings.find do |opening|
          opening['opening_type'] == 'skylight'
        end
      end
    end
  end
end