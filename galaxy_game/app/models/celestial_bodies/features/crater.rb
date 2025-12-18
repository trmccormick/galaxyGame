# app/models/celestial_bodies/features/crater.rb
module CelestialBodies
  module Features
    class Crater < BaseFeature
      before_validation :set_feature_type, on: :create
      
      def diameter_m
        static_data&.dig('dimensions', 'diameter_m')
      end
      
      def depth_m
        static_data&.dig('dimensions', 'depth_m')
      end
      
      def rim_height_m
        static_data&.dig('dimensions', 'rim_height_m')
      end
      
      def floor_area_m2
        static_data&.dig('dimensions', 'floor_area_m2')
      end
      
      def crater_type
        static_data&.dig('crater_type')
      end
      
      def composition
        static_data&.dig('composition') || {}
      end
      
      def has_ice?
        composition['ice_present'] == true
      end
      
      def ice_concentration
        composition['ice_concentration']
      end
      
      def attributes_data
        static_data&.dig('attributes') || {}
      end
      
      def permanently_shadowed?
        attributes_data['permanently_shadowed'] == true
      end
      
      def solar_exposure_percent
        attributes_data['solar_exposure_percent']
      end
      
      def temperature_floor_k
        attributes_data['temperature_floor_k']
      end
      
      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end
      
      def dome_suitability
        conversion_suitability['crater_dome']
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
      
      def resources
        static_data&.dig('resources') || {}
      end
      
      def water_ice_tons
        resources['water_ice_tons']
      end
      
      def accessible_ice_tons
        resources['accessible_ice_tons']
      end
      
      def minerals
        resources['minerals'] || []
      end
      
      def priority
        static_data&.dig('priority')
      end
      
      def strategic_value
        static_data&.dig('strategic_value') || []
      end
      
      # Size categorization
      def size_category
        return 'unknown' unless diameter_m
        
        diameter_km = diameter_m / 1000.0
        case diameter_km
        when 0..10 then 'small'
        when 10..50 then 'medium'
        when 50..100 then 'large'
        else 'very_large'
        end
      end
      
      private
      
      def set_feature_type
        self.feature_type = 'crater'
      end
    end
  end
end