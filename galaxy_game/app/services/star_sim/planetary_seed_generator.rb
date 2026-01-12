module StarSim
    class PlanetarySeedGenerator
      attr_reader :star, :num_planets, :random
  
      # @param star [Star] the star around which planets orbit
      # @param num_planets [Integer] how many planets to generate
      # @param random [Random] optional seeded RNG for reproducibility
      def initialize(star:, num_planets:, random: Random.new)
        @star = star
        @num_planets = num_planets
        @random = random
      end
  
      def generate
        seeds = []
        current_distance = initial_distance
  
        num_planets.times do |i|
          mass = generate_mass
          orbital_distance = current_distance
          orbital_zone = orbital_zone_for(orbital_distance)
          type = classify_planet_type(mass, orbital_zone)
  
          seeds << {
            index: i,
            mass: mass.round(3),
            orbital_distance: orbital_distance.round(3),
            orbital_zone: orbital_zone,
            type: type
          }
  
          current_distance *= spacing_factor
        end
  
        seeds
      end
  
      private
  
      def initial_distance
        # Start at 0.4 AU to simulate inner planet spacing
        0.4 + random.rand * 0.2
      end
  
      def spacing_factor
        # Exponential spacing between planets (Keppler-style)
        1.5 + random.rand * 0.5
      end
  
      def generate_mass
        base = random.rand
        if base < 0.6
          # Terrestrial
          0.1 + random.rand * 1.5
        elsif base < 0.9
          # Ice giant
          2.0 + random.rand * 10.0
        else
          # Gas giant
          50.0 + random.rand * 200.0
        end
      end
  
      def orbital_zone_for(distance)
        hz = star.habitable_zone_range # e.g., 0.95..1.5 AU
        return :inner_zone if distance < hz.begin
        return :habitable_zone if hz.cover?(distance)
        :outer_zone
      end
  
      def classify_planet_type(mass, orbital_zone)
        return :gas_giant if mass > 50
        return :ice_giant if mass > 10
        return :terrestrial if orbital_zone != :outer_zone
        :dwarf_planet
      end
    end
  end
  