# ==============================================================================
# Script: lib/tasks/terraforming_demo.rake
# Usage: rails terraforming:demo
# ==============================================================================

namespace :terraforming do
  desc "Demonstrate terraforming a barren planet with life forms"
  task demo: :environment do
    puts "\n" + "="*80
    puts "TERRAFORMING SIMULATION DEMO"
    puts "="*80
    
    # Step 1: Create a barren Mars-like planet
    puts "\n[STEP 1] Creating barren Mars-like planet..."
    
    celestial_body = CelestialBodies::CelestialBody.create!(
      name: "New Mars",
      identifier: "new_mars_#{Time.now.to_i}",
      body_type: "terrestrial",
      size: 3389.5, # Radius in km
      mass: 6.4171e23, # Mars mass in kg
      radius: 3389500, # Mars radius in meters
      density: 3.93,
      gravity: 0.38, # 38% of Earth
      surface_temperature: 210.0, # -63°C in Kelvin
      axial_tilt: 25.19
    )
    
    # Create atmosphere (thin CO2 atmosphere like Mars)
    atmosphere = celestial_body.create_atmosphere!(
      total_atmospheric_mass: 2.5e16, # Very thin compared to Earth (5.15e18)
      temperature: 210.0,
      pressure: 0.006, # 0.6% of Earth's pressure
      temperature_data: {
        'tropical_temperature' => 220.0,
        'polar_temperature' => 200.0
      },
      dust: { 'concentration' => 0.5, 'properties' => 'Iron oxide dust' }
    )
    # Set composition and initialize gases (spec pattern)
    atmosphere.update!(
      composition: {
        'CO2' => 95.32,
        'N2' => 2.7,
        'Ar' => 1.6,
        'O2' => 0.13
      },
      total_atmospheric_mass: 2.5e16
    )
    atmosphere.initialize_gases

    # --- Verification: Print initial atmospheric gas makeup ---
    puts "\n[VERIFY] Initial atmospheric gas makeup:"
    total_mass = atmosphere.gases.sum(:mass)
    sum_pct = atmosphere.gases.sum(:percentage)
    puts "  Total atmospheric mass: #{total_mass} kg"
    puts "  Gas breakdown:"
    atmosphere.gases.each do |gas|
        puts "    #{gas.name}: mass=#{gas.mass.round(3)}, pct=#{gas.percentage.round(4)}%, ppm=#{gas.ppm.round(1)}"
    end
    puts "  Sum of percentages: #{sum_pct.round(4)}%"
    
    # Create hydrosphere (frozen water)
    hydrosphere = celestial_body.create_hydrosphere!(
      total_hydrosphere_mass: 1.6e16, # Mars estimated water
      temperature: 210.0,
      pressure: 0.006, # Mars atmospheric pressure (bars)
      state_distribution: {
        'solid' => 90.0,  # Mostly ice
        'liquid' => 5.0,  # Trace liquid (subsurface)
        'vapor' => 5.0
      }
    )
    
    # Create biosphere
    biosphere = celestial_body.create_biosphere!(
      habitable_ratio: 0.1, # Barely habitable
      ice_latitude: 1.47,   # Ice near equator
      biodiversity_index: 0.0
    )
    
    puts "✓ Created planet: #{celestial_body.name}"
    puts "  - Surface temp: #{celestial_body.surface_temperature}K (#{(celestial_body.surface_temperature - 273.15).round(1)}°C)"
    puts "  - Atmospheric mass: #{atmosphere.total_atmospheric_mass} (Earth = 100)"
    puts "  - Initial O2: #{atmosphere.o2_percentage.round(4)}%"
    puts "  - Initial CO2: #{atmosphere.co2_percentage.round(4)}%"
    
    # Step 2: Deploy starter organisms
    puts "\n[STEP 2] Deploying starter ecosystem..."
    
    # Extremophile cyanobacteria - the pioneers
    cyano = Biology::LifeForm.create!(
      biosphere: biosphere,
      name: "Extremophile Cyanobacteria",
      complexity: :simple,
      population: 1_000_000_000, # 1 billion
      diet: "photosynthetic",
      properties: {
        'oxygen_production_rate' => 0.00015,      # Realistic: 0.015% per 100 days
        'co2_consumption_rate' => 0.00018,        # Consumes slightly more CO2
        'nitrogen_fixation_rate' => 0.00002,      # Fixes nitrogen slowly
        'preferred_biome' => 'Rocky Desert',
        'min_temperature' => 180.0,
        'max_temperature' => 320.0,
        'description' => 'Hardy photosynthetic bacteria that can survive extreme cold'
      }
    )
    
    # Green algae - secondary colonizers
    algae = Biology::LifeForm.create!(
      biosphere: biosphere,
      name: "Cold-Adapted Green Algae",
      complexity: :simple,
      population: 500_000_000, # 500 million
      diet: "photosynthetic",
      properties: {
        'oxygen_production_rate' => 0.00020,      # Slightly better than cyano
        'co2_consumption_rate' => 0.00022,        # More efficient
        'preferred_biome' => 'Tundra',
        'min_temperature' => 200.0,
        'max_temperature' => 310.0,
        'description' => 'More efficient photosynthesizers for slightly warmer areas'
      }
    )
    
    # Methanogens - for diverse gas production
    methanogens = Biology::LifeForm.create!(
      biosphere: biosphere,
      name: "Methanogenic Archaea",
      complexity: :simple,
      population: 800_000_000, # 800 million
      diet: "chemosynthetic",
      properties: {
        'methane_production_rate' => 0.00008,     # Slow methane production
        'co2_consumption_rate' => 0.00005,
        'preferred_biome' => 'Rocky Desert',
        'min_temperature' => 170.0,
        'max_temperature' => 330.0,
        'description' => 'Produce methane to help warm the planet'
      }
    )
    
    puts "✓ Deployed #{biosphere.life_forms.count} species:"
    biosphere.life_forms.each do |lf|
      puts "  - #{lf.name}: #{lf.population.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} organisms"
      contribution = lf.atmospheric_contribution
      puts "    O2: +#{contribution[:o2].round(4)}%/day, CO2: -#{contribution[:co2].round(4)}%/day, CH4: +#{contribution[:ch4].round(4)}%/day"
    end
    
    # Step 3: Show initial conditions
    puts "\n[STEP 3] Initial atmospheric conditions:"
    puts "  Oxygen (O2):        #{atmosphere.o2_percentage.round(6)}%"
    puts "  Carbon Dioxide:     #{atmosphere.co2_percentage.round(4)}%"
    puts "  Methane (CH4):      #{atmosphere.ch4_percentage.round(6)}%"
    puts "  Temperature:        #{atmosphere.temperature.round(1)}K (#{(atmosphere.temperature - 273.15).round(1)}°C)"
    puts "  Habitability:       #{(biosphere.habitable_ratio * 100).round(1)}%"
    
    # Step 4: Run simulation
    puts "\n[STEP 4] Running terraforming simulation..."
    puts "-" * 80
    
    simulation_days = [1, 10, 50, 100, 250, 500, 1000]
    service = TerraSim::BiosphereSimulationService.new(celestial_body)
    
    previous_day = 0
    simulation_days.each do |target_day|
      days_to_simulate = target_day - previous_day
      
      # Run simulation
      service.simulate(days_to_simulate)
      
      # Reload to get fresh data
      atmosphere.reload
      biosphere.reload
      
      # Display results
      puts "\nDay #{target_day}:"
      puts "  Atmospheric Composition:"
      puts "    O2:   #{atmosphere.o2_percentage.round(6)}%"
      puts "    CO2:  #{atmosphere.co2_percentage.round(4)}%"
      puts "    CH4:  #{atmosphere.ch4_percentage.round(6)}%"
      puts "  Temperature: #{atmosphere.temperature.round(1)}K (#{(atmosphere.temperature - 273.15).round(1)}°C)"
      puts "  Habitability: #{(biosphere.habitable_ratio * 100).round(1)}%"
      # --- Verification: Print current atmospheric gas makeup ---
      puts "  [VERIFY] Gas breakdown:"
      total_mass = atmosphere.gases.sum(:mass)
      sum_pct = atmosphere.gases.sum(:percentage)
      atmosphere.gases.each do |gas|
        puts "    #{gas.name}: mass=#{gas.mass.round(3)}, pct=#{gas.percentage.round(4)}%, ppm=#{gas.ppm.round(1)}"
      end
      puts "    Total atmospheric mass: #{total_mass} kg"
      puts "    Sum of percentages: #{sum_pct.round(4)}%"
      
      # Show life form populations
      puts "  Life Forms:"
      biosphere.life_forms.each do |lf|
        lf.reload
        puts "    #{lf.name}: #{lf.population.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      end
      
      previous_day = target_day
    end
    
    # Step 5: Final summary
    puts "\n" + "="*80
    puts "TERRAFORMING SUMMARY"
    puts "="*80
    
    initial_o2 = 0.13
    final_o2 = atmosphere.o2_percentage
    o2_change = ((final_o2 - initial_o2) / initial_o2 * 100).round(1)
    
    initial_co2 = 95.0
    final_co2 = atmosphere.co2_percentage
    co2_change = ((final_co2 - initial_co2) / initial_co2 * 100).round(1)
    
    puts "\nAfter #{simulation_days.last} days of terraforming:"
    puts "\nAtmospheric Changes:"
    puts "  Oxygen:   #{initial_o2}% → #{final_o2.round(4)}% (#{o2_change > 0 ? '+' : ''}#{o2_change}%)"
    puts "  CO2:      #{initial_co2}% → #{final_co2.round(2)}% (#{co2_change}%)"
    puts "  Methane:  0.0% → #{atmosphere.ch4_percentage.round(4)}%"
    
    puts "\nTemperature Change:"
    puts "  Initial: 210K (-63°C)"
    puts "  Final:   #{atmosphere.temperature.round(1)}K (#{(atmosphere.temperature - 273.15).round(1)}°C)"
    puts "  Change:  #{(atmosphere.temperature - 210).round(1)}K"
    
    puts "\nBiosphere Status:"
    puts "  Habitability:    #{(biosphere.habitable_ratio * 100).round(1)}%"
    puts "  Biodiversity:    #{biosphere.biodiversity_index}"
    puts "  Total Species:   #{biosphere.life_forms.count}"
    puts "  Total Organisms: #{biosphere.life_forms.sum(:population).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    
    puts "\n" + "="*80
    puts "Demo complete! Planet ID: #{celestial_body.id}"
    puts "="*80 + "\n"
  end
end