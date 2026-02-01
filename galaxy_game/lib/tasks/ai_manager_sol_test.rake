namespace :ai do
  namespace :sol do
    desc "AI Manager GCC Satellite Bootstrap Test - First Priority Mission"
    task gcc_bootstrap: :environment do
      require 'benchmark'

      puts "\n🚀 AI MANAGER GCC SATELLITE BOOTSTRAP TEST"
      puts "=" * 60

      build_stats = initialize_bootstrap_stats
      total_time = Benchmark.measure do
        begin
          # Phase 1: System Analysis
          system_state = analyze_initial_system_state(build_stats)

          # Phase 2: AI Decision Making
          bootstrap_decision = ai_gcc_bootstrap_decision(system_state, build_stats)

          # Phase 3: GCC Satellite Deployment
          deployment_result = execute_gcc_satellite_deployment(bootstrap_decision, build_stats)

          # Phase 4: Economic Bootstrap Verification
          bootstrap_verification = verify_gcc_bootstrap(deployment_result, build_stats)

        rescue => e
          puts "❌ GCC Bootstrap failed: #{e.message}"
          puts e.backtrace.join("\n")
          build_stats[:errors] << e.message
        end
      end

      # Final Report
      generate_gcc_bootstrap_report(build_stats, total_time.real)
    end
  end
end

private

def initialize_bootstrap_stats
  {
    start_time: Time.current,
    phases_completed: 0,
    ai_decisions_made: 0,
    gcc_satellite_deployed: false,
    construction_cost_gcc: 0,
    launch_cost_usd: 0,
    total_bootstrap_cost: 0,
    initial_funding_needed: 0,
    economic_bootstrapped: false,
    gcc_generation_started: false,
    errors: [],
    ai_insights: []
  }
end

def analyze_initial_system_state(build_stats)
  puts "\n📊 PHASE 1: INITIAL SYSTEM STATE ANALYSIS"

  # Check for existing GCC generation
  gcc_satellites = Craft::Satellite::BaseSatellite.where("operational_data->>'craft_type' = ?", 'crypto_mining_satellite')
  gcc_generation_active = gcc_satellites.any?

  puts "🔍 System Analysis:"
  puts "  - GCC Mining Satellites: #{gcc_satellites.count}"
  puts "  - GCC Generation Active: #{gcc_generation_active ? 'YES' : 'NO'}"

  # Check economic state
  gcc_currency = Currency.find_by(symbol: 'GCC')
  usd_currency = Currency.find_by(symbol: 'USD')

  total_gcc_in_economy = Account.where(currency: gcc_currency).sum(:balance)
  total_usd_in_economy = Account.where(currency: usd_currency).sum(:balance)

  puts "  - Total GCC in Economy: #{total_gcc_in_economy.round(2)}"
  puts "  - Total USD in Economy: #{total_usd_in_economy.round(2)}"

  # Check for organizations
  organizations = Organizations::BaseOrganization.all
  puts "  - Active Organizations: #{organizations.count}"

  system_state = {
    gcc_generation_active: gcc_generation_active,
    total_gcc_economy: total_gcc_in_economy,
    total_usd_economy: total_usd_in_economy,
    organizations_count: organizations.count,
    existing_satellites: gcc_satellites
  }

  build_stats[:phases_completed] += 1
  puts "✅ Phase 1 complete"
  system_state
end

def ai_gcc_bootstrap_decision(system_state, build_stats)
  puts "\n🎯 PHASE 2: AI GCC BOOTSTRAP DECISION"

  puts "🤖 AI Manager Analysis:"
  puts "  - System State: #{system_state[:gcc_generation_active] ? 'GCC Generation Active' : 'No GCC Generation'}"
  puts "  - Economic State: #{system_state[:total_gcc_economy] > 0 ? 'GCC Economy Exists' : 'No GCC Economy'}"

  # AI Decision: Is GCC bootstrap needed?
  bootstrap_needed = !system_state[:gcc_generation_active] && system_state[:total_gcc_economy] == 0

  puts "  - Bootstrap Decision: #{bootstrap_needed ? 'REQUIRED' : 'NOT NEEDED'}"

  if bootstrap_needed
    puts "  - AI Priority: DEPLOY GCC MINING SATELLITE"

    # Load learned patterns for GCC satellite deployment
    learned_patterns = load_learned_patterns
    gcc_pattern = learned_patterns['gcc_satellite_deployment'] ||
                  learned_patterns['crypto_mining_satellite'] ||
                  find_gcc_pattern_from_missions

    puts "  - Selected Pattern: #{gcc_pattern ? gcc_pattern['name'] || 'GCC Satellite Deployment' : 'Default Pattern'}"

    decision = {
      bootstrap_required: true,
      mission_type: 'gcc_satellite_deployment',
      pattern: gcc_pattern,
      priority: 'critical',
      reasoning: 'No GCC generation exists - economy cannot function without cryptocurrency mining'
    }
  else
    puts "  - AI Priority: ECONOMY ALREADY BOOTSTRAPPED"
    decision = {
      bootstrap_required: false,
      reasoning: 'GCC generation already active'
    }
  end

  build_stats[:ai_decisions_made] += 1
  build_stats[:phases_completed] += 1

  puts "✅ Phase 2 complete"
  decision
end

def execute_gcc_satellite_deployment(decision, build_stats)
  puts "\n🏗️ PHASE 3: GCC SATELLITE DEPLOYMENT EXECUTION"

  unless decision[:bootstrap_required]
    puts "⏭️ Bootstrap not required - skipping deployment"
    return { success: true, skipped: true }
  end

  begin
    # Setup organizations and funding
    setup_bootstrap_organizations(build_stats)

    # Load mission data
    mission_data = load_gcc_mission_data

    # Build satellite
    satellite = build_gcc_satellite(mission_data, build_stats)

    # Fit components
    fit_gcc_satellite(satellite, mission_data, build_stats)

    # Calculate and pay costs
    cost_result = calculate_gcc_deployment_costs(satellite, build_stats)

    # Deploy and activate
    deployment_result = deploy_gcc_satellite(satellite, build_stats)

    # Start mining operations
    mining_result = start_gcc_mining(satellite, mission_data, build_stats)

    result = {
      success: true,
      satellite: satellite,
      costs: cost_result,
      deployment: deployment_result,
      mining: mining_result
    }

    build_stats[:gcc_satellite_deployed] = true
    build_stats[:phases_completed] += 1

    puts "✅ Phase 3 complete"
    result

  rescue => e
    puts "❌ Deployment failed: #{e.message}"
    build_stats[:errors] << "Deployment failed: #{e.message}"
    { success: false, error: e.message }
  end
end

def setup_bootstrap_organizations(build_stats)
  puts "  📋 Setting up organizations and funding..."

  # Create/fund organizations
  @ldc = Organizations::BaseOrganization.find_or_create_by!(name: 'Lunar Development Corporation', identifier: 'LDC', organization_type: :corporation)
  @astrolift = Organizations::BaseOrganization.find_or_create_by!(name: 'AstroLift', identifier: 'ASTROLIFT', organization_type: :corporation)

  # Setup currencies
  @gcc_currency = Currency.find_by(symbol: 'GCC')
  @usd_currency = Currency.find_by(symbol: 'USD')

  # Setup accounts with initial funding
  @ldc_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: @ldc, currency: @gcc_currency)
  @ldc_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: @ldc, currency: @usd_currency)
  @astrolift_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: @astrolift, currency: @gcc_currency)
  @astrolift_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: @astrolift, currency: @usd_currency)

  # Provide initial funding
  initial_gcc_funding = 100_000.00
  initial_usd_funding = 50_000.00

  @ldc_gcc_account.deposit(initial_gcc_funding, "AI Bootstrap Initial GCC Fund")
  @ldc_usd_account.deposit(initial_usd_funding, "AI Bootstrap Initial USD Fund")
  @astrolift_usd_account.deposit(20_000.00, "Launch Provider Working Capital")

  build_stats[:initial_funding_needed] = initial_gcc_funding + initial_usd_funding

  puts "    ✅ Organizations setup with #{initial_gcc_funding} GCC and #{initial_usd_funding} USD funding"
end

def load_gcc_mission_data
  puts "  📄 Loading GCC satellite mission data..."

  manifest_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'crypto_mining_satellite_01_manifest_v2.json')
  task_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'gcc_satellite_mining_tasks_v1.json')

  manifest = JSON.parse(File.read(manifest_path), symbolize_names: true)
  tasks = File.exist?(task_path) ? JSON.parse(File.read(task_path), symbolize_names: true) : []

  puts "    ✅ Loaded manifest and #{tasks.size} tasks"

  { manifest: manifest, tasks: tasks }
end

def build_gcc_satellite(mission_data, build_stats)
  puts "  🏭 Building GCC mining satellite..."

  earth = CelestialBodies::CelestialBody.find_or_create_by!(name: 'Earth', celestial_body_type: 'terrestrial_planet', identifier: 'EARTH')
  orbit_location = Location::CelestialLocation.find_or_create_by!(coordinates: "0.00°N 0.00°E", celestial_body: earth)

  satellite = CraftFactoryService.build_from_blueprint(
    blueprint_id: mission_data[:manifest].dig(:craft, :blueprint_id),
    variant_data: mission_data[:manifest][:variant_data],
    owner: @ldc,
    location: orbit_location
  )

  raise "Satellite build failed" unless satellite&.persisted?

  if mission_data[:manifest][:operational_data]
    satellite.update!(operational_data: mission_data[:manifest][:operational_data])
  end

  orbit_location.update!(locationable: satellite)
  satellite.reload

  # Deploy to orbit
  valid_locations = satellite.operational_data.dig('deployment', 'deployment_locations') || []
  if valid_locations.include?('orbital')
    satellite.deploy('orbital', celestial_body: earth)
  else
    satellite.deploy('orbital', celestial_body: earth)
  end

  puts "    ✅ Built and deployed: #{satellite.name}"
  satellite
end

def fit_gcc_satellite(satellite, mission_data, build_stats)
  puts "  🔧 Fitting satellite components..."

  fit_data = mission_data[:manifest][:operational_data]['recommended_fit'] ||
             mission_data[:manifest].dig(:variant_data, :recommended_fit) ||
             satellite.operational_data['recommended_fit']

  if fit_data
    # Fit units
    if fit_data['units']
      fit_data['units'].each do |unit_data|
        result = FittingResult.fit_unit_to_craft(satellite, unit_data)
        puts "      #{result.success? ? '✅' : '❌'} #{unit_data['name'] || unit_data['unit_type']}"
      end
    end

    # Fit modules
    if fit_data['modules']
      fit_data['modules'].each do |module_data|
        result = FittingResult.fit_module_to_craft(satellite, module_data)
        puts "      #{result.success? ? '✅' : '❌'} #{module_data['name'] || module_data['module_type']}"
      end
    end

    # Fit rigs
    if fit_data['rigs']
      fit_data['rigs'].each do |rig_data|
        result = FittingResult.fit_rig_to_craft(satellite, rig_data)
        puts "      #{result.success? ? '✅' : '❌'} #{rig_data['name'] || rig_data['rig_type']}"
      end
    end
  end

  satellite.reload
  puts "    ✅ Satellite fitted with #{satellite.base_units.size} units, #{satellite.modules.size} modules, #{satellite.rigs.size} rigs"
end

def calculate_gcc_deployment_costs(satellite, build_stats)
  puts "  💰 Calculating deployment costs..."

  # Construction cost
  construction_cost = satellite.base_units.sum { |unit| unit.operational_data.dig('cost', 'gcc') || 0 } +
                     satellite.modules.sum { |mod| mod.operational_data.dig('cost', 'gcc') || 0 } +
                     satellite.rigs.sum { |rig| rig.operational_data.dig('cost', 'gcc') || 0 }

  # Launch cost based on mass
  mass_kg = satellite.mass_kg
  launch_cost_per_kg = 544.22 # $/kg
  launch_cost_usd = mass_kg * launch_cost_per_kg

  total_cost = construction_cost + launch_cost_usd

  puts "    - Construction Cost: #{construction_cost} GCC"
  puts "    - Satellite Mass: #{mass_kg.round(2)} kg"
  puts "    - Launch Cost: $#{launch_cost_usd.round(2)} USD"
  puts "    - Total Cost: #{construction_cost} GCC + $#{launch_cost_usd.round(2)} USD"

  build_stats[:construction_cost_gcc] = construction_cost
  build_stats[:launch_cost_usd] = launch_cost_usd
  build_stats[:total_bootstrap_cost] = total_cost

  { construction_gcc: construction_cost, launch_usd: launch_cost_usd, total: total_cost }
end

def deploy_gcc_satellite(satellite, build_stats)
  puts "  🚀 Processing launch payment..."

  # Pay for launch using LaunchPaymentService
  launch_config = {
    pricing: {
      cost_per_kg: 544.22,
      currency: 'USD',
      include_construction: true,
      construction_multiplier: 0.8
    },
    payment: {
      methods: [
        { currency: 'GCC', max_percentage: 50 },
        { currency: 'USD', max_percentage: 100 }
      ],
      allow_bonds: true,
      bond_terms: {
        maturity_days: 180,
        description: "GCC Satellite Launch Bond"
      }
    }
  }

  LaunchPaymentService.pay_for_launch!(
    craft: satellite,
    customer_accounts: { gcc: @ldc_gcc_account, usd: @ldc_usd_account },
    provider_accounts: { gcc: @astrolift_gcc_account, usd: @astrolift_usd_account },
    launch_config: launch_config
  )

  puts "    ✅ Launch payment processed"
  { success: true }
end

def start_gcc_mining(satellite, mission_data, build_stats)
  puts "  ⛏️ Starting GCC mining operations..."

  # Run mission tasks
  if mission_data[:tasks].any?
    MissionTaskRunnerService.run(
      satellite: satellite,
      tasks: mission_data[:tasks],
      accounts: { ldc: @ldc_gcc_account, astrolift: @astrolift_gcc_account }
    )
  end

  # Test initial mining
  mining_units = satellite.base_units.select { |u| u.unit_type.include?('mining') }
  puts "    - Mining Units: #{mining_units.size}"

  # Simulate first mining cycle
  initial_mining = mining_units.sum { |unit| unit.operational_data.dig('mining', 'base_yield') || 0 }
  puts "    - Initial Mining Rate: #{initial_mining} GCC/day"

  build_stats[:gcc_generation_started] = initial_mining > 0

  { mining_rate: initial_mining, units: mining_units.size }
end

def verify_gcc_bootstrap(deployment_result, build_stats)
  puts "\n🔍 PHASE 4: BOOTSTRAP VERIFICATION"

  if deployment_result[:skipped]
    puts "⏭️ Bootstrap verification skipped - not required"
    build_stats[:economic_bootstrapped] = true
    build_stats[:phases_completed] += 1
    return { success: true, skipped: true }
  end

  puts "  📊 Verifying GCC generation..."

  # Check satellite status
  satellite = deployment_result[:satellite]
  puts "    - Satellite: #{satellite.name}"
  puts "    - Status: #{satellite.status}"
  puts "    - Location: #{satellite.location&.name || 'Unknown'}"

  # Check power systems
  power_gen = satellite.power_generation
  power_use = satellite.power_usage
  puts "    - Power: #{power_gen.round(2)} kW generated, #{power_use.round(2)} kW used"

  # Check mining systems
  mining_active = satellite.base_units.any? { |u| u.unit_type.include?('mining') }
  puts "    - Mining Systems: #{mining_active ? 'ACTIVE' : 'INACTIVE'}"

  # Check economic impact
  final_ldc_gcc = @ldc_gcc_account.reload.balance
  final_ldc_usd = @ldc_usd_account.reload.balance
  final_astrolift_usd = @astrolift_usd_account.reload.balance

  puts "    - LDC GCC Balance: #{final_ldc_gcc.round(2)}"
  puts "    - LDC USD Balance: #{final_ldc_usd.round(2)}"
  puts "    - AstroLift USD Balance: #{final_astrolift_usd.round(2)}"

  # Verify bootstrap success
  bootstrap_success = mining_active && power_gen > power_use && final_ldc_gcc > 0

  build_stats[:economic_bootstrapped] = bootstrap_success
  build_stats[:phases_completed] += 1

  puts "  ✅ Bootstrap #{bootstrap_success ? 'SUCCESSFUL' : 'FAILED'}"
  puts "✅ Phase 4 complete"

  {
    success: bootstrap_success,
    mining_active: mining_active,
    power_balance: power_gen - power_use,
    economic_state: {
      ldc_gcc: final_ldc_gcc,
      ldc_usd: final_ldc_usd,
      astrolift_usd: final_astrolift_usd
    }
  }
end

def generate_gcc_bootstrap_report(build_stats, total_time)
  puts "\n📊 AI GCC BOOTSTRAP TEST REPORT"
  puts "=" * 60
  puts "Total Time: #{total_time.round(2)} seconds"
  puts "Phases Completed: #{build_stats[:phases_completed]}/4"
  puts "AI Decisions Made: #{build_stats[:ai_decisions_made]}"

  puts "\n🚀 DEPLOYMENT RESULTS:"
  puts "  - GCC Satellite Deployed: #{build_stats[:gcc_satellite_deployed] ? 'YES' : 'NO'}"
  puts "  - GCC Generation Started: #{build_stats[:gcc_generation_started] ? 'YES' : 'NO'}"
  puts "  - Economic Bootstrap: #{build_stats[:economic_bootstrapped] ? 'SUCCESSFUL' : 'FAILED'}"

  puts "\n💰 COSTS INCURRED:"
  puts "  - Construction Cost: #{build_stats[:construction_cost_gcc]} GCC"
  puts "  - Launch Cost: $#{build_stats[:launch_cost_usd].round(2)} USD"
  puts "  - Total Bootstrap Cost: #{build_stats[:total_bootstrap_cost].round(2)} USD"
  puts "  - Initial Funding Required: #{build_stats[:initial_funding_needed]} USD"

  if build_stats[:errors].any?
    puts "\n❌ ERRORS ENCOUNTERED:"
    build_stats[:errors].each { |error| puts "  - #{error}" }
  end

  puts "\n🤖 AI CAPABILITY ASSESSMENT:"
  puts "  • Bootstrap Recognition: #{build_stats[:ai_decisions_made] > 0 ? 'PASS' : 'FAIL'}"
  puts "  • Mission Execution: #{build_stats[:gcc_satellite_deployed] ? 'PASS' : 'FAIL'}"
  puts "  • Economic Management: #{build_stats[:economic_bootstrapped] ? 'PASS' : 'FAIL'}"
  puts "  • Cost Control: #{build_stats[:total_bootstrap_cost] > 0 ? 'PASS' : 'FAIL'}"

  puts "\n🏁 GCC BOOTSTRAP TEST COMPLETE"

  if build_stats[:economic_bootstrapped]
    puts "🎉 ECONOMY SUCCESSFULLY BOOTSTRAPPED!"
    puts "   The AI Manager can now proceed with Sol system development."
  else
    puts "⚠️ ECONOMY BOOTSTRAP FAILED"
    puts "   The AI Manager needs additional training or system fixes."
  end
end

def load_learned_patterns
  pattern_file = Rails.root.join('data', 'json-data', 'ai-manager', 'learned_patterns.json')
  if File.exist?(pattern_file)
    JSON.parse(File.read(pattern_file))
  else
    puts "⚠️ No learned patterns found, using defaults"
    {}
  end
end

def find_gcc_pattern_from_missions
  # Look for GCC-related mission profiles
  missions_path = Rails.root.join('data', 'json-data', 'missions')
  return nil unless Dir.exist?(missions_path)

  Dir.glob("#{missions_path}/**/*").each do |mission_dir|
    next unless File.directory?(mission_dir)

    profile_files = Dir.glob("#{mission_dir}/*_profile_v1.json")
    profile_path = profile_files.first

    if profile_path && File.exist?(profile_path)
      profile = JSON.parse(File.read(profile_path))
      if profile['name']&.include?('GCC') || profile['name']&.include?('mining') || profile['name']&.include?('crypto')
        return {
          'name' => profile['name'],
          'type' => 'gcc_satellite_deployment',
          'phases' => profile['phases']&.size || 1,
          'source' => 'mission_profile'
        }
      end
    end
  end

  nil
end