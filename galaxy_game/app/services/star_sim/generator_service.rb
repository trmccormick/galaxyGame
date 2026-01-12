module StarSim
    class GeneratorService
      def initialize(star)
        @star = star
      end
  
      def generate
        dust_bands = DustBandGenerator.new(@star).generate
        seeds = []
  
        5.times do
          orbit = rand(0.3..10.0).round(2) # AU range
          seed = ProtoplanetSeed.new(orbit: orbit)
          seeds << seed
        end
  
        simulator = AccretionSimulator.new(seeds, dust_bands)
        simulator.run!
  
        planets = seeds.map do |seed|
          PlanetBuilder.new(seed, @star).build
        end
  
        planets
      end
    end
  end
  