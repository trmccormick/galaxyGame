module StarSim
  class SystemGeneratorService
    def initialize(solar_system)
      @solar_system = solar_system
    end

    # Main public method to generate a system
    def generate!(num_stars:, num_planets:)
      if Lookup::StarSystemLookupService.new.system_exists?(@solar_system.identifier)
        # System has predefined data in a JSON file
        generate_from_predefined_data
      else
        # No predefined data, generate procedurally
        generate_random_system(num_stars: num_stars, num_planets: num_planets)
      end
    end

    private

    def generate_from_predefined_data
      if @solar_system.identifier == 'AC-01' # Alpha Centauri
        # Use hybrid seeding for Alpha Centauri
        seed_path = Lookup::StarSystemLookupService::SYSTEMS_PATH.join('alpha_centauri.json')
        generator = StarSim::ProceduralGenerator.new
        system_seed = generator.generate_hybrid_system_from_seed(seed_path)
        
        # Save the hybrid seed data
        filepath = Lookup::StarSystemLookupService::SYSTEMS_PATH.join('alpha_centauri_hybrid.json')
        File.open(filepath, 'w') do |f|
          f.write(JSON.pretty_generate(system_seed))
        end
        
        # Use SystemBuilderService with the hybrid data
        builder = StarSim::SystemBuilderService.new(name: 'alpha_centauri_hybrid')
        builder.build!
      else
        # The SystemBuilderService expects a name parameter, not system_data
        # So we pass the solar system identifier as the name
        builder = StarSim::SystemBuilderService.new(name: @solar_system.identifier)
        builder.build!
      end
      
      @solar_system
    end

    def generate_random_system(num_stars:, num_planets:)
      # Create a procedural generator
      generator = StarSim::ProceduralGenerator.new
      
      # Generate the system seed data
      system_seed = generator.generate_system_seed(
        num_stars: num_stars,
        num_planets: num_planets
      )
      
      # Skip file operations in test environment
      unless Rails.env.test?
        # Save the seed data as a JSON file
        timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
        generated_identifier = system_seed["solar_system"]["identifier"] || "unnamed-system"
        filename = "generated_#{generated_identifier}_#{timestamp}.json"
        filepath = File.join(Lookup::StarSystemLookupService::SYSTEMS_PATH, filename)
        
        FileUtils.mkdir_p(Lookup::StarSystemLookupService::SYSTEMS_PATH) unless File.directory?(Lookup::StarSystemLookupService::SYSTEMS_PATH)
        
        File.open(filepath, 'w') do |f|
          f.write(JSON.pretty_generate(system_seed))
        end
      end
      
      # Update the solar system name and identifier - bypass validations
      @solar_system.name = system_seed["solar_system"]["name"] || "Unnamed System"
      @solar_system.identifier = system_seed["solar_system"]["identifier"] || "UNNAMED-#{SecureRandom.hex(4)}"
      @solar_system.save(validate: false)
      
      # For procedurally generated systems, we can't use SystemBuilderService directly
      # since it expects to lookup data by name. Instead, we'll use our fallback method.
      puts "DEBUG: About to call fallback_build" if Rails.env.test?
      fallback_build(system_seed, num_stars, num_planets)
      
      @solar_system
    end
    
    # Fallback method - creates stars and planets directly
    def fallback_build(system_seed, num_stars, num_planets)
      Rails.logger.info("Building system using direct creation method")
      
      # Create stars based on the seed data
      star_data = system_seed["stars"]&.first || {}
      
      num_stars.times do |i|
        # Generate a unique identifier for each star
        star_identifier = "STAR-#{i}-#{SecureRandom.hex(4)}"
        
        @solar_system.stars.create!(
          name: star_data["name"] || "Star #{i}",
          identifier: star_identifier,
          type_of_star: star_data["type"] || "G2V",
          mass: star_data["mass"] || 1.0,
          radius: star_data["radius"] || 6.96e8,
          luminosity: star_data["luminosity"] || 1.0,
          temperature: star_data["temperature"] || 5778,
          life: "main_sequence",
          age: rand(1e9..10e9),
          r_ecosphere: calculate_habitable_zone(star_data["luminosity"] || 1.0)[0],
          properties: { "spectral_class" => star_data["type"] || "G2V", "stellar_class" => "Main Sequence" }
        )
      end
      
      # Create planets based on the seed data - using new class hierarchy
      planet_data = system_seed.dig("celestial_bodies", "terrestrial_planets")&.first || {}
      
      num_planets.times do |i|
        # Generate a unique identifier for each planet
        planet_identifier = "PLANET-#{i}-#{SecureRandom.hex(4)}"
        
        # Randomly select a planet type from the new hierarchy
        planet_types = [
          CelestialBodies::Planets::Rocky::TerrestrialPlanet,
          CelestialBodies::Planets::Rocky::SuperEarth,
          CelestialBodies::Planets::Gaseous::GasGiant,
          CelestialBodies::Planets::Gaseous::IceGiant,
          CelestialBodies::Planets::Ocean::OceanPlanet
        ]
        
        planet_class = planet_types.sample
        
        # Create planet with class-specific defaults
        planet_attributes = {
          name: planet_data["name"] || "Planet #{i}",
          identifier: planet_identifier,
          solar_system: @solar_system,
          mass: planet_data["mass"] && planet_data["mass"] >= minimum_mass_for_type(planet_class) ? planet_data["mass"] : random_mass_for_type(planet_class),
          radius: planet_data["radius"] && planet_data["radius"] >= minimum_radius_for_type(planet_class) ? planet_data["radius"] : random_radius_for_type(planet_class),
          size: planet_data["size"] || rand(0.2..2.5),
          gravity: planet_data["gravity"] && planet_data["gravity"] >= minimum_gravity_for_type(planet_class) ? planet_data["gravity"] : random_gravity_for_type(planet_class),
          orbital_period: planet_data.dig("orbits", 0, "orbital_period_days") || rand(30..3000),
          surface_temperature: planet_data["surface_temperature"] || rand(50..500),
          density: planet_data["density"] || random_density_for_type(planet_class),
          albedo: planet_data["albedo"] || rand(0.1..0.9),
          status: "active"
        }
        
        if planet_class.name.include?('OceanPlanet')
          # For ocean planets, create hydrosphere first
          surface_area = 4 * Math::PI * (planet_attributes[:radius] ** 2)
          total_water_area = surface_area * 0.35 # 35% water coverage
          
          hydrosphere = CelestialBodies::Spheres::Hydrosphere.new(
            liquid_bodies: {
              'oceans' => total_water_area * 0.9,
              'lakes' => total_water_area * 0.05,
              'rivers' => total_water_area * 0.05
            },
            composition: { 'water' => 96, 'salts' => 4 },
            temperature: planet_attributes[:surface_temperature]
          )
          
          planet = planet_class.new(planet_attributes)
          planet.hydrosphere = hydrosphere
          planet.save!
        else
          planet = planet_class.create!(planet_attributes)
        end
        
        # Add moons to some planets (except for terrestrial planets close to star)
        if rand > 0.3 && planet.orbital_period.to_f > 100
          num_moons = rand(0..5)
          
          num_moons.times do |j|
            moon_class = [
              CelestialBodies::Satellites::SmallMoon,
              CelestialBodies::Satellites::LargeMoon
            ].sample
            
            moon = moon_class.create!(
              name: "Moon #{j} of #{planet.name}",
              identifier: "MOON-#{i}-#{j}-#{SecureRandom.hex(4)}",
              solar_system: @solar_system,
              parent_celestial_body_id: planet.id,
              mass: random_mass_for_type(moon_class),
              radius: moon_class.name.include?('SmallMoon') ? rand(10e3..199e3) : random_radius_for_type(moon_class),
              size: rand(0.1..1.0),
              orbital_period: rand(0.5..60.0),
              surface_temperature: planet.surface_temperature.to_f * rand(0.6..0.9),
              density: random_density_for_type(moon_class),
              status: "active"
            )
          end
        end
      end
    end
    
    # Helper methods for generating appropriate values for different planet types
    def random_mass_for_type(planet_class)
      case planet_class.name
      when /TerrestrialPlanet/
        rand(0.1..2.0) * 5.97e24  # 0.1 to 2 Earth masses
      when /SuperEarth/
        rand(2.1..9.9) * 5.97e24  # 2.1 to 9.9 Earth masses (ensure < 10e24)
      when /GasGiant/
        rand(100..1000) * 5.97e24 # 100 to 1000 Earth masses
      when /IceGiant/
        rand(10..50) * 5.97e24    # 10 to 50 Earth masses
      when /OceanPlanet/
        rand(1.0..5.0) * 5.97e24  # 1 to 5 Earth masses
      when /LargeMoon/
        rand(0.01..0.3) * 5.97e24 # Large moon masses
      when /SmallMoon/
        rand(1e18..1e22)          # Small moon masses
      else
        5.97e24                   # Default to Earth mass
      end
    end
    
    def minimum_mass_for_type(planet_class)
      case planet_class.name
      when /SuperEarth/
        2e24  # SuperEarth validation requires mass > 2e24
      when /GasGiant/
        100 * 5.97e24  # Gas giants should be massive
      when /IceGiant/
        10 * 5.97e24   # Ice giants should be reasonably massive
      else
        1e20  # Very small minimum for other types
      end
    end
    
    def minimum_radius_for_type(planet_class)
      case planet_class.name
      when /SuperEarth/
        7e6 + 1  # SuperEarth validation requires radius > 7e6
      else
        1  # Very small minimum for other types
      end
    end
    
    def minimum_gravity_for_type(planet_class)
      case planet_class.name
      when /SuperEarth/
        10.0 + 0.1  # SuperEarth validation requires gravity > 10.0
      else
        0.1  # Very small minimum for other types
      end
    end
    
    def random_radius_for_type(planet_class)
      case planet_class.name
      when /TerrestrialPlanet/
        rand(0.5..1.5) * 6.37e6   # 0.5 to 1.5 Earth radii
      when /SuperEarth/
        rand(1.1..2.3) * 6.37e6   # 1.1 to 2.3 Earth radii (ensure > 7e6 and < 15e6)
      when /GasGiant/
        rand(8.0..12.0) * 6.37e6  # 8 to 12 Earth radii
      when /IceGiant/
        rand(3.5..5.0) * 6.37e6   # 3.5 to 5 Earth radii
      when /OceanPlanet/
        rand(1.3..2.5) * 6.37e6   # 1.3 to 2.5 Earth radii
      when /LargeMoon/
        rand(1000e3..3000e3)      # 1000-3000 km
      when /SmallMoon/
        rand(10e3..500e3)         # 10-500 km
      else
        6.37e6                    # Default to Earth radius
      end
    end
    
    def random_density_for_type(planet_class)
      case planet_class.name
      when /TerrestrialPlanet/
        rand(3.5..6.0)            # Earth-like density
      when /SuperEarth/
        rand(4.0..8.0)            # Higher density for super-Earths
      when /GasGiant/
        rand(0.3..1.2)            # Low density for gas giants
      when /IceGiant/
        rand(1.2..1.9)            # Medium-low density for ice giants
      when /OceanPlanet/
        rand(2.0..4.0)            # Medium density for ocean worlds
      when /LargeMoon/
        rand(2.5..4.0)            # Density for large moons
      when /SmallMoon/
        rand(1.5..3.0)            # Density for small moons
      else
        5.51                      # Default to Earth density
      end
    end
    
    def random_gravity_for_type(planet_class)
      case planet_class.name
      when /TerrestrialPlanet/
        rand(0.8..1.2)            # Earth-like gravity
      when /SuperEarth/
        rand(10.0..25.0)          # Higher gravity for super-Earths
      when /GasGiant/
        rand(20.0..50.0)          # High gravity for gas giants
      when /IceGiant/
        rand(10.0..25.0)          # Medium-high gravity for ice giants
      when /OceanPlanet/
        rand(0.5..1.5)            # Earth-like gravity for ocean worlds
      when /LargeMoon/
        rand(0.1..0.5)            # Low gravity for large moons
      when /SmallMoon/
        rand(0.01..0.1)           # Very low gravity for small moons
      else
        9.8                       # Default to Earth gravity
      end
    end
    
    # Helper method to calculate habitable zone
    def calculate_habitable_zone(luminosity)
      luminosity ||= 1.0
      inner_edge = Math.sqrt(luminosity) * 0.95
      outer_edge = Math.sqrt(luminosity) * 1.37
      [inner_edge, outer_edge]
    end
  end
end

