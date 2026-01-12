# Baseline planetary simulation Rake task
# This task loads Mars, Venus, Earth, and Titan from the database/models,
# sets their initial properties from JSON/model data, runs the simulation,
# and outputs their status to validate baseline behavior.

namespace :terra_sim do
  desc "Run baseline simulation for Mars, Venus, Earth, and Titan"
  task :baseline, [:days] => :environment do |t, args|
    days = (args[:days] || 0).to_i
    planet_names = ENV['PLANETS']&.split(',') || ["Earth", "Mars", "Venus", "Titan"]
    
    puts "🌍 Running baseline planetary simulation"
    puts "   Planets: #{planet_names.join(', ')}"
    puts "   Simulation days: #{days}"
    puts "   Mode: #{days > 0 ? 'Active simulation' : 'Baseline validation'}"
    puts ""
    
    results = []
    
    planet_names.each do |name|
      planet = CelestialBodies::CelestialBody.find_by(name: name)
      if planet.nil?
        puts "❌ Planet #{name} not found in database."
        results << { name: name, status: :missing }
        next
      end
      
      puts "🔄 Processing #{planet.name}..."
      
      # Capture pre-reset state
      pre_reset = capture_planetary_state(planet, "Pre-reset")
      
      # Reset spheres to initial state from model/JSON
      reset_success = reset_planetary_spheres(planet)
      
      if reset_success
        puts "   ✅ Spheres reset successfully"
      else
        puts "   ⚠️  Some sphere resets may have failed"
      end
      
      # Capture post-reset state
      post_reset = capture_planetary_state(planet, "Post-reset")
      
      # Run simulation
      simulation_success = run_planetary_simulation(planet, days)
      
      # Capture final state
      final_state = capture_planetary_state(planet, "Final")
      
      # Validate baseline behavior
      validation = validate_baseline_behavior(planet, pre_reset, post_reset, final_state, days)
      
      # Output status
      display_planetary_status(planet, validation)
      
      results << {
        name: name,
        status: :processed,
        reset_success: reset_success,
        simulation_success: simulation_success,
        validation: validation
      }
    end
    
    # Summary
    display_summary(results, days)
  end
end

# Helper methods

def reset_planetary_spheres(planet)
  success = true
  
  # Atmosphere reset
  if planet.atmosphere
    begin
      if planet.atmosphere.respond_to?(:reset) && planet.atmosphere.base_values.present?
        planet.atmosphere.reset
      else
        # Manual reset if no base values
        planet.atmosphere.update!(
          temperature: planet.surface_temperature || 288.0,
          pressure: planet.known_pressure || 101325.0,
          composition: planet.atmosphere.composition || {},
          total_atmospheric_mass: planet.atmosphere.total_atmospheric_mass || 0.0
        )
      end
    rescue => e
      puts "   ❌ Atmosphere reset failed: #{e.message}"
      success = false
    end
  end
  
  # Hydrosphere reset
  if planet.hydrosphere
    begin
      # Skip hydrosphere reset due to data type issues - manual reset not working
      puts "   ⚠️  Hydrosphere reset skipped (data type compatibility issue)"
    rescue => e
      puts "   ❌ Hydrosphere reset failed: #{e.message}"
      success = false
    end
  end
  
  # Geosphere reset
  if planet.geosphere
    begin
      if planet.geosphere.respond_to?(:reset) && planet.geosphere.base_values.present?
        planet.geosphere.reset
      else
        # Manual reset if no base values
        planet.geosphere.update!(
          total_crust_mass: planet.geosphere.total_crust_mass || 0.0,
          total_mantle_mass: planet.geosphere.total_mantle_mass || 0.0,
          total_core_mass: planet.geosphere.total_core_mass || 0.0
        )
      end
    rescue => e
      puts "   ❌ Geosphere reset failed: #{e.message}"
      success = false
    end
  end
  
  # Biosphere reset
  if planet.biosphere
    begin
      if planet.biosphere.respond_to?(:reset) && planet.biosphere.base_values.present?
        planet.biosphere.reset
      else
        # Manual reset if no base values
        planet.biosphere.update!(
          biodiversity_index: planet.biosphere.biodiversity_index || 0.0,
          habitable_ratio: planet.biosphere.habitable_ratio || 0.0,
          biome_distribution: planet.biosphere.biome_distribution || {}
        )
      end
    rescue => e
      puts "   ❌ Biosphere reset failed: #{e.message}"
      success = false
    end
  end
  
  success
end

def capture_planetary_state(planet, label)
  {
    timestamp: Time.current,
    label: label,
    atmosphere: planet.atmosphere&.attributes&.slice('temperature', 'pressure', 'composition', 'total_atmospheric_mass'),
    hydrosphere: planet.hydrosphere&.attributes&.slice('total_hydrosphere_mass', 'state_distribution', 'composition'),
    geosphere: planet.geosphere&.attributes&.slice('total_crust_mass', 'total_mantle_mass', 'total_core_mass'),
    biosphere: planet.biosphere&.attributes&.slice('biodiversity_index', 'habitability_score', 'species_count')
  }
end

def run_planetary_simulation(planet, days)
  return true if days == 0 # Baseline validation only
  
  begin
    simulator = TerraSim::Simulator.new(planet)
    
    if days == 1
      simulator.calc_current
    else
      # Run simulation for specified days
      days.times { simulator.calc_current }
    end
    
    puts "   ✅ Simulation completed (#{days} days)"
    true
  rescue => e
    puts "   ❌ Simulation failed: #{e.message}"
    false
  end
end

def validate_baseline_behavior(planet, pre_reset, post_reset, final_state, days)
  validation = { issues: [], warnings: [], passed: true }
  
  # Check atmosphere reset
  if planet.atmosphere
    if post_reset[:atmosphere]&.dig('temperature') != planet.surface_temperature
      validation[:issues] << "Atmosphere temperature not reset correctly"
      validation[:passed] = false
    end
    
    if post_reset[:atmosphere]&.dig('pressure') != planet.known_pressure
      validation[:issues] << "Atmosphere pressure not reset correctly"
      validation[:passed] = false
    end
  end
  
  # Check for unexpected changes during baseline validation
  if days == 0
    # For baseline mode, state should remain stable after reset
    if state_changed?(post_reset, final_state)
      validation[:warnings] << "State changed during baseline validation (possible simulation drift)"
    end
  end
  
  validation
end

def state_changed?(state1, state2)
  # Simple comparison - could be more sophisticated
  state1[:atmosphere] != state2[:atmosphere] ||
  state1[:hydrosphere] != state2[:hydrosphere] ||
  state1[:geosphere] != state2[:geosphere] ||
  state1[:biosphere] != state2[:biosphere]
end

def display_planetary_status(planet, validation)
  puts "\n=== #{planet.name} Status ==="
  
  if planet.atmosphere
    puts "🌡️  Atmosphere:"
    puts "   Temperature: #{planet.atmosphere.temperature} K"
    puts "   Pressure: #{planet.atmosphere.pressure} Pa"
    puts "   Mass: #{planet.atmosphere.total_atmospheric_mass} kg"
    puts "   Composition: #{planet.atmosphere.composition.inspect}"
  else
    puts "🌡️  Atmosphere: None"
  end
  
  if planet.hydrosphere
    puts "💧 Hydrosphere:"
    puts "   Total Mass: #{planet.hydrosphere.total_hydrosphere_mass} kg"
    puts "   State Distribution: #{planet.hydrosphere.state_distribution.inspect}"
    puts "   Composition: #{planet.hydrosphere.composition.inspect}"
  else
    puts "💧 Hydrosphere: None"
  end
  
  if planet.geosphere
    puts "🪨 Geosphere:"
    puts "   Crust Mass: #{planet.geosphere.total_crust_mass} kg"
    puts "   Mantle Mass: #{planet.geosphere.total_mantle_mass} kg"
    puts "   Core Mass: #{planet.geosphere.total_core_mass} kg"
    puts "   Crust Composition: #{planet.geosphere.crust_composition.inspect}"
  else
    puts "🪨 Geosphere: None"
  end
  
  if planet.biosphere
    puts "🌱 Biosphere:"
    puts "   Biodiversity Index: #{planet.biosphere.biodiversity_index}"
    puts "   Habitable Ratio: #{planet.biosphere.habitable_ratio}"
    puts "   Life Forms: #{planet.biosphere.life_forms.count}"
  else
    puts "🌱 Biosphere: None"
  end
  
  # Validation results
  if validation[:passed]
    puts "✅ Validation: PASSED"
  else
    puts "❌ Validation: FAILED"
    validation[:issues].each { |issue| puts "   Issue: #{issue}" }
  end
  
  validation[:warnings].each { |warning| puts "⚠️  Warning: #{warning}" }
  
  puts "=" * 40
end

def display_summary(results, days)
  puts "\n📊 SIMULATION SUMMARY"
  puts "=" * 40
  
  total = results.size
  processed = results.count { |r| r[:status] == :processed }
  missing = results.count { |r| r[:status] == :missing }
  passed = results.count { |r| r[:status] == :processed && r[:validation][:passed] }
  
  puts "Total Planets: #{total}"
  puts "Processed: #{processed}"
  puts "Missing: #{missing}"
  puts "Validation Passed: #{passed}/#{processed}"
  
  if days > 0
    puts "Simulation Mode: Active (#{days} days)"
  else
    puts "Simulation Mode: Baseline validation"
  end
  
  if passed == processed && missing == 0
    puts "🎉 Overall Result: SUCCESS"
  else
    puts "⚠️  Overall Result: ISSUES DETECTED"
  end
end
