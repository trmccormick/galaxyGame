module Generators
  class ProceduralSystemGeneratorService
    def initialize(name: nil, galaxy: nil)
      @name_generator = NameGeneratorService.new
      @galaxy = galaxy || Galaxy.first || Galaxy.create!(name: 'Default')
      @name = name || @name_generator.generate_star_system_name
    end
  
    def generate
      generated_data = generate_system_data
      SystemBuilderService.new(system_data: generated_data, galaxy: @galaxy).build!
    end
  
    private
  
    def generate_system_data
      # This structure mimics the shape of SOL_SYSTEM_DATA
      {
        name: @name,
        stars: [
          {
            name: "Zerion",
            mass: 1.2e30,
            radius: 6.96e8,
            luminosity: 3.846e26,
            temperature: 6100
          }
        ],
        celestial_bodies: {
          planet: [
            {
              name: "New Terra",
              model_class: CelestialBodies::Planet,
              radius: 6_500_000,
              mass: 6e24,
              surface_temperature: 290,
              density: 5500,
              albedo: 0.3,
              orbital_period: 365,
              insolation: 1.05,
              atmosphere: {
                composition: { "N2" => { percentage: 78.0 }, "O2" => { percentage: 21.0 } },
                pressure: 101_325,
                total_atmospheric_mass: 5.1e18,
                dust: 0.01
              },
              star_distances: [
                { star_name: "Zerion", distance: 1.5e11 }
              ]
            }
          ]
        }
      }
    end
  end
end
  