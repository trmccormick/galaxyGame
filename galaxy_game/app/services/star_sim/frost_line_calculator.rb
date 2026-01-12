module StarSim
    class FrostLineCalculator
      def initialize(star)
        @luminosity = star.luminosity.to_f
      end
  
      def frost_line
        (4.85 * Math.sqrt(@luminosity)).round(3) # in AU
      end
    end
  end