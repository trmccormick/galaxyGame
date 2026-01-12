module StarSim
    class ProtoplanetSeed
      attr_accessor :orbit, :mass, :gas_mass
  
      def initialize(orbit:)
        @orbit = orbit         # AU
        @mass = 0.01           # Starting mass in Earth masses
        @gas_mass = 0.0
      end
  
      def influence_zone(star_mass)
        # Rough Hill sphere approximation
        @orbit * (@mass / (3.0 * star_mass)) ** (1.0 / 3.0)
      end
  
      def accrete_dust!(dust_bands, star_mass)
        influence = influence_zone(star_mass)
        gained_mass = 0
  
        dust_bands.each do |band|
          gained_mass += band.accrete_mass!(@orbit, influence)
        end
  
        @mass += gained_mass
      end
  
      def reaches_gas_accretion_threshold?
        @mass >= 1.0 # Earth masses — adjust threshold as needed
      end
  
      def accrete_gas!(available_gas = 1.0)
        return 0 unless reaches_gas_accretion_threshold?
  
        gas_gain = available_gas * (@mass / 10.0)
        @gas_mass += gas_gain
      end
  
      def total_mass
        @mass + @gas_mass
      end
  
      def can_grow?(dust_bands)
        dust_bands.any? { |band| band.overlaps_with?(@orbit, influence_zone(1.0)) && !band.empty? }
      end
    end
end
  
