module StarSim
    class StarGenerator
      def initialize(system_name:, name_generator: NameGeneratorService.new)
        @system_name = system_name
        @name_generator = name_generator
      end
  
      def generate
        # Basic star generation — this can be expanded to support different spectral types, mass, etc.
        [{
          name: "#{@system_name} A",
          spectral_type: "G", # Defaulting to sun-like; could randomize
          mass: 1.0,          # In solar masses
          radius: 1.0,        # In solar radii
          temperature: 5778,  # Kelvin, approximate for G-type
          luminosity: 1.0,    # In solar units
          age: rand(3..7),    # In billions of years
          metallicity: 0.012, # Solar default
          identifier: @name_generator.generate_identifier
        }]
      end
    end
  end