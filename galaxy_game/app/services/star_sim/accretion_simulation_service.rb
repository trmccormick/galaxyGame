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
  
        # Add gravity influence: stability check
        apply_gravity_stability
  
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
          seed.accrete_dust!(@dust_disk, @star.mass)
        end
      end
  
      def clear_band(seed)
        @dust_disk.each do |band|
          band.clear_if_within(seed.orbit, seed.influence_zone(@star.mass))
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
  
      # Define rand_orbit: Random orbit within dust disk, weighted towards denser bands
      def rand_orbit
        # Assume dust_disk has bands with inner/outer radii and density
        total_density = @dust_disk.sum { |band| band.density || 1 }
        rand_val = rand * total_density
        cumulative = 0
        @dust_disk.each do |band|
          cumulative += band.density || 1
          if rand_val <= cumulative
            # Random orbit within this band
            return rand(band.inner_edge..band.outer_edge)
          end
        end
        # Fallback
        1.0
      end
  
      # Define threshold: Minimum mass for a planet (e.g., 0.1 Earth masses)
      def threshold
        0.1  # Earth masses
      end
  
      # Apply gravity stability: Remove bodies with overlapping Hill spheres
      def apply_gravity_stability
        @protoplanets.sort_by!(&:orbit)  # Sort by distance
        stable = []
        @protoplanets.each do |planet|
          conflicting = stable.any? do |existing|
            hill_distance = [planet.orbit, existing.orbit].min * (planet.mass / (3 * @star.mass))**(1/3.0)
            (planet.orbit - existing.orbit).abs < hill_distance
          end
          stable << planet unless conflicting
        end
        @protoplanets = stable
      end
    end
end
  