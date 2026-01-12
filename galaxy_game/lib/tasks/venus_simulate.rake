# lib/tasks/venus_simulate.rake
# Usage: rails venus:simulate

namespace :venus do
  desc "Run simulation on imported Venus and print before/after states"
  task simulate: :environment do
    puts "\n" + "="*80
    puts "VENUS SIMULATION"
    puts "="*80

    venus = CelestialBodies::CelestialBody.find_by(name: 'Venus')
    if venus.nil?
      puts "ERROR: Venus not found. Did you run the seeds?"
      exit 1
    end

    puts "\n[BEFORE SIMULATION]"
    puts "  Atmosphere:"
    if venus.atmosphere
      puts "    Pressure: #{venus.atmosphere.pressure} bar, Mass: #{venus.atmosphere.total_atmospheric_mass} kg"
      puts "    Composition: #{venus.atmosphere.composition.inspect}"
    else
      puts "    None"
    end
    puts "  Hydrosphere:"
    if venus.hydrosphere
      puts "    Mass: #{venus.hydrosphere.total_hydrosphere_mass} kg"
      puts "    Composition: #{venus.hydrosphere.composition.inspect}"
      puts "    State Distribution: #{venus.hydrosphere.state_distribution.inspect}"
    else
      puts "    None"
    end
    puts "  Geosphere:"
    if venus.geosphere
      puts "    Crust Mass: #{venus.geosphere.total_crust_mass} kg"
      puts "    Mantle Mass: #{venus.geosphere.total_mantle_mass} kg"
      puts "    Core Mass: #{venus.geosphere.total_core_mass} kg"
      puts "    Crust Composition: #{venus.geosphere.crust_composition.inspect}"
    else
      puts "    None"
    end

    puts "\nRunning simulation for 1000 days..."
    if defined?(TerraSim::BiosphereSimulationService)
      service = TerraSim::BiosphereSimulationService.new(venus)
      service.simulate(1000)
      venus.reload
      venus.atmosphere&.reload
      venus.hydrosphere&.reload
      venus.geosphere&.reload
    else
      puts "Simulation service not found. Skipping simulation."
    end

    puts "\n[AFTER SIMULATION]"
    puts "  Atmosphere:"
    if venus.atmosphere
      puts "    Pressure: #{venus.atmosphere.pressure} bar, Mass: #{venus.atmosphere.total_atmospheric_mass} kg"
      puts "    Composition: #{venus.atmosphere.composition.inspect}"
    else
      puts "    None"
    end
    puts "  Hydrosphere:"
    if venus.hydrosphere
      puts "    Mass: #{venus.hydrosphere.total_hydrosphere_mass} kg"
      puts "    Composition: #{venus.hydrosphere.composition.inspect}"
      puts "    State Distribution: #{venus.hydrosphere.state_distribution.inspect}"
    else
      puts "    None"
    end
    puts "  Geosphere:"
    if venus.geosphere
      puts "    Crust Mass: #{venus.geosphere.total_crust_mass} kg"
      puts "    Mantle Mass: #{venus.geosphere.total_mantle_mass} kg"
      puts "    Core Mass: #{venus.geosphere.total_core_mass} kg"
      puts "    Crust Composition: #{venus.geosphere.crust_composition.inspect}"
    else
      puts "    None"
    end

    puts "\nSimulation complete. Compare before/after states for changes."
    puts "="*80 + "\n"
  end
end
