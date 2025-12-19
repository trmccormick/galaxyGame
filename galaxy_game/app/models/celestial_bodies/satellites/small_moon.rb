module CelestialBodies
  module Satellites
    class SmallMoon < Moon
      # Similar to asteroids in many ways, but orbits a planet
      validates :radius, numericality: { less_than: 2.0e5 }, allow_nil: true # Less than 200km
      
      # Set STI type
      before_validation :set_sti_type
      
      # Potential relationship to asteroids - you could add an association here
      belongs_to :origin_body, class_name: 'CelestialBodies::CelestialBody', 
                foreign_key: 'origin_body_id', optional: true
      
      def likely_origin
        if origin_body.present? && origin_body.type.include?('::MinorBodies::Asteroid')
          :captured_asteroid
        elsif is_irregular_shape?
          :probable_asteroid
        else
          :accretion
        end
      end
      
      def is_irregular_shape?
        # Small moons under ~250km radius are usually not rounded by gravity
        radius.present? && radius < 2.5e5
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::Satellites::SmallMoon'
      end
    end
  end
end