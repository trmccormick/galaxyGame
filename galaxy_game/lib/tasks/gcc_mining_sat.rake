# lib/tasks/gcc_mining_sat.rake
require 'json'
require 'yaml'
require 'securerandom'

namespace :orbital_mining do
  desc "Full Production Simulation: CapEx, Initial Reserves, and Fixed Monthly Bond Service"
  task gcc_sat: :environment do
    puts "\n🧹 Cleaning up previous simulation data..."
    # Destroy accounts first
    Organizations::BaseOrganization.where(identifier: ['LDC', 'ASTROLIFT']).each do |org|
      Financial::Account.where(accountable: org).destroy_all
    end
    # Then destroy organizations
    Organizations::BaseOrganization.where(identifier: ['LDC', 'ASTROLIFT']).destroy_all
    Craft::Satellite::BaseSatellite.destroy_all

    puts "\n🚀 Starting Galaxy Game: GCC Mining Satellite Production Integration..."

    # === Configuration ===
    bond_maturity_days = 180
    game_days = (ENV['GAME_DAYS']&.to_i || bond_maturity_days + 1)
    monthly_bond_fixed_payment = 15000.0 # Fixed GCC payment regardless of yield
    project_cost_usd = 31_329_707.2      # Total CapEx recorded as initial debt
    launch_cost_usd = 6613860.0          # AstroLift Launch Fee
    
    game = Game.new
    game_state = game.game_state

    # === 1. Load Manifest & Profile ===
    puts "\n1. Loading mission manifest and profile..."
    manifest_path = GalaxyGame::Paths::JSON_DATA.join('missions', 'gcc_sat_mining_deployment', 'crypto_mining_satellite_01_manifest_v2.json')
    manifest = JSON.parse(File.read(manifest_path))

    profile_path = GalaxyGame::Paths::JSON_DATA.join('missions', 'gcc_sat_mining_deployment', 'gcc_mining_satellite_01_profile_v1.json')
    profile = JSON.parse(File.read(profile_path))

    # Load operational data
    satellite_data_path = GalaxyGame::Paths::JSON_DATA.join('operational_data', 'crafts', 'space', 'satellites', 'crypto_mining_satellite_data.json')
    satellite_data = JSON.parse(File.read(satellite_data_path))

    # Load global cryptocurrency mining parameters
    economic_config = YAML.load_file(Rails.root.join('config', 'economic_parameters.yml'))
    gcc_mining_config = economic_config['cryptocurrency']['gcc_mining']
    halving_period_days = gcc_mining_config['halving_interval_days']
    max_gcc_supply = gcc_mining_config['max_supply'].to_f

    # Initialize lookup services
    unit_lookup = Lookup::UnitLookupService.new
    rig_lookup = Lookup::RigLookupService.new

    # === 2. Setup Context & NPCs ===
    puts "\n2. Setting up NPCs and initial capitalization..."
    earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_or_create_by!(identifier: 'EARTH-01') do |p|
      p.name = "Earth"; p.mass = 5.972e24; p.gravity = 9.807; p.size = 6_371_000.0
    end

    orbit_location = Location::CelestialLocation.find_or_create_by(coordinates: "0.00°N 0.00°E", celestial_body: earth) do |loc|
      loc.name = "Planetary Orbit"
    end

    ldc = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') { |o| o.name = 'LDC'; o.organization_type = :corporation }
    astrolift = Organizations::BaseOrganization.find_or_create_by!(identifier: 'ASTROLIFT') { |o| o.name = 'AstroLift'; o.organization_type = :corporation }

    gcc = Financial::Currency.find_by!(symbol: 'GCC')
    usd = Financial::Currency.find_by!(symbol: 'USD')

    ldc_gcc = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: gcc)
    ldc_usd = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: usd)
    astro_gcc = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: gcc)
    astro_usd = Financial::Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: usd)

    # --- Initial Reserves & CapEx Imbalance ---
    ldc_usd.deposit(50_000_000.0, "Series A Startup Capital") if ldc_usd.balance == 0
    astro_usd.deposit(25_000_000.0, "Logistics Reserves") if astro_usd.balance == 0
    
    # Starting GCC (Terrestrial Mining)
    ldc_gcc.update(balance: 50_000_000.0)
    
    # Record the massive project debt on the USD ledger
    # Note: NPCs are allowed to have negative balances to represent long-term debt
    ldc_usd.withdraw(project_cost_usd, "Initial CapEx: Satellite Construction & Launch")

    # FIX: Reload to ensure Step 4 sees the deposited funds
    ldc_usd.reload
    astro_usd.reload
    ldc_gcc.reload

    # === 3. Build Satellite ===
    puts "\n3. Building satellite and installing hardware..."
    satellite = Manufacturing::CraftFactory.build_from_blueprint(
      blueprint_id: manifest.dig("craft", "blueprint_id") || "generic_satellite",
      variant_data: manifest["variant_data"], 
      owner: ldc, 
      location: orbit_location
    )
    satellite.update(operational_data: satellite_data)

    # Install recommended fit
    operational_data = satellite.operational_data
    if operational_data['recommended_fit']
      # Install units
      operational_data['recommended_fit']['units'].each do |unit_hash|
        unit_id = unit_hash['id']
        count = unit_hash['count'] || 1
        unit_data = unit_lookup.find_unit(unit_id)
        if unit_data
          puts "  - Installing #{count}x #{unit_id}"
          count.times do |i|
            merged_data = unit_data.dup
            case unit_id
            when 'solar_panel'
              merged_data['power'] ||= {}
              merged_data['power']['generation_kw'] = 1000.0
            when 'advanced_computer'
              merged_data['mining'] ||= {}
              merged_data['mining']['hash_rate'] = 80.0
              merged_data['mining']['efficiency'] = 1.0
              merged_data['power'] ||= {}
              merged_data['power']['consumption_kw'] = 100.0
            when 'basic_ion_thruster'
              merged_data['power'] ||= {}
              merged_data['power']['consumption_kw'] = 50.0
            when 'fuel_tank_s'
              merged_data['fuel'] ||= {}
              merged_data['fuel']['xenon'] ||= {}
              merged_data['fuel']['xenon']['capacity'] = 1000.0
              merged_data['fuel']['xenon']['current'] = 500.0
            when 'satellite_battery'
              merged_data['power'] ||= {}
              merged_data['power']['capacity_kwh'] = 2000.0
              merged_data['power']['current_kwh'] = 1500.0
            end
            ::Units::BaseUnit.create!(
              identifier: "#{unit_id}_#{i}_#{SecureRandom.hex(4)}",
              name: "#{unit_id} #{i+1}",
              unit_type: unit_id,
              attachable: satellite,
              owner: ldc,
              operational_data: merged_data
            )
          end
        else
          puts "  ❌ Unit data not found for #{unit_id}"
        end
      end

      # Install rigs
      operational_data['active_rig_effects'] ||= []
      operational_data['recommended_fit']['rigs'].each do |rig_hash|
        rig_id = rig_hash['id']
        count = rig_hash['count'] || 1
        rig_data = rig_lookup.find_rig(rig_id)
        if rig_data
          puts "  - Installing #{count}x #{rig_id}"
          count.times do |i|
            merged_data = rig_data.dup
            case rig_id
            when 'gpu_coprocessor_rig'
              merged_data['power'] ||= {}
              merged_data['power']['consumption_kw'] = 15.0
              # Do not override effects, let JSON effects apply
              merged_data['mining'] ||= {}
              # Remove bonus override to let effects handle mining boost
            end
            rig = ::Rigs::BaseRig.new(
              identifier: "#{rig_id}_#{i}_#{SecureRandom.hex(4)}",
              name: "#{rig_id} #{i+1}",
              description: "GPU Co-Processor Rig for mining acceleration",
              rig_type: rig_id,
              capacity: merged_data['capacity'] || 100,
              operational_data: merged_data
            )
            rig.apply_to(satellite)
            rig.save!
            # Add rig effects to satellite's active_rig_effects
            if merged_data['effects']
              operational_data['active_rig_effects'] << { 'effects' => merged_data['effects'] }
            end
          end
        else
          puts "  ❌ Rig data not found for #{rig_id}"
        end
      end

      # Install modules (treated as units) - commented out as data not found
      # operational_data['recommended_fit']['modules'].each do |mod_hash|
      #   mod_id = mod_hash['id']
      #   count = mod_hash['count'] || 1
      #   mod_data = unit_lookup.find_unit(mod_id)
      #   if mod_data
      #     puts "  - Installing #{count}x #{mod_id} (module)"
      #     count.times do |i|
      #       ::Units::BaseUnit.create!(
      #         identifier: "#{mod_id}_#{i}_#{SecureRandom.hex(4)}",
      #         name: "#{mod_id} #{i+1}",
      #         unit_type: mod_id,
      #         attachable: satellite,
      #         owner: ldc,
      #         operational_data: mod_data
      #       )
      #     end
      #   else
      #     puts "  ❌ Module data not found for #{mod_id}"
      #   end
      # end
    end

    # Sync power grid
    satellite.base_units.reload
    satellite.base_rigs.reload
    satellite.instance_variable_set(:@power_grid, nil)
    satellite.deploy('orbital', celestial_body: earth)
    satellite.save!

    # === 4. Launch Payment ===
    puts "\n4. Processing launch costs..."
    ldc_usd.transfer_funds(launch_cost_usd, astro_usd, "Launch Payment")
    puts "✅ LDC paid #{launch_cost_usd} USD to AstroLift."

    # === 5. Simulation Loop (Monthly Fixed Payments) ===
    puts "\n5. Simulating #{game_days} days with Monthly Bond Payments..."
    
    total_mined = 0.0
    
    game_days.times do |day|
      game.advance_by_days(1)
      current_day_in_cycle = (day + 1) % 30
      
      # Daily Mining with halving events and supply cap
      base_mined = satellite.mine_gcc
      
      # Apply halving events (similar to Bitcoin)
      halvings = (day / halving_period_days).floor
      mining_multiplier = 0.5 ** halvings
      
      mined_today = base_mined * mining_multiplier
      total_mined += mined_today
      
      # Check supply cap (withdraw excess if needed)
      current_balance = ldc_gcc.reload.balance
      if current_balance > max_gcc_supply
        excess = current_balance - max_gcc_supply
        ldc_gcc.withdraw(excess, "GCC Supply Cap Enforcement")
        mined_today -= excess
      end
      
      # Power and Mining Status (Daily summary for first few days, then weekly)
      if (day + 1) <= 7 || (day + 1) % 7 == 0
        power_gen = satellite.power_generation
        power_use = satellite.power_usage
        power_balance = power_gen - power_use
        mining_units = satellite.mining_units.count
        rigs = operational_data['recommended_fit']['rigs'].sum { |r| r['count'] }
        
        puts "📅 Day #{day + 1}: Mined: #{mined_today.round(1)} GCC (x#{mining_multiplier}) | Power: #{power_balance.round(1)} kW | Mining Units: #{mining_units} | Rigs: #{rigs} | LDC Bal: #{ldc_gcc.reload.balance.to_f.round(1)}"
      end

      # Fixed Monthly Bond Service (Real GCC transfer)
      if current_day_in_cycle == 0
        puts "  🏛️ Settlement Date (Day #{day + 1}): Processing Bond Payment..."
        ldc_gcc.transfer_funds(monthly_bond_fixed_payment, astro_gcc, "Fixed Monthly Bond Payment")
        puts "  ✅ Paid #{monthly_bond_fixed_payment} GCC to AstroLift."
      end

      # Progress Logging (Monthly summary)
      if (day + 1) % 30 == 0
        puts "📊 Summary Day #{day + 1}: LDC: #{ldc_gcc.reload.balance.to_f.round(1)} | AstroLift: #{astro_gcc.reload.balance.to_f.round(1)} GCC"
      end
    end

    final_halvings = (game_days / halving_period_days).floor

    puts "\n=== FINAL VERIFICATION ==="
    puts "AstroLift GCC Account: #{astro_gcc.reload.balance.to_f} (Income Realized)"
    puts "LDC GCC Account: #{ldc_gcc.reload.balance.to_f} (Remaining CapEx Debt)"
    puts "AstroLift USD Account: #{astro_usd.reload.balance.to_f} (Launch Revenue)"
    puts "LDC USD Account: #{ldc_usd.reload.balance.to_f} (Remaining Capital)"
    puts "Total GCC Mined: #{total_mined.round(1)} (with #{final_halvings} halvings applied)"
    puts "GCC Supply Cap: #{max_gcc_supply} (#{((ldc_gcc.balance / max_gcc_supply) * 100).round(2)}% utilized)"
    puts "🏁 Simulation Complete."
  end
end