# app/models/celestial_bodies/planets/planet.rb
module CelestialBodies
  module Planets
    class Planet < CelestialBodies::CelestialBody
      self.abstract_class = true
      
      # No need to redeclare orbital methods - they're in the concern
      
      # Planet classification methods that aren't in the concern
      def earth_masses
        mass.to_f / 5.972e24
      end
      
      def earth_radii
        radius.to_f / 6.371e6
      end
      
      # Planet classification
      def classification
        self.class.name.demodulize.underscore.humanize
      end
      
      # Calculate day-night cycle - this is a planet-specific concept
      def day_night_cycle
        return nil unless rotational_period.present? && orbital_period.present?
        
        # Calculate solar day length
        (rotational_period * orbital_period) / (orbital_period - rotational_period)
      end
    end
  end
end