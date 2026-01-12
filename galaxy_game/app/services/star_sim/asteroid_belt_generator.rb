module StarSim
    class AsteroidBeltGenerator
      def initialize(star:, existing_bodies:)
        @star = star
        @existing_bodies = existing_bodies
      end
  
      def generate
        # Find a gap between planetary orbits where an asteroid belt could fit
        sorted_orbits = @existing_bodies.map(&:semi_major_axis).compact.sort
  
        belt_zones = find_viable_belt_zones(sorted_orbits)
        return [] if belt_zones.empty?
  
        belt_zones.map.with_index do |(inner, outer), index|
          create_asteroid_belt(inner, outer, index)
        end
      end
  
      private
  
      def find_viable_belt_zones(orbits)
        return [[0.4, 4.0]] if orbits.empty?
  
        zones = []
        previous_orbit = 0.3 # Minimum distance from star where belts might be stable
  
        orbits.each do |orbit|
          midpoint = (previous_orbit + orbit) / 2.0
          width = orbit - previous_orbit
          zones << [previous_orbit + 0.1 * width, orbit - 0.1 * width] if width > 0.2
          previous_orbit = orbit
        end
  
        # Final zone beyond last planet
        zones << [previous_orbit + 0.5, previous_orbit + 2.0] if previous_orbit < 20
  
        zones
      end
  
      def create_asteroid_belt(inner_edge, outer_edge, index)
        {
          name: "Asteroid Belt #{index + 1}",
          type: :asteroid_belt,
          inner_edge: inner_edge.round(2),
          outer_edge: outer_edge.round(2),
          estimated_mass: rand(0.01..0.2).round(3) # In Earth masses
        }
      end
    end
  end
  