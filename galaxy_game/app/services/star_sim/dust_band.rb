module StarSim
    class DustBand
      attr_accessor :inner_edge, :outer_edge, :density
  
      def initialize(inner_edge:, outer_edge:, density:)
        @inner_edge = inner_edge # AU
        @outer_edge = outer_edge # AU
        @density = density       # g/cm² or normalized units
      end
  
      def overlaps_with?(orbit, influence)
        # Returns true if the protoplanet’s zone overlaps with this band
        influence_min = orbit - influence
        influence_max = orbit + influence
        influence_max > @inner_edge && influence_min < @outer_edge
      end
  
      def accrete_mass!(orbit, influence, efficiency = 1.0)
        return 0 unless overlaps_with?(orbit, influence)
  
        overlap_width = [@outer_edge, orbit + influence].min - [@inner_edge, orbit - influence].max
        accreted_mass = overlap_width * @density * efficiency
        @density = [@density - (accreted_mass / overlap_width), 0].max
        accreted_mass
      end
  
      def empty?
        @density <= 0
      end
    end
end
  