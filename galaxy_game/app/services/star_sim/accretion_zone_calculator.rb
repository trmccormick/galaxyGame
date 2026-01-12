module StarSim
    class AccretionZoneCalculator
      # Constants used in the original StarGen algorithm
      INNER_DUST_LIMIT_COEFF = 0.3
      OUTER_DUST_LIMIT_COEFF = 50.0
  
      def initialize(star)
        @star = star
      end
  
      def calculate
        {
          inner_dust_limit: inner_dust_limit,
          outer_dust_limit: outer_dust_limit,
          habitable_zone: habitable_zone_range
        }
      end
  
      private
  
      def inner_dust_limit
        INNER_DUST_LIMIT_COEFF * Math.sqrt(@star.mass.to_f)
      end
  
      def outer_dust_limit
        OUTER_DUST_LIMIT_COEFF * Math.sqrt(@star.mass.to_f)
      end
  
      def habitable_zone_range
        # Simplified using luminosity; more advanced models may use atmosphere, greenhouse effect, etc.
        # From Kasting et al. (1993), rough estimate:
        inner = Math.sqrt(@star.luminosity.to_f / 1.1) # in AU
        outer = Math.sqrt(@star.luminosity.to_f / 0.53)
        (inner..outer)
      end
    end
  end
  