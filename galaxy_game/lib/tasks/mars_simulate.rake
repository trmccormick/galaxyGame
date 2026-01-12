# lib/tasks/mars_simulate.rake
# Usage: rails mars:simulate

namespace :mars do
  desc "Run simulation on imported Mars and print before/after states"
  task simulate: :environment do
    puts "\n" + "="*80
    puts "MARS SIMULATION"
    puts "="*80

    mars = CelestialBodies::CelestialBody.find_by(name: 'Mars')
    if mars.nil?
      puts "ERROR: Mars not found. Did you run the seeds?"
      exit 1
    end

    puts "\n[BEFORE SIMULATION]"
    puts "  Atmosphere:"
    if mars.atmosphere
      puts "    Pressure: #{mars.atmosphere.pressure} bar, Mass: #{mars.atmosphere.total_atmospheric_mass} kg"
      puts "    Composition: #{mars.atmosphere.composition.inspect}"
    else
      puts "    None"
    end
    puts "  Hydrosphere:"
    if mars.hydrosphere
      puts "    Mass: #{mars.hydrosphere.total_hydrosphere_mass} kg"
      puts "    Composition: #{mars.hydrosphere.composition.inspect}"
      puts "    State Distribution: #{mars.hydrosphere.state_distribution.inspect}"
    else
      puts "    None"
    end
    puts "  Geosphere:"
    if mars.geosphere
      puts "    Crust Mass: #{mars.geosphere.total_crust_mass} kg"
      puts "    Mantle Mass: #{mars.geosphere.total_mantle_mass} kg"
      puts "    Core Mass: #{mars.geosphere.total_core_mass} kg"
      puts "    Crust Composition: #{mars.geosphere.crust_composition.inspect}"
    else
      puts "    None"
    end

    puts "\nRunning simulation for 1000 days..."
    if defined?(TerraSim::BiosphereSimulationService)
      service = TerraSim::BiosphereSimulationService.new(mars)
      service.simulate(1000)
      mars.reload
      mars.atmosphere&.reload
      mars.hydrosphere&.reload
      mars.geosphere&.reload
    else
      puts "Simulation service not found. Skipping simulation."
    end

    puts "\n[AFTER SIMULATION]"
    puts "  Atmosphere:"
    if mars.atmosphere
      puts "    Pressure: #{mars.atmosphere.pressure} bar, Mass: #{mars.atmosphere.total_atmospheric_mass} kg"
      puts "    Composition: #{mars.atmosphere.composition.inspect}"
    else
      puts "    None"
    end
    puts "  Hydrosphere:"
    if mars.hydrosphere
      puts "    Mass: #{mars.hydrosphere.total_hydrosphere_mass} kg"
      puts "    Composition: #{mars.hydrosphere.composition.inspect}"
      puts "    State Distribution: #{mars.hydrosphere.state_distribution.inspect}"
    else
      puts "    None"
    end
    puts "  Geosphere:"
    if mars.geosphere
      puts "    Crust Mass: #{mars.geosphere.total_crust_mass} kg"
      puts "    Mantle Mass: #{mars.geosphere.total_mantle_mass} kg"
      puts "    Core Mass: #{mars.geosphere.total_core_mass} kg"
      puts "    Crust Composition: #{mars.geosphere.crust_composition.inspect}"
    else
      puts "    None"
    end

    puts "\nSimulation complete. Compare before/after states for changes."
    puts "="*80 + "\n"
  end
end
