module StarSim
    class AccretionSimulationService
      def initialize(star, dust_disk)
        @star = star
        @dust_disk = dust_disk # Array of DustBand objects
        @protoplanets = []
      end
  
      def run
        100.times do
          break if dust_depleted?
  
          seed = create_seed
          grow_seed(seed)
          clear_band(seed)
          @protoplanets << seed if seed.mass > threshold
        end
  
        finalize_planets
      end
  
      private
  
      def create_seed
        orbit = rand_orbit
        ProtoplanetSeed.new(orbit:)
      end
  
      def grow_seed(seed)
        # Accretion loop based on StarGen logic
        while seed.can_grow?(@dust_disk)
          seed.accrete_dust(@dust_disk)
        end
      end
  
      def clear_band(seed)
        @dust_disk.each do |band|
          band.clear_if_within(seed.orbit, seed.influence_zone)
        end
      end
  
      def finalize_planets
        @protoplanets.map do |seed|
          PlanetBuilder.new(seed, @star).build
        end
      end
  
      def dust_depleted?
        @dust_disk.all?(&:empty?)
      end
    end
end
  