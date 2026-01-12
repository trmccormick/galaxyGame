module StarSim
    class HabitableZoneCalculator
      def initialize(star)
        @luminosity = star.luminosity.to_f # In solar units
      end
  
      def inner_boundary
        (0.95 * Math.sqrt(@luminosity)).round(3)
      end
  
      def outer_boundary
        (1.37 * Math.sqrt(@luminosity)).round(3)
      end
  
      def range
        inner = inner_boundary
        outer = outer_boundary
        (inner..outer)
      end
    end
  end
  