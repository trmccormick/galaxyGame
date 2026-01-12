module StarSim
    class OrbitalParametersGenerator
      def initialize(star:, index:, randomness: true)
        @star = star
        @index = index
        @randomness = randomness
      end
  
      def generate
        {
          semi_major_axis_au: generate_semi_major_axis,
          eccentricity: generate_eccentricity,
          inclination_deg: generate_inclination,
          orbital_period_days: calculate_orbital_period
        }
      end
  
      private
  
      def generate_semi_major_axis
        base = 0.3 + @index * 0.4
        variation = @randomness ? rand(-0.05..0.1) : 0
        (base + variation).round(3)
      end
  
      def generate_eccentricity
        @randomness ? rand(0.0..0.15).round(3) : 0.01
      end
  
      def generate_inclination
        @randomness ? rand(0.0..3.0).round(2) : 0.0
      end
  
      def calculate_orbital_period
        # Using Kepler’s Third Law approximation: P² ≈ a³
        a = generate_semi_major_axis
        ((a**3)**0.5 * 365.25).round(1) # In Earth days
      end
    end
  end
  