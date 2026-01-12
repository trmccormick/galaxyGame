# app/services/brown_dwarf_system_generator.rb
module StarSim
  class BrownDwarfSystemGenerator
    def initialize(solar_system)
      @solar_system = solar_system
      @name_generator = NameGeneratorService.new
      @planet_counter = 0
    end
  
    def generate_system(num_planets: 5, num_sub_brown_dwarfs: 1)
      # Create primary brown dwarf system
      create_brown_dwarf
      # Create secondary brown dwarfs (if needed)
      num_sub_brown_dwarfs.times { create_brown_dwarf }
      # Generate planets and other celestial bodies
      create_celestial_bodies(num_planets, num_sub_brown_dwarfs)
    end
  
    private
  
    def create_brown_dwarf
      spectral_types = ['L', 'T', 'Y']
  
      @brown_dwarf = @solar_system.stars.create!(
        identifier: "#{@solar_system.identifier} BD-#{rand(100..9999)}",
        name: @name_generator.generate_star_name,
        luminosity: rand(0.0001..0.01),
        mass: rand(0.01..0.08) * 1.989e30,
        life: 'Substellar',
        age: rand(1..10) * 1e9,
        r_ecosphere: rand(0.05..0.2),
        type_of_star: spectral_types.sample,
        radius: rand(0.7..1.2) * 6.963e7,
        temperature: rand(300..2500)
      )
  
      puts "Created brown dwarf: #{@brown_dwarf.name}"
    end
  
    def create_celestial_bodies(num_planets, num_sub_brown_dwarfs)
      (num_planets + num_sub_brown_dwarfs).times do
        model_class = determine_celestial_body_class
        attributes = generate_celestial_body_attributes(model_class)
  
        # Adjust attributes based on multiple stars and complex orbital mechanics
        model_class.create!(attributes.merge(solar_system: @solar_system))
      end
    end
  
    def determine_celestial_body_class
      weighted_classes = {
        CelestialBodies::GasGiant => 25,
        CelestialBodies::IceGiant => 20,
        CelestialBodies::DwarfPlanet => 15,
        CelestialBodies::Moon => 10,
        CelestialBodies::CelestialBody => 30, # Basic terrestrial planets
        CelestialBodies::SubBrownDwarf => 5 # Rare occurrence
      }
  
      weighted_classes.max_by { |_, weight| rand * weight }.first
    end
  
    def generate_celestial_body_attributes(model_class)
      @planet_counter += 1
      attributes = {
        identifier: generate_planet_identifier(@solar_system.identifier, @planet_counter),
        name: @name_generator.generate_planet_name,
        mass: rand(0.1..5.0) * 5.972e24,
        radius: rand(0.3..2.0) * 6.371e6,
        density: rand(2.0..6.0),
        orbital_period: rand(50..800),
        surface_temperature: rand(50..300),
        albedo: rand(0.1..0.6),
        gravity: rand(0.5..2.0) * 9.81,
        insolation: rand(10..500),
        known_pressure: rand(0.001..5.0)
      }
  
      if model_class == CelestialBodies::GasGiant
        attributes.merge!(
          hydrogen_concentration: rand(80..95),
          helium_concentration: rand(5..20)
        )
      elsif model_class == CelestialBodies::SubBrownDwarf
        attributes.merge!(
          mass: rand(5..15) * 1.898e27, # Between 5-15 Jupiter masses
          radius: rand(0.9..1.5) * 6.9911e7, # Larger than Jupiter
          temperature: rand(500..2000) # Hotter than gas giants but cooler than stars
        )
      end
  
      attributes
    end
  end
end
  
  