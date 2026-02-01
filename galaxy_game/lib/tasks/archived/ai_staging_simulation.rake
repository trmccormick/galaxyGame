namespace :ai do
  desc "Simulate AI Manager staging plan starting with Luna build, then expanding to Mars/Venus"
  task staging_simulation: :environment do
    begin
      puts "Starting AI Staging Simulation (Luna-first approach)..."

      # Database reset for clean simulation
      if Rails.env.development?
        puts "Resetting database for clean simulation..."
        begin
          Rake::Task['db:drop'].invoke
        rescue
          puts "DB drop failed (may not exist), continuing..."
        end
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['db:seed'].invoke
        puts "Database reset and seeded."
      end

      # Phase 1: Luna Build and Cislunar Setup
      puts "Phase 1: Building Luna Base and Cislunar Infrastructure..."
      Rake::Task['infrastructure:cislunar_setup'].invoke  # Initialize L1/station/depot
      Rake::Task['ai:sol:build_system'].invoke  # AI-driven Sol system build, including Luna
      luna_failures = check_luna_failures

      # Verification after Luna build
      puts "=== VERIFICATION AFTER LUNA BUILD ==="
      verify_setup

      puts "Luna build complete. Stopping for manual verification."
      # Stop here - comment out phases 2-4 for now
      # Phase 2: Expand to Mars
      # puts "Phase 2: Expanding to Mars..."
      # Rake::Task['mars:simulate'].invoke
      # mars_failures = check_mars_failures

      # Phase 3: Expand to Venus
      # puts "Phase 3: Expanding to Venus..."
      # Rake::Task['venus:simulate'].invoke
      # venus_failures = check_venus_failures

      # Phase 4: Solar System Progression
      # puts "Phase 4: Solar System Progression..."
      # Rake::Task['missions:solar_system:simple_progression'].invoke
      # progression_failures = check_progression_failures

      # Summary
      # total_failures = luna_failures + mars_failures + venus_failures + progression_failures
      puts "Simulation Complete (Luna only). Total Failures: #{luna_failures}"

    rescue => e
      puts "Simulation Failed: #{e.message}"
      puts e.backtrace
    end
  end

  # Helper methods
  def check_luna_failures
    puts "Checking Luna setup failures..."
    # Implement: Check for L1/station/depot existence, ISRU production
    0
  end

  def check_mars_failures
    puts "Checking Mars failures..."
    0
  end

  def check_venus_failures
    puts "Checking Venus failures..."
    0
  end

  def check_progression_failures
    puts "Checking progression failures..."
    0
  end

  def log_failures(count)
    puts "Logged #{count} failures."
  end

  def verify_setup
    puts "=== ORGANIZATION SETUP ==="
    ldc = Organizations::BaseOrganization.find_by(name: 'Lunar Development Corporation')
    astrolift = Organizations::BaseOrganization.find_by(name: 'AstroLift')
    zenith = Organizations::BaseOrganization.find_by(name: 'Zenith Orbital')
    vector = Organizations::BaseOrganization.find_by(name: 'Vector Hauling')

    puts "LDC: #{ldc&.operational_data.inspect}"
    puts "AstroLift: #{astrolift&.operational_data.inspect}"
    puts "Zenith: #{zenith&.operational_data.inspect}"
    puts "Vector: #{vector&.operational_data.inspect}"

    puts "\n=== MARKET LISTINGS ==="
    # Check for commodities and contracts
    begin
      commodities = Financial::Commodity.where("name LIKE ?", "%regolith%").or(Financial::Commodity.where("name LIKE ?", "%fuel%"))
      puts "Commodities: #{commodities.pluck(:name, :price_gcc).to_h}"
    rescue NameError
      puts "Commodities: Not implemented yet (Financial::Commodity model missing)"
    end

    puts "\n=== CONTRACTS AND MISSIONS ==="
    contracts = SupplyChain::Contract.limit(10)
    puts "Recent Contracts: #{contracts.count}"
    contracts.each do |c|
      puts "  #{c.description} - #{c.status}"
    end

    puts "\n=== CELESTIAL BODIES ==="
    luna = CelestialBodies::CelestialBody.find_by(name: 'Luna')
    earth = CelestialBodies::CelestialBody.find_by(name: 'Earth')
    puts "Luna exists: #{luna.present?}"
    puts "Earth exists: #{earth.present?}"

    puts "\n=== SETTLEMENTS ==="
    settlements = Locations::Settlement.limit(5)
    puts "Settlements: #{settlements.pluck(:name, :celestial_body_id)}"

    puts "\n=== CRAFT AND MISSIONS ==="
    # Check for skimmer craft or other vehicles
    craft = Operational::Craft.limit(5)
    puts "Craft: #{craft.pluck(:name, :status)}"

    missions = Missions::Mission.limit(5)
    puts "Missions: #{missions.pluck(:name, :status)}"

    puts "\n=== RESUPPLY CHECK ==="
    # Check for any resupply missions from Earth
    resupply_missions = Missions::Mission.where("description LIKE ?", "%resupply%").or(Missions::Mission.where("description LIKE ?", "%supply%"))
    puts "Resupply missions: #{resupply_missions.count}"
    resupply_missions.each do |m|
      puts "  #{m.name}: #{m.description}"
    end

    puts "\n=== IMPORTED SUPPLIES ==="
    # Check supply chain records
    supplies = SupplyChain::SupplyRecord.limit(10)
    puts "Supply records: #{supplies.count}"
    total_imported = supplies.sum(:quantity)
    puts "Total supplies imported: #{total_imported}"

    puts "\n=== SKIMMER CRAFT STATUS ==="
    skimmers = Operational::Craft.where("name LIKE ?", "%skimmer%")
    puts "Skimmer craft: #{skimmers.count}"
    skimmers.each do |s|
      puts "  #{s.name}: #{s.status} - Deployed: #{s.deployed_at.present?}"
    end
  end
end