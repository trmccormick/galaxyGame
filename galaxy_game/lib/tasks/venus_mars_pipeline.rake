require_relative '../../app/services/ai_manager/terraforming_manager'

namespace :venus_mars do
  desc "Simulate Venus-to-Mars terraforming pipeline (REFACTORED)"
  task pipeline_v2: :environment do
    puts "\n=== Venus-to-Mars Terraforming Pipeline (REFACTORED) ==="
    
    # Load celestial bodies
    venus = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_by(name: "Venus")
    mars = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_by(name: "Mars")
    titan = CelestialBodies::Satellites::Moon.find_by(name: "Titan")
    saturn = CelestialBodies::Planets::Gaseous::GasGiant.find_by(name: "Saturn")
    
    raise "Required bodies not found" unless [venus, mars, titan, saturn].all?

    # Simulation parameters
    years = 10_000
    days_per_year = 365
    total_days = years * days_per_year
    synodic_period = 584 # Venus-Mars transfer window
    titan_period = 3650 # Titan transfer window
    
    magnetosphere_deployment_years = 50
    magnetosphere_escape_reduction = 0.95
    
    base_cycler_capacity = 1.0e13
    max_cyclers = 1000
    max_new_cyclers_per_year = 20
    transport_loss = 0.02
    co2_to_o2_efficiency = 0.95

    # Reset all bodies
    puts "\nResetting all spheres to baseline..."
    [venus, mars, titan].each do |body|
      body.atmosphere&.reset if body.atmosphere&.respond_to?(:reset)
      body.hydrosphere&.reset if body.hydrosphere&.respond_to?(:reset)
      body.geosphere&.reset if body.geosphere&.respond_to?(:reset)
      body.biosphere&.reset if body.biosphere&.respond_to?(:reset)
    end

    # Initialize TerraformingManager
    terraforming_manager = AIManager::TerraformingManager.new(
      worlds: { mars: mars, venus: venus, titan: titan, saturn: saturn },
      simulation_params: {
        safe_o2_threshold: 22.0,
        target_ch4_pct: 1.0,
        target_n2_pct: 70.0,
        target_o2_pct: 18.0,
        target_co2_pct: 0.04,
        target_total_pressure_bar: 0.81,
        mars_liquid_water_threshold: 1.0,
        cycler_capacity: base_cycler_capacity,
        titan_capacity: base_cycler_capacity
      }
    )

    puts "\nSimulation Parameters:"
    puts "- Duration: #{years} years"
    puts "- Magnetosphere Shield: Deployment Years 0-#{magnetosphere_deployment_years}"
    puts "- Cycler Capacity: #{format_mass(base_cycler_capacity)} per trip"
    puts "- Max Cyclers: #{max_cyclers}"

    print_planet_status(venus)
    print_planet_status(mars)
    print_planet_status(titan)

    # Simulation state
    current_day = 0
    current_year = 0
    cyclers = 1
    magnetosphere_active = false
    trips_completed = 0

    # Main simulation loop
    while current_day < total_days
      # Yearly updates
      if (current_day % days_per_year).zero?
        current_year = current_day / days_per_year
        
        # Activate magnetosphere
        if current_year == magnetosphere_deployment_years
          magnetosphere_active = true
          puts "\n#{'='*70}"
          puts "🛡️  MAGNETOSPHERE SHIELD ACTIVATED"
          puts "#{'='*70}\n"
        end
        
        # Run TerraSim for 1 year of atmospheric evolution
        fresh_mars = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find(mars.id)
        TerraSim::Simulator.new(fresh_mars, magnetosphere_active: magnetosphere_active).calc_current(365)
        mars.reload
        
        # Print status every 10 years
        if (current_year % 10).zero? || current_year == years
          puts "\nYear #{current_year}:"
          puts "  [Magnetosphere: #{magnetosphere_active ? 'ACTIVE' : 'DEPLOYING'}]"
          print_planet_status(venus)
          print_planet_status(mars)
          print_planet_status(titan)
        end
        
        # Update cycler fleet
        cyclers = [1 + [current_year * max_new_cyclers_per_year, max_cyclers].min, max_cyclers].min
      end

      # Venus transfer window (every synodic_period days, after magnetosphere active)
      if (current_day % synodic_period).zero? && magnetosphere_active
        print_transfer = (current_year % 100).zero? || current_year == years

        puts "\n--- Day #{current_day} (Year #{current_year}): Transfer Window ---" if print_transfer

        # Check terraforming phase
        phase = terraforming_manager.determine_terraforming_phase(:mars)
        gas_needs = terraforming_manager.calculate_gas_needs(:mars)

        if phase == :warming
          puts "  [WARMING PHASE] Building CO2 greenhouse (#{(mars.atmosphere.pressure / terraforming_manager.simulation_params[:target_total_pressure_bar] * 100).round(1)}% of target)" if print_transfer
          
          # Check if we need more gas (stops at 60% of target pressure to leave room for selective tuning)
          if gas_needs[:gases_needed].any? && cyclers > 0
            # Raw transfer from Venus
            transfer_service = TerraSim::AtmosphericTransferService.new(venus, mars, mode: :raw)
            result = transfer_service.transfer_atmosphere(
              capacity: cyclers * base_cycler_capacity,
              efficiency: 1 - transport_loss
            )
            trips_completed += 1
            
            if print_transfer || trips_completed <= 5
              puts "  Transferred: #{format_gases(result[:gases_delivered])}"
            end
          elsif print_transfer
            puts "  [WARMING] Reached 60% target pressure (#{mars.atmosphere.pressure.round(3)} bar), stopping raw imports to allow selective tuning"
          end
        elsif phase == :maintenance
          # Seed biosphere if conditions met
          if terraforming_manager.should_seed_biosphere?(:mars)
            terraforming_manager.seed_biosphere(:mars)
            puts "  ✓ Seeded biosphere with #{mars.biosphere.life_forms.count} species"
          end

          # Check what gases are needed
          if gas_needs[:gases_needed].any?
            puts "  [MAINTENANCE PHASE] Tuning composition" if print_transfer
            
            # Processed transfer from Venus (N2 + O2 from MOXIE)
            if cyclers > 0
              transfer_service = TerraSim::AtmosphericTransferService.new(venus, mars, mode: :processed)
              result = transfer_service.transfer_atmosphere(
                capacity: cyclers * base_cycler_capacity,
                co2_ratio: 0.8,
                n2_ratio: 0.2,
                processing_efficiency: co2_to_o2_efficiency,
                efficiency: 1 - transport_loss
              )
              trips_completed += 1
              
              puts "  Transferred: #{format_gases(result[:gases_delivered])}" if print_transfer
            end
          end

          # Manage O2 levels
          if terraforming_manager.manage_oxygen_levels(:mars)
            result = terraforming_manager.execute_o2_management(:mars)
            if result && print_transfer
              puts "  [O2 Management] Used #{format_mass(result[:h2_consumed])} H2, removed #{format_mass(result[:o2_consumed])} O2"
            end
          end
        end

        # H2 imports for reactions
        h2_plan = terraforming_manager.plan_h2_imports(:mars)
        if h2_plan
          imported = terraforming_manager.import_h2_from_gas_giant(:saturn, :mars, h2_plan[:total_h2_needed])
          puts "  Imported #{format_mass(imported)} H2 from Saturn" if imported && print_transfer
        end

        # Methane synthesis if needed
        ch4_plan = terraforming_manager.calculate_methane_needs(:mars)
        if ch4_plan
          result = terraforming_manager.synthesize_methane(:mars, :venus)
          if result && print_transfer
            puts "  [Sabatier] Synthesized #{format_mass(result[:ch4_produced])} CH4"
          end
        end
      end

      # Titan transfer window (if CH4 needed)
      if (current_day % titan_period).zero? && magnetosphere_active
        ch4_plan = terraforming_manager.calculate_methane_needs(:mars)
        
        if ch4_plan && titan.atmosphere.pressure >= 1.3
          transfer_service = TerraSim::AtmosphericTransferService.new(titan, mars, mode: :raw)
          result = transfer_service.transfer_atmosphere(
            capacity: base_cycler_capacity,
            efficiency: 1 - transport_loss
          )
          
          puts "  [Titan] Delivered: #{format_gases(result[:gases_delivered])}"
        end
      end

      current_day += 1
    end

    # Final report
    puts "\n#{'='*70}"
    puts "=== FINAL STATUS ==="
    puts "#{'='*70}"
    
    mars.reload
    print_detailed_status(mars, "MARS")
    print_detailed_status(venus, "VENUS")
    print_detailed_status(titan, "TITAN")
    
    puts "\n✓ Simulation complete"
  end

  # Helper methods
  def format_mass(mass)
    if mass >= 1.0e15
      "#{(mass / 1.0e15).round(2)} Pt"
    elsif mass >= 1.0e12
      "#{(mass / 1.0e12).round(2)} Tt"
    elsif mass >= 1.0e9
      "#{(mass / 1.0e9).round(2)} Gt"
    else
      "#{mass.round(2)} kg"
    end
  end

  def format_gases(gases_hash)
    gases_hash.map { |k, v| "#{k}=#{format_mass(v)}" }.join(", ")
  end

  def get_gas_pct(planet, gas_name)
    gas = planet.atmosphere.gases.find_by(name: gas_name)
    gas&.percentage || 0.0
  end

  def print_planet_status(planet)
    puts "  #{planet.name}:"
    puts "    Pressure: #{planet.atmosphere.pressure.round(6)} bar"
    planet.atmosphere.gases.order(percentage: :desc).limit(4).each do |gas|
      puts "      • #{gas.name}: #{gas.percentage.round(4)}%"
    end
  end

  def print_detailed_status(planet, label)
    puts "\n[#{label}]"
    atm = planet.atmosphere
    
    if atm
      puts "  Pressure: #{atm.pressure.round(6)} bar"
      puts "  Temperature: #{planet.surface_temperature.round(2)} K"
      puts "  Major Gases:"
      atm.gases.order(percentage: :desc).each do |gas|
        puts "    • #{gas.name}: #{gas.percentage.round(4)}%" if gas.percentage >= 0.01
      end
    end

    if planet.hydrosphere
      puts "  Hydrosphere: #{format_mass(planet.hydrosphere.total_hydrosphere_mass)}"
      puts "    State: #{planet.hydrosphere.state_distribution.inspect}"
    end

    if planet.biosphere
      puts "  Biosphere:"
      puts "    Habitability: #{(planet.biosphere.habitable_ratio * 100).round(2)}%"
      puts "    Species: #{planet.biosphere.life_forms.count}"
    end
  end
end