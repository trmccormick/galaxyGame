# app/services/star_sim/procedural_generator.rb
require 'json'
require 'fileutils'
require_relative '../name_generator_service'

module StarSim
  class ProceduralGenerator
    TERRAFORMABLE_CHANCE = 0.4 # 40% chance for terraformable planets
    
    def initialize(
      solar_system = nil,
      atmosphere_generator = nil,
      hydrosphere_generator = nil,
      material_lookup = nil, # Add MaterialLookupService
      planet_name_service = nil,
      force_complex_biosphere = false
    )
      @solar_system = solar_system
      @name_generator = NameGeneratorService.new
      @planet_name_service = planet_name_service || Naming::PlanetNameService.new
      @planet_counter = 0
      @output_path = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
      FileUtils.mkdir_p(@output_path) unless File.directory?(@output_path)
      @atmosphere_generator = atmosphere_generator || AtmosphereGeneratorService.new({}, material_lookup || Lookup::MaterialLookupService.new) # Default instance if not provided
      @hydrosphere_generator = hydrosphere_generator || HydrosphereGeneratorService.new({}) # Default instance if not provided
      @material_lookup = material_lookup || Lookup::MaterialLookupService.new # Ensure MaterialLookupService is available
      
      # Load terraformable planet templates
      @terraformable_templates = load_terraformable_templates
      @force_complex_biosphere = force_complex_biosphere
    end

    def generate_system_seed_file(num_planets: 10, num_stars: 1)
      seed_data = generate_system_seed(num_planets: num_planets, num_stars: num_stars)
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      filename = "generated_#{seed_data[:solar_system][:identifier]}_#{timestamp}.json" # Use identifier in filename
      filepath = File.join(@output_path, filename)

      File.open(filepath, 'w') do |f|
        f.write(JSON.pretty_generate(seed_data))
      end

      puts "Generated seed file: #{filepath}"
    end

    # Main method used by SystemGeneratorService
    def generate_system_seed(num_stars:, num_planets:)
      # Generate a system name
      system_name = @name_generator.generate_system_name
      system_identifier = system_name.upcase.gsub(/\s+/, '-')
      
      # Create the basic system structure
      system_data = {
        "galaxy" => {
          "name" => @solar_system&.galaxy&.name || "Milky Way",
          "identifier" => @solar_system&.galaxy&.identifier || "MILKY-WAY"
        },
        "solar_system" => {
          "name" => system_name,
          "identifier" => system_identifier
        },
        "stars" => generate_stars(num_stars, system_identifier),
        "celestial_bodies" => {
          "terrestrial_planets" => generate_terrestrial_planets(num_planets, system_identifier),
          "gas_giants" => generate_gas_giants(rand(0..3)),
          "ice_giants" => generate_ice_giants(rand(0..2)),
          "dwarf_planets" => generate_dwarf_planets(rand(0..5)),
          "asteroids" => generate_asteroids(rand(5..15)) # Add asteroids
        }
      }
      
      system_data
    end

    # Generate system with guaranteed prize targets for early wormhole shifts
    def generate_system_seed_with_prize_targets(num_stars:, num_planets:, shift_count: 0)
      system_data = generate_system_seed(num_stars: num_stars, num_planets: num_planets)
      
      # For first 3 shifts, ensure at least one prize target (TPL-A01 or TPL-A05)
      if shift_count < 3
        ensure_prize_targets_in_system!(system_data)
      end
      
      system_data
    end

    # Hybrid seeding: Load ground truth from seed file, generate procedural for empty orbits
    def generate_hybrid_system_from_seed(seed_path)
      seed_data = JSON.parse(File.read(seed_path))

      # Lock in ground truth: stars and Proxima Centauri b
      system_data = {
        "galaxy" => seed_data["galaxy"],
        "id" => seed_data["id"],
        "name" => seed_data["name"],
        "identifier" => seed_data["identifier"],
        "stars" => seed_data["stars"], # All stars are immutable ground truth
        "celestial_bodies" => {
          "terrestrial_planets" => [],
          "gas_giants" => [],
          "ice_giants" => [],
          "dwarf_planets" => []
        }
      }

      # Preserve Proxima Centauri b as immutable ground truth with locked atmosphere
      proxima_b = seed_data["celestial_bodies"].find { |body| body["name"] == "Proxima Centauri b" }
      if proxima_b
        # Ensure atmosphere is locked at 90% N2, 10% CO2
        proxima_b["atmosphere_attributes"] = {
          "composition" => {
            "N2" => { "percentage" => 90.0 },
            "CO2" => { "percentage" => 10.0 }
          },
          "pressure" => proxima_b.dig("atmosphere_attributes", "pressure") || 1.0,
          "locked" => true # Mark as atmospherically locked
        }
        system_data["celestial_bodies"]["terrestrial_planets"] << proxima_b
      end

      # Generate procedural planets for specific empty orbits around Alpha Centauri A and B
      alpha_a = seed_data["stars"].find { |star| star["name"] == "Alpha Centauri A" }
      alpha_b = seed_data["stars"].find { |star| star["name"] == "Alpha Centauri B" }

      if alpha_a
        # Generate planet at 1.23 AU around Alpha Centauri A
        planet_a = generate_planet_at_orbit(alpha_a, 1.23, seed_data["identifier"], "A")
        planet_a["market_status"] = "unclaimed_procedural"
        system_data["celestial_bodies"]["terrestrial_planets"] << planet_a
      end

      if alpha_b
        # Generate planet at 0.71 AU around Alpha Centauri B
        planet_b = generate_planet_at_orbit(alpha_b, 0.71, seed_data["identifier"], "B")
        planet_b["market_status"] = "unclaimed_procedural"
        system_data["celestial_bodies"]["terrestrial_planets"] << planet_b
      end

      system_data
    end

    # For test compatibility
    alias_method :generate!, :generate_system_seed

    # Methods expected by the SystemGenerator spec
    def generate_system(num_planets:, num_stars:)
      create_stars(num_stars)
      create_celestial_bodies(num_planets)
    end

    def create_stars(count)
      stars = []
      count.times do |i|
        star = @solar_system.stars.create!(
          identifier: "Star-#{i}-#{Time.now.to_i}",
          name: "Star #{i}",
          luminosity: 1.0,
          mass: 1.0,
          life: "main_sequence",
          age: 5e9,
          r_ecosphere: 1.0,
          type_of_star: "G",
          radius: 6.96e8,
          temperature: 5778,
          properties: { 'spectral_class' => 'G2V', 'stellar_class' => 'Main Sequence' }
        )
        stars << star.id
      end
      stars
    end

    def create_celestial_bodies(count)
      bodies = []
      count.times do |i|
        # Create with a concrete subclass and all required fields
        body = CelestialBodies::Planets::Rocky::TerrestrialPlanet.create!(
          name: "Planet #{i}",
          identifier: "Planet-#{i}-#{Time.now.to_i}",
          solar_system: @solar_system,
          mass: 1.0,
          radius: 1.0,
          size: 1.0,
          # Add these required fields:
          gravity: 9.8,                # Earth gravity (m/s²)
          orbital_period: 365.0,       # Earth year (days)
          surface_temperature: 288.0,  # Earth average temperature (K)
          density: 5.5,                # Earth density (g/cm³)
          albedo: 0.3                  # Earth albedo
        )
        bodies << body.id
      end
      bodies
    end

    private
    
    def ensure_prize_targets_in_system!(system_data)
      terrestrial_planets = system_data["celestial_bodies"]["terrestrial_planets"]
      
      # Check if we already have prize targets
      has_prize_a01 = terrestrial_planets.any? { |p| p["identifier"] == "TPL-A01" }
      has_prize_a05 = terrestrial_planets.any? { |p| p["identifier"] == "TPL-A05" }
      
      return if has_prize_a01 && has_prize_a05
      
      # Load alien templates - try v1.1 first, then v1.0
      template_files = [
        GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.1.json'),
        GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.json')
      ]
      
      template_file = template_files.find { |path| File.exist?(path) }
      alien_templates = if template_file
        JSON.parse(File.read(template_file))
      else
        { 'terrestrial_planets' => [] }
      end
      
      # Add missing prize targets
      unless has_prize_a01
        tpl_a01 = alien_templates["terrestrial_planets"].find { |t| t["identifier"] == "TPL-A01" }
        if tpl_a01
          terrestrial_planets << generate_from_template(
            tpl_a01, 
            "Prize Target A01", 
            "TPL-A01", 
            terrestrial_planets.length
          )
        end
      end
      
      unless has_prize_a05
        tpl_a05 = alien_templates["terrestrial_planets"].find { |t| t["identifier"] == "TPL-A05" }
        if tpl_a05
          terrestrial_planets << generate_from_template(
            tpl_a05, 
            "Prize Target A05", 
            "TPL-A05", 
            terrestrial_planets.length
          )
        end
      end
    end
    
    def load_terraformable_templates
      # Try to load v1.1 first, then fall back to v1.0
      template_files = [
        GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.1.json'),
        GalaxyGame::Paths::TEMPLATE_PATH.join('alien_world_templates_v1.json')
      ]
      
      template_file = template_files.find { |path| File.exist?(path) }
      return [] unless template_file
      
      begin
        data = JSON.parse(File.read(template_file))
        (data['terrestrial_planets'] || [])
          .select { |p| p['type'] == 'terrestrial' }
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to load terraformable templates from #{template_file}: #{e.message}"
        []
      end
    end

    def generate_from_template(template, planet_name, planet_identifier, index)
      # Start with template data and modify for uniqueness
      planet_data = template.deep_dup
      
      # Update identifiers and name
      planet_data["name"] = planet_name
      planet_data["identifier"] = planet_identifier
      
      # Apply small variations to prevent identical planets
      variation_factor = 0.05 # ±5% variation
      
      # Vary mass and radius slightly
      planet_data["mass"] = planet_data["mass"].to_f * (1 + rand(-variation_factor..variation_factor))
      planet_data["radius"] = planet_data["radius"].to_f * (1 + rand(-variation_factor..variation_factor))
      
      # Recalculate dependent properties
      volume = (4.0/3.0) * Math::PI * (planet_data["radius"] ** 3)
      planet_data["density"] = planet_data["mass"] / volume
      planet_data["gravity"] = calculate_gravity(planet_data["mass"], planet_data["radius"])
      planet_data["size"] = planet_data["radius"] / 6.371e6 # Earth radii
      
      # Vary albedo slightly
      planet_data["albedo"] = (planet_data["albedo"] || 0.3) * (1 + rand(-variation_factor..variation_factor))
      planet_data["albedo"] = [[planet_data["albedo"], 0.05].max, 0.9].min # Clamp to reasonable range
      
      # Mark as template-derived
      planet_data["from_template"] = true
      
      planet_data
    end

    def generate_procedural_terrestrial(planet_name, planet_identifier, index)
      # Original procedural generation (kept for variety)
      mass = rand(0.1..10.0) * 5.972e24
      radius = rand(0.5..2.0) * 6.371e6
      
      volume = (4.0/3.0) * Math::PI * (radius ** 3)
      density = mass / volume
      
      {
        "name" => planet_name,
        "identifier" => planet_identifier,
        "type" => "terrestrial",
        "mass" => mass,
        "radius" => radius,
        "density" => density,
        "gravity" => calculate_gravity(mass, radius),
        "albedo" => rand(0.1..0.6),
        "surface_temperature" => 288, # Will be recalculated based on orbit
        "size" => radius / 6.371e6, # Earth radii
        "known_pressure" => rand(0.1..2.0),
        "geological_activity" => rand(10..90),
        "geosphere_attributes" => {
          "geological_activity" => rand(10..90),
          "tectonic_activity" => rand < 0.4,
          "total_crust_mass" => mass * rand(0.01..0.05),
          "total_mantle_mass" => mass * rand(0.6..0.7),
          "total_core_mass" => mass * rand(0.25..0.35)
        },
        "from_template" => false
      }
    end

    # Methods to generate different types of celestial bodies
    def generate_stars(count, system_identifier)
      stars = []
      count.times do |i|
        star_name = @name_generator.generate_star_name(system_identifier, i)
        
        # Assign star mass based on spectral type distribution
        spectral_types = [
          { type: "M", mass_range: (0.08..0.45), probability: 0.76 },
          { type: "K", mass_range: (0.45..0.8), probability: 0.12 },
          { type: "G", mass_range: (0.8..1.04), probability: 0.076 },
          { type: "F", mass_range: (1.04..1.4), probability: 0.03 },
          { type: "A", mass_range: (1.4..2.1), probability: 0.006 },
          { type: "B", mass_range: (2.1..16), probability: 0.001 },
          { type: "O", mass_range: (16..150), probability: 0.0001 }
        ]
        
        # Pick a spectral type based on probability
        rand_val = rand
        cumulative_prob = 0
        chosen_type = spectral_types.find do |type|
          cumulative_prob += type[:probability]
          rand_val <= cumulative_prob
        end || spectral_types.first # Default to M if nothing matched
        
        # Generate mass within the range for this type
        mass_range = chosen_type[:mass_range]
        mass = rand(mass_range.begin..mass_range.end)
        
        # Calculate other properties based on mass
        radius = calculate_star_radius(mass)
        luminosity = calculate_star_luminosity(mass)
        temperature = calculate_star_temperature(mass)
        
        stars << {
          "name" => star_name,
          "identifier" => star_name.upcase.gsub(/\s+/, '-'),
          "type" => "#{chosen_type[:type]}#{rand(0..9)}V", # Adding a subtype and luminosity class
          "mass" => mass,
          "radius" => radius,
          "luminosity" => luminosity,
          "temperature" => temperature
        }
      end
      
      stars
    end

    def generate_terrestrial_planets(count, system_identifier)
      planets = []
      
      # If we have stars, use the first one for orbits
      star_for_planets = @solar_system&.stars&.first
      
      count.times do |i|
        @planet_counter += 1
        
        # Use identifier as name initially - proper names assigned upon settlement
        planet_identifier = "#{system_identifier}-P#{i + 1}"
        planet_name = planet_identifier
        
        # Decide whether to use a terraformable template or generate procedurally
        use_template = !@terraformable_templates.empty? && rand < TERRAFORMABLE_CHANCE
        
        # Decide whether to use a terraformable template or generate procedurally
        use_template = !@terraformable_templates.empty? && rand < TERRAFORMABLE_CHANCE
        
        if use_template
          planet_data = generate_from_template(@terraformable_templates.sample, planet_name, planet_identifier, i)
          # Terraformable planets get preferential orbital placement
          orbital_parameters = generate_optimized_orbital_parameters(i, star_for_planets)
        else
          planet_data = generate_procedural_terrestrial(planet_name, planet_identifier, i)
          orbital_parameters = generate_orbital_parameters(i)
        end
        planet_data["orbits"] = [{
          "around" => star_for_planets&.name || "Primary Star",
          "semi_major_axis_au" => orbital_parameters[:semi_major_axis_au],
          "eccentricity" => orbital_parameters[:eccentricity],
          "inclination_deg" => orbital_parameters[:inclination_deg],
          "orbital_period_days" => orbital_parameters[:orbital_period_days],
          "distance" => orbital_parameters[:semi_major_axis_au]
        }]
        
        # Recalculate temperature based on actual orbit
        planet_data["surface_temperature"] = calculate_surface_temperature(orbital_parameters[:semi_major_axis_au])
        
        # Generate atmosphere using existing generators - but only if not from template
        if !planet_data["from_template"]
          atmosphere_data = @atmosphere_generator.generate_composition_for_body(
            planet_name,
            planet_data["surface_temperature"],
            planet_data["mass"],
            planet_data["radius"],
            orbital_parameters[:semi_major_axis_au],
            star_for_planets&.type,
            rand < 0.5
          )
          planet_data[:atmosphere] = atmosphere_data
        end
        
        # Generate hydrosphere
        hydrosphere_data = @hydrosphere_generator.generate(planet_data)
        planet_data[:hydrosphere] = hydrosphere_data

        # Generate biosphere data
        biosphere_data = generate_biosphere_data(planet_data)
        planet_data["biosphere_attributes"] = biosphere_data

        # Generate moons for this planet (some planets have moons)
        if rand < 0.6 # 60% of terrestrial planets have moons
          moon_count = rand(1..3)
          planet_data["moons"] = generate_moons_for_planet(planet_data, moon_count, system_identifier)
        end

        planets << planet_data
      end
      
      planets
    end

    def generate_planets_for_star(star, system_identifier, count)
      planets = []
      ecosphere_radius = star["r_ecosphere"] || 1.0

      count.times do |i|
        @planet_counter += 1

        # Decide whether to use a terraformable template or generate procedurally
        use_template = !@terraformable_templates.empty? && rand < TERRAFORMABLE_CHANCE

        planet_name = @planet_name_service.generate_planet_name(
          terraformable: use_template,
          system_identifier: system_identifier,
          index: @planet_counter,
          world_composition: use_template ? 'terrestrial' : 'rocky'
        )
        planet_identifier = "PROC-#{@planet_counter}"

        if use_template
          planet_data = generate_from_template(@terraformable_templates.sample, planet_name, planet_identifier, i)
        else
          planet_data = generate_procedural_terrestrial(planet_name, planet_identifier, i)
        end

        # Generate orbital parameters around the ecosphere
        semi_major_axis = ecosphere_radius + rand(-0.5..0.5) # Within ecosphere +/- 0.5 AU
        orbital_parameters = {
          semi_major_axis_au: semi_major_axis,
          eccentricity: rand(0.0..0.3),
          inclination_deg: rand(0.0..10.0),
          orbital_period_days: calculate_orbital_period(semi_major_axis)
        }

        planet_data["orbits"] = [{
          "around" => star["name"],
          "semi_major_axis_au" => orbital_parameters[:semi_major_axis_au],
          "eccentricity" => orbital_parameters[:eccentricity],
          "inclination_deg" => orbital_parameters[:inclination_deg],
          "orbital_period_days" => orbital_parameters[:orbital_period_days],
          "distance" => orbital_parameters[:semi_major_axis_au]
        }]

        # Recalculate temperature based on actual orbit
        planet_data["surface_temperature"] = calculate_surface_temperature(orbital_parameters[:semi_major_axis_au])

        # Generate atmosphere
        atmosphere_data = @atmosphere_generator.generate_composition_for_body(
          planet_name,
          planet_data["surface_temperature"],
          planet_data["mass"],
          planet_data["radius"],
          orbital_parameters[:semi_major_axis_au],
          star["type"] || "G-type",
          rand < 0.5
        )
        planet_data[:atmosphere] = atmosphere_data

        # Generate hydrosphere
        hydrosphere_data = @hydrosphere_generator.generate(planet_data)
        planet_data[:hydrosphere] = hydrosphere_data

        # Generate biosphere data
        biosphere_data = generate_biosphere_data(planet_data)
        planet_data["biosphere_attributes"] = biosphere_data

        # Tag as procedural for market
        planet_data["market_status"] = "unclaimed_procedural"

        planets << planet_data
      end

      planets
    end

    def calculate_orbital_period(semi_major_axis_au)
      # Kepler's Third Law: P^2 = a^3 (P in years, a in AU)
      orbital_period_years = Math.sqrt(semi_major_axis_au ** 3)
      orbital_period_years * 365.25
    end

    def generate_planet_at_orbit(star, semi_major_axis_au, system_identifier, star_suffix)
      @planet_counter += 1

      planet_name = @planet_name_service.generate_planet_name(
        terraformable: false,
        system_identifier: system_identifier,
        index: @planet_counter,
        world_composition: 'rocky'
      )
      planet_identifier = "#{star['identifier']}-P#{@planet_counter}"

      # Generate procedural terrestrial planet
      mass = rand(0.1..10.0) * 5.972e24
      radius = rand(0.5..2.0) * 6.371e6

      volume = (4.0/3.0) * Math::PI * (radius ** 3)
      density = mass / volume

      # Calculate orbital period for the specific semi-major axis
      orbital_period_days = calculate_orbital_period(semi_major_axis_au)

      # Calculate surface temperature based on stellar parameters and orbit
      stellar_luminosity = star['luminosity'] || 1.0
      stellar_temperature = star['temperature'] || 5778
      distance_from_star = semi_major_axis_au * 1.496e11  # Convert AU to meters

      # Simplified temperature calculation using Stefan-Boltzmann
      effective_temp = stellar_temperature * Math.sqrt(Math.sqrt(stellar_luminosity) / (2 * semi_major_axis_au))
      surface_temperature = effective_temp * (1 - 0.3)**(1/4)  # Rough greenhouse effect adjustment

      planet_data = {
        "name" => planet_name,
        "identifier" => planet_identifier,
        "type" => "terrestrial",
        "mass" => mass,
        "radius" => radius,
        "density" => density,
        "gravity" => calculate_gravity(mass, radius),
        "albedo" => rand(0.1..0.6),
        "surface_temperature" => surface_temperature,
        "size" => radius / 6.371e6, # Earth radii
        "known_pressure" => rand(0.1..2.0),
        "geological_activity" => rand(10..90),
        "distance_from_star" => distance_from_star,
        "orbital_period" => orbital_period_days,
        "star_distances" => [{
          "star_name" => star['name'],
          "distance" => distance_from_star
        }],
        "orbits" => [{
          "around" => star['name'],
          "semi_major_axis_au" => semi_major_axis_au,
          "eccentricity" => rand(0.0..0.3),
          "inclination_deg" => rand(0.0..5.0),
          "orbital_period_days" => orbital_period_days,
          "distance" => semi_major_axis_au
        }],
        "geosphere_attributes" => {
          "geological_activity" => rand(10..90),
          "tectonic_activity" => rand < 0.4,
          "total_crust_mass" => mass * rand(0.01..0.05),
          "total_mantle_mass" => mass * rand(0.6..0.7),
          "total_core_mass" => mass * rand(0.25..0.35)
        },
        "hydrosphere_attributes" => {
          "total_water_mass" => mass * 0.001, # Basic estimate
          "surface_coverage" => 0.1
        },
        "atmosphere_attributes" => @atmosphere_generator.generate_composition_for_body(
          planet_name,
          surface_temperature,
          mass,
          radius,
          semi_major_axis_au,
          star['type_of_star'],
          rand < 0.5
        ),
        "biosphere_attributes" => generate_biosphere_data({
          type: "terrestrial",
          surface_temperature: surface_temperature,
          atmosphere: { pressure: 1.0 },
          gravity: calculate_gravity(mass, radius)
        }),
        "market_status" => "unclaimed_procedural"
      }

      planet_data
    end

    def generate_gas_giants(count)
      planets = []
      star_for_planets = @solar_system&.stars&.first

      count.times do |i|
        @planet_counter += 1
        planet_name = "Gas Giant #{@planet_counter}"
        planet_identifier = "GAS_GIANT-#{@planet_counter}"

        mass = rand(10..1000) * 5.972e24  # Earth masses
        radius = rand(4..20) * 6.371e6    # Earth radii

        volume = (4.0 / 3.0) * Math::PI * (radius**3)
        density = mass / volume

        orbital_parameters = generate_orbital_parameters(i + 3) # Gas giants further out
        surface_temperature = calculate_surface_temperature(orbital_parameters[:semi_major_axis_au])

         planet_data = {
            "name" => planet_name,
            "identifier" => planet_identifier,
            "type" => "gas_giant",
            "mass" => mass,
            "radius" => radius,
            "density" => density,
            "gravity" => calculate_gravity(mass, radius),
            "albedo" => rand(0.4..0.9),  # Higher albedo for gas giants
            "surface_temperature" => surface_temperature,
            "orbits" => [{
              "around" => star_for_planets&.name || "Primary Star",
              "semi_major_axis_au" => orbital_parameters[:semi_major_axis_au],
              "eccentricity" => orbital_parameters[:eccentricity],
              "inclination_deg" => orbital_parameters[:inclination_deg],
              "orbital_period_days" => orbital_parameters[:orbital_period_days],
              "distance" => orbital_parameters[:semi_major_axis_au]
            }]
          }

        atmosphere_data = @atmosphere_generator.generate_composition_for_body(
          planet_name,
          surface_temperature,
          mass,
          radius,
          orbital_parameters[:semi_major_axis_au],
          star_for_planets&.type,
          true # Assume gas giants have magnetic fields
        )
        planet_data[:atmosphere] = atmosphere_data

        hydrosphere_data = @hydrosphere_generator.generate(planet_data)
        planet_data[:hydrosphere] = hydrosphere_data

        planets << planet_data
      end
      planets
    end

    def generate_ice_giants(count)
      planets = []
      star_for_planets = @solar_system&.stars&.first

      count.times do |i|
        @planet_counter += 1
        planet_name = "Ice Giant #{@planet_counter}"
        planet_identifier = "ICE_GIANT-#{@planet_counter}"
        mass = rand(10..50) * 5.972e24  # Earth masses
        radius = rand(3..5) * 6.371e6    # Earth radii

        volume = (4.0 / 3.0) * Math::PI * (radius**3)
        density = mass / volume

        orbital_parameters = generate_orbital_parameters(i + 5)
        surface_temperature = calculate_surface_temperature(orbital_parameters[:semi_major_axis_au])

        planet_data = {
          "name" => planet_name,
          "identifier" => planet_identifier,
          "type" => "ice_giant",
          "mass" => mass,
          "radius" => radius,
          "density" => density,
          "gravity" => calculate_gravity(mass, radius),
          "albedo" => rand(0.5..0.8),
          "surface_temperature" => surface_temperature,
          "orbits" => [{
            "around" => star_for_planets&.name || "Primary Star",
            "semi_major_axis_au" => orbital_parameters[:semi_major_axis_au],
            "eccentricity" => orbital_parameters[:eccentricity],
            "inclination_deg" => orbital_parameters[:inclination_deg],
            "orbital_period_days" => orbital_parameters[:orbital_period_days],
            "distance" => orbital_parameters[:semi_major_axis_au]
          }]
        }

        atmosphere_data = @atmosphere_generator.generate_composition_for_body(
          planet_name,
          surface_temperature,
          mass,
          radius,
          orbital_parameters[:semi_major_axis_au],
          star_for_planets&.type,
          true
        )
        planet_data[:atmosphere] = atmosphere_data

        hydrosphere_data = @hydrosphere_generator.generate(planet_data)
        planet_data[:hydrosphere] = hydrosphere_data
        planets << planet_data
      end
      planets
    end

    def generate_dwarf_planets(count)
      planets = []
      star_for_planets = @solar_system&.stars&.first
      count.times do |i|
        @planet_counter += 1
        planet_name = "Dwarf Planet #{@planet_counter}"
        planet_identifier = "DWARF_PLANET-#{@planet_counter}"
        mass = rand(0.01..0.1) * 5.972e24
        radius = rand(0.1..0.5) * 6.371e6

        volume = (4.0 / 3.0) * Math::PI * (radius**3)
        density = mass / volume

        orbital_parameters = generate_orbital_parameters(i + 7)
        surface_temperature = calculate_surface_temperature(orbital_parameters[:semi_major_axis_au])

        planet_data = {
          "name" => planet_name,
          "identifier" => planet_identifier,
          "type" => "dwarf_planet",
          "mass" => mass,
          "radius" => radius,
          "density" => density,
          "gravity" => calculate_gravity(mass, radius),
          "albedo" => rand(0.1..0.7),
          "surface_temperature" => surface_temperature,
           "orbits" => [{
            "around" => star_for_planets&.name || "Primary Star",
            "semi_major_axis_au" => orbital_parameters[:semi_major_axis_au],
            "eccentricity" => orbital_parameters[:eccentricity],
            "inclination_deg" => orbital_parameters[:inclination_deg],
            "orbital_period_days" => orbital_parameters[:orbital_period_days],
            "distance" => orbital_parameters[:semi_major_axis_au]
          }]
        }
        atmosphere_data = @atmosphere_generator.generate_composition_for_body(
          planet_name,
          surface_temperature,
          mass,
          radius,
          orbital_parameters[:semi_major_axis_au],
          star_for_planets&.type,
          rand < 0.2
        )
        planet_data[:atmosphere] = atmosphere_data

        hydrosphere_data = @hydrosphere_generator.generate(planet_data)
        planet_data[:hydrosphere] = hydrosphere_data
        planets << planet_data
      end
      planets
    end

    # Helper methods to calculate various properties
    
    def generate_optimized_orbital_parameters(planet_index, star)
      # For terraformable planets, bias toward habitable zone
      base_distance = 0.4 + 0.3 * (2 ** planet_index)
      
      # Calculate habitable zone based on star type (simplified)
      habitable_zone_center = calculate_habitable_zone_center(star)
      
      # 70% chance to place in or near habitable zone for terraformable planets
      if rand < 0.7
        distance_au = habitable_zone_center * rand(0.8..1.5) # ±20% from HZ center
      else
        distance_au = base_distance * rand(0.8..1.2)
      end
      
      # Other orbital parameters (same as before)
      eccentricity = rand(0.0..0.1)
      inclination_deg = rand(0.0..5.0)
      
      orbital_period_years = Math.sqrt(distance_au ** 3)
      orbital_period_days = orbital_period_years * 365.25
      
      {
        semi_major_axis_au: distance_au,
        eccentricity: eccentricity,
        inclination_deg: inclination_deg,
        orbital_period_days: orbital_period_days
      }
    end

    def calculate_habitable_zone_center(star)
      return 1.0 unless star # Default to 1 AU
      
      # Simplified habitable zone calculation based on stellar luminosity
      luminosity = star.luminosity || 1.0
      Math.sqrt(luminosity) # HZ scales with square root of luminosity
    end

    def generate_orbital_parameters(planet_index)
      # Use Titius-Bode Law for approximate spacing
      semi_major_axis_au = 0.4 + 0.3 * (2 ** planet_index)
      
      # Add some randomness
      semi_major_axis_au *= rand(0.8..1.2)
      
      # Other orbital parameters
      eccentricity = rand(0.0..0.1)
      inclination_deg = rand(0.0..5.0)
      
      # Calculate orbital period using Kepler's Third Law
      # P^2 = a^3 (where P is in years and a is in AU)
      orbital_period_years = Math.sqrt(semi_major_axis_au ** 3)
      orbital_period_days = orbital_period_years * 365.25
      
      {
        semi_major_axis_au: semi_major_axis_au,
        eccentricity: eccentricity,
        inclination_deg: inclination_deg,
        orbital_period_days: orbital_period_days
      }
    end

    def generate_optimized_orbital_parameters(planet_index, star)
      # For terraformable planets, place them near the habitable zone
      hz_center = calculate_habitable_zone_center(star)
      
      # Add some variation around the HZ center
      variation = rand(-0.3..0.3) # ±0.3 AU variation
      semi_major_axis_au = hz_center + variation
      
      # Ensure it's not too close to the star
      semi_major_axis_au = [semi_major_axis_au, 0.5].max
      
      # Other orbital parameters - more circular for habitable planets
      eccentricity = rand(0.0..0.05)
      inclination_deg = rand(0.0..2.0)
      
      # Calculate orbital period using Kepler's Third Law
      orbital_period_years = Math.sqrt(semi_major_axis_au ** 3)
      orbital_period_days = orbital_period_years * 365.25
      
      {
        semi_major_axis_au: semi_major_axis_au,
        eccentricity: eccentricity,
        inclination_deg: inclination_deg,
        orbital_period_days: orbital_period_days
      }
    end

    def calculate_star_radius(mass)
      # Simple approximation for main sequence stars
      # For M >= 1 solar mass: R ~ M^0.8
      # For M < 1 solar mass: R ~ M^0.57
      solar_radius = 6.96e8
      
      if mass >= 1.0
        solar_radius * (mass ** 0.8)
      else
        solar_radius * (mass ** 0.57)
      end
    end

    def calculate_star_luminosity(mass)
      # Approximation: L ~ M^3.5 for main sequence stars
      mass ** 3.5
    end

    def calculate_star_temperature(mass)
      # Very rough approximation
      if mass < 0.5
        3000 + (mass - 0.1) * 3000
      elsif mass < 1.0
        4000 + (mass - 0.5) * 1556
      elsif mass < 2.0
        5778 + (mass - 1.0) * 2000
      else
        7778 + (mass - 2.0) * 5000
      end
    end

    def calculate_gravity(mass, radius)
      # g = G * M / r^2
      g_constant = 6.67430e-11
      gravity = g_constant * mass / (radius ** 2)
      
      # Convert to Earth g's
      earth_g = 9.80665
      gravity / earth_g
    end

    def calculate_surface_temperature(distance_au)
      # Very simple approximation assuming Earth-like atmospheres
      # T ~ 278K * (1/sqrt(distance_au))
      base_temp = 278
      base_temp / Math.sqrt(distance_au)
    end

    def generate_biosphere_data(planet_data)
      # Only generate biosphere data for terrestrial planets with atmosphere
      return {} unless planet_data["type"] == 'terrestrial' && planet_data["atmosphere"]
      
      # Get temperature and pressure
      temp = planet_data["surface_temperature"] || 288
      
      # Check if this planet came from a template (more likely to be terraformable)
      from_template = planet_data.key?('geosphere_attributes')
      
      # Basic biosphere data
      biosphere_data = {
        biodiversity_index: 0.0,
        habitable_ratio: 0.0,
        biome_distribution: {}
      }
      
      # Planets from templates or with good conditions get better starting biosphere
      good_conditions = temp.between?(260, 310) && 
                       planet_data["atmosphere"]["pressure"].to_f.between?(0.5, 2.0) &&
                       planet_data["gravity"].to_f.between?(0.5, 1.5)
      
      if from_template || good_conditions || @force_complex_biosphere
        # Template planets or planets with good conditions get starter biomes
        base_habitability = from_template ? 0.15 : 0.05
        biosphere_data[:biodiversity_index] = rand(base_habitability..base_habitability * 2)
        biosphere_data[:habitable_ratio] = rand(base_habitability..base_habitability * 1.5)
        
        # Add some basic biome distribution
        if temp.between?(270, 300)
          biosphere_data[:biome_distribution] = {
            'temperate' => rand(0.3..0.7),
            'desert' => rand(0.1..0.3),
            'ocean' => rand(0.2..0.5)
          }
        end
      end
      
      # Extremely rare: Generate complex biosphere (second Earth scenario)
      # ~1 in 50,000 chance for a planet to have existing complex life
      # Or force it for testing
      if @force_complex_biosphere
        # Force complex biosphere for testing
        biosphere_data[:biodiversity_index] = rand(0.8..1.0)
        biosphere_data[:habitable_ratio] = rand(0.9..1.0)
        biosphere_data[:estimated_species_count] = rand(1000000..20000000)
        biosphere_data[:primary_producers] = ["plants", "phytoplankton", "algae"]
        biosphere_data[:consumers] = ["animals", "zooplankton", "insects"]
        biosphere_data[:decomposers] = ["bacteria", "fungi", "microorganisms"]
        biosphere_data[:biome_distribution] = {
          'temperate' => rand(0.4..0.6),
          'tropical' => rand(0.2..0.4),
          'desert' => rand(0.05..0.15),
          'ocean' => rand(0.6..0.8),
          'polar' => rand(0.1..0.2)
        }
      elsif rand < 0.00002 && good_conditions
        # Rare natural occurrence
        biosphere_data[:biodiversity_index] = rand(0.8..1.0)
        biosphere_data[:habitable_ratio] = rand(0.9..1.0)
        biosphere_data[:estimated_species_count] = rand(1000000..20000000)
        biosphere_data[:primary_producers] = ["plants", "phytoplankton", "algae"]
        biosphere_data[:consumers] = ["animals", "zooplankton", "insects"]
        biosphere_data[:decomposers] = ["bacteria", "fungi", "microorganisms"]
        biosphere_data[:biome_distribution] = {
          'temperate' => rand(0.4..0.6),
          'tropical' => rand(0.2..0.4),
          'desert' => rand(0.05..0.15),
          'ocean' => rand(0.6..0.8),
          'polar' => rand(0.1..0.2)
        }
      end
      
      biosphere_data
    end

    def generate_moons_for_planet(planet_data, count, system_identifier)
      moons = []
      
      count.times do |i|
        @planet_counter += 1
        moon_name = "#{planet_data['name']} #{roman_numeral(i + 1)}"
        moon_identifier = "#{planet_data['identifier']}-MOON-#{i + 1}"
        
        # Moons are smaller, with random sizes
        mass = rand(0.0001..0.1) * 7.34e22  # Up to 0.1 lunar masses
        radius = rand(0.1..1.5) * 1.738e6   # Up to 1.5 lunar radii
        
        volume = (4.0/3.0) * Math::PI * (radius ** 3)
        density = mass / volume
        
        # Orbital distance from planet (in planetary radii)
        orbital_distance = rand(2..50) * planet_data["radius"]
        
        moon_data = {
          "name" => moon_name,
          "identifier" => moon_identifier,
          "type" => "moon",
          "mass" => mass,
          "radius" => radius,
          "diameter_km" => (radius * 2) / 1000, # Convert to km for AI analysis
          "density" => density,
          "gravity" => calculate_gravity(mass, radius),
          "albedo" => rand(0.1..0.4),
          "surface_temperature" => planet_data["surface_temperature"] * rand(0.8..1.2),
          "orbiting_body" => planet_data["name"],
          "orbits" => [{
            "around" => planet_data["name"],
            "semi_major_axis_au" => orbital_distance / 1.496e11, # Convert to AU
            "eccentricity" => rand(0.0..0.1),
            "inclination_deg" => rand(0.0..10.0),
            "orbital_period_days" => rand(1..30), # Simplified
            "distance" => orbital_distance / 1.496e11
          }]
        }
        
        # Some moons have thin atmospheres
        if rand < 0.3
          atmosphere_data = @atmosphere_generator.generate_composition_for_body(
            moon_name,
            moon_data["surface_temperature"],
            mass,
            radius,
            moon_data["orbits"].first["semi_major_axis_au"],
            nil, # No star type for moon
            false
          )
          moon_data[:atmosphere] = atmosphere_data
        end
        
        moons << moon_data
      end
      
      moons
    end

    def generate_asteroids(count)
      asteroids = []
      
      count.times do |i|
        @planet_counter += 1
        asteroid_name = "Asteroid #{roman_numeral(@planet_counter)}"
        asteroid_identifier = "ASTEROID-#{@planet_counter}"
        
        # Asteroids vary greatly in size
        mass = rand(1e15..1e20)  # Very small masses
        radius = rand(0.1..50) * 1000  # 100m to 50km
        
        volume = (4.0/3.0) * Math::PI * (radius ** 3)
        density = mass / volume
        
        # Random orbital distance (asteroid belt area)
        orbital_distance_au = rand(2.0..4.0)
        
        asteroid_data = {
          "name" => asteroid_name,
          "identifier" => asteroid_identifier,
          "type" => "asteroid",
          "mass" => mass,
          "radius" => radius,
          "diameter_km" => (radius * 2) / 1000,
          "density" => density,
          "gravity" => calculate_gravity(mass, radius),
          "albedo" => rand(0.05..0.3),
          "surface_temperature" => calculate_surface_temperature(orbital_distance_au),
          "orbits" => [{
            "around" => "Primary Star",
            "semi_major_axis_au" => orbital_distance_au,
            "eccentricity" => rand(0.0..0.3),
            "inclination_deg" => rand(0.0..20.0),
            "orbital_period_days" => calculate_orbital_period(orbital_distance_au),
            "distance" => orbital_distance_au
          }]
        }
        
        asteroids << asteroid_data
      end
      
      asteroids
    end

    def roman_numeral(n)
      roman = ""
      roman << "M" * (n / 1000)
      roman << "CM" * ((n % 1000) / 900)
      roman << "D" * ((n % 1000 % 900) / 500)
      roman << "CD" * ((n % 1000 % 900 % 500) / 400)
      roman << "C" * ((n % 1000 % 900 % 500 % 400) / 100)
      roman << "XC" * ((n % 1000 % 900 % 500 % 400 % 100) / 90)
      roman << "L" * ((n % 1000 % 900 % 500 % 400 % 100 % 90) / 50)
      roman << "XL" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50) / 40)
      roman << "X" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50 % 40) / 10)
      roman << "IX" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50 % 40 % 10) / 9)
      roman << "V" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50 % 40 % 10 % 9) / 5)
      roman << "IV" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50 % 40 % 10 % 9 % 5) / 4)
      roman << "I" * ((n % 1000 % 900 % 500 % 400 % 100 % 90 % 50 % 40 % 10 % 9 % 5 % 4) / 1)
      roman
    end
  end
end