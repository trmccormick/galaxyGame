# app/models/concerns/celestial_bodies/features/has_natural_openings.rb
module CelestialBodies
  module Features
    module HasNaturalOpenings
      extend ActiveSupport::Concern
      
      included do
        has_many :skylights, -> { where(type: 'CelestialBodies::Features::Skylight') }, 
                 class_name: 'CelestialBodies::Features::Skylight',
                 foreign_key: :parent_feature_id,
                 dependent: :destroy
        
        has_many :access_points, -> { where(type: 'CelestialBodies::Features::AccessPoint') },
                 class_name: 'CelestialBodies::Features::AccessPoint',
                 foreign_key: :parent_feature_id,
                 dependent: :destroy
      end
      
      # Natural openings from static data
      def natural_openings
        static_data&.dig('natural_openings') || []
      end
      
      # All openings (skylights + access points)
      def all_openings
        skylights.to_a + access_points.to_a
      end
      
      # Check if all openings are sealed
      def all_openings_sealed?
        return false if all_openings.empty?
        all_openings.all? { |opening| opening.enclosed? || opening.pressurized? }
      end
      
      # Count of each opening type
      def skylight_count
        skylights.count
      end
      
      def access_point_count
        access_points.count
      end
      
      def opening_count
        skylight_count + access_point_count
      end
      
      # Total opening area
      def total_opening_area_m2
        all_openings.sum { |opening| opening.area_m2 || 0 }
      end
      
      # Create child opening features from static data
      def create_openings_from_static_data!
        natural_openings.each_with_index do |opening_data, index|
          opening_type = opening_data['opening_type']
          
          if opening_type == 'skylight'
            Skylight.create!(
              celestial_body: celestial_body,
              parent_feature: self,
              feature_id: "#{feature_id}_skylight_#{index + 1}",
              status: 'natural'
            )
          elsif opening_type.in?(['cave_entrance', 'collapsed_section', 'access_point', 'entrance'])
            AccessPoint.create!(
              celestial_body: celestial_body,
              parent_feature: self,
              feature_id: "#{feature_id}_access_#{index + 1}",
              status: 'natural'
            )
          end
        end
      end
      
      # Seal all openings
      def seal_all_openings!
        all_openings.each(&:enclose!)
      end
    end
  end
end