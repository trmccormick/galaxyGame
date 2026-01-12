# lib/tasks/sol_verify.rake
# Usage: rails sol:verify

namespace :sol do
  desc "Verify imported Sol system planets and moons against expected values"
  task verify: :environment do
    puts "\n" + "="*80
    puts "SOL SYSTEM VERIFICATION"
    puts "="*80

    solar_system = SolarSystem.find_by(name: 'Sol')
    if solar_system.nil?
      puts "ERROR: Sol system not found. Did you run the seeds?"
      exit 1
    end

    puts "\nSolar System: #{solar_system.name} (ID: #{solar_system.id})"
    puts "Galaxy: #{solar_system.galaxy&.name}"
    puts "Stars:"
    solar_system.stars.each do |star|
      puts "  - #{star.name} (#{star.identifier}): mass=#{star.mass}, radius=#{star.radius}, temp=#{star.temperature}K"
    end

    puts "\nPlanets:"
    solar_system.celestial_bodies.where("type LIKE ?", "%Planet%").each do |planet|
      puts "  - #{planet.name} (#{planet.identifier})"
      puts "    Mass: #{planet.mass} kg, Radius: #{planet.radius} m, Density: #{planet.density} g/cm^3"
      puts "    Surface Temp: #{planet.surface_temperature}K, Gravity: #{planet.gravity} m/s^2"
      if planet.atmosphere
        puts "    Atmosphere:"
        puts "      Pressure: #{planet.atmosphere.pressure} bar, Mass: #{planet.atmosphere.total_atmospheric_mass} kg"
        puts "      Composition:"
        planet.atmosphere.composition.each do |gas, pct|
          puts "        #{gas}: #{pct}%"
        end
      else
        puts "    Atmosphere: None"
      end
      if planet.hydrosphere
        puts "    Hydrosphere:"
        puts "      Mass: #{planet.hydrosphere.total_hydrosphere_mass} kg"
        puts "      Composition: #{planet.hydrosphere.composition.inspect}"
        puts "      State Distribution: #{planet.hydrosphere.state_distribution.inspect}"
      else
        puts "    Hydrosphere: None"
      end
      if planet.geosphere
        puts "    Geosphere:"
        puts "      Crust Mass: #{planet.geosphere.total_crust_mass} kg"
        puts "      Mantle Mass: #{planet.geosphere.total_mantle_mass} kg"
        puts "      Core Mass: #{planet.geosphere.total_core_mass} kg"
        puts "      Crust Composition: #{planet.geosphere.crust_composition.inspect}"
      else
        puts "    Geosphere: None"
      end
    end

    puts "\nMoons:"
    solar_system.celestial_bodies.where("type LIKE ?", "%Moon%").each do |moon|
      puts "  - #{moon.name} (#{moon.identifier}) [Parent: #{moon.parent_celestial_body&.name}]"
      puts "    Mass: #{moon.mass} kg, Radius: #{moon.radius} m, Density: #{moon.density} g/cm^3"
      if moon.atmosphere
        puts "    Atmosphere:"
        puts "      Pressure: #{moon.atmosphere.pressure} bar, Mass: #{moon.atmosphere.total_atmospheric_mass} kg"
        puts "      Composition:"
        moon.atmosphere.composition.each do |gas, pct|
          puts "        #{gas}: #{pct}%"
        end
      else
        puts "    Atmosphere: None"
      end
      if moon.hydrosphere
        puts "    Hydrosphere:"
        puts "      Mass: #{moon.hydrosphere.total_hydrosphere_mass} kg"
        puts "      Composition: #{moon.hydrosphere.composition.inspect}"
        puts "      State Distribution: #{moon.hydrosphere.state_distribution.inspect}"
      else
        puts "    Hydrosphere: None"
      end
      if moon.geosphere
        puts "    Geosphere:"
        puts "      Crust Mass: #{moon.geosphere.total_crust_mass} kg"
        puts "      Mantle Mass: #{moon.geosphere.total_mantle_mass} kg"
        puts "      Core Mass: #{moon.geosphere.total_core_mass} kg"
        puts "      Crust Composition: #{moon.geosphere.crust_composition.inspect}"
      else
        puts "    Geosphere: None"
      end
    end

    puts "\nVerification complete. Compare output to sol.json for accuracy."
    puts "="*80 + "\n"
  end
end
