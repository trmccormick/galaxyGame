# === 1. Load manifest using game path helper
# === 2. Build craft from blueprint (chassis only)
# === 3. Apply operational data (variant)
# === 4. Fit units/modules/rigs
# === 6. Payment of Craft Construction ===
# === 7. Calculate Craft Mass and Pay Launch Costs ===

# -----------
# Original Tasks
# -----------
# === 1. Load Manifest ===
# === 2. Load Continuous Tasks ===
# === 3. Load mission profile and extract location ===
# === 4. Setup celestial context and owning organization ===
# === 5. Setup Currencies and Accounts ===
# === 6. Setup AstroLift and their accounts ===
# === 7. Load craft variant from manifest and create satellite ===
# === 8. Install Units, Modules, Rigs ===
# === 9. Calculate Satellite Mass and Pay Launch Costs ===
# === 11. Initial Mining Test ===
# === 12. Simulate Game Days Mining ===
# === 13. Bond Maturity and Repayment ===
# === 14. Final Verification ===

require 'json'
require_relative '../app/services/craft_factory_service'
require_relative '../app/services/fitting_result'
require_relative '../app/services/launch_payment_service'
require_relative '../app/services/mission_task_runner_service'

# Define methods at the top of the file
def simulate_power_cycles(satellite)
  battery = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
  return unless battery
  
  if rand < 0.3
    charge = battery.operational_data.dig('battery', 'current_charge') || 0
    power_used = satellite.power_usage * 0.25
    new_charge = [charge - power_used, 0].max
    battery.operational_data['battery']['current_charge'] = new_charge
    battery.save!
    puts "  - Eclipse period: Battery at #{(new_charge / battery.operational_data['battery']['capacity'] * 100).round(1)}%"
  else
    capacity = battery.operational_data.dig('battery', 'capacity') || 0
    battery.operational_data['battery']['current_charge'] = capacity
    battery.save!
    puts "  - Sunlight period: Battery fully charged"
  end
end

puts "\n🚀 Starting GCC Mining Satellite Integration Test..."

# 1. Setup context (orgs, currencies, accounts, locations)
ldc = Organizations::BaseOrganization.find_or_create_by!(name: 'Lunar Development Corporation', identifier: 'LDC', organization_type: :corporation)
astrolift = Organizations::BaseOrganization.find_or_create_by!(name: 'AstroLift', identifier: 'ASTROLIFT', organization_type: :corporation)
gcc_currency = Currency.find_by(symbol: 'GCC')
usd_currency = Currency.find_by(symbol: 'USD')
ldc_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: gcc_currency)
ldc_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: usd_currency)
astrolift_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: gcc_currency)
astrolift_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: usd_currency)
earth = CelestialBodies::CelestialBody.find_by(name: "Earth")
orbit_location = Location::CelestialLocation.find_by(coordinates: "0.00°N 0.00°E", celestial_body: earth) ||
                 Location::CelestialLocation.create!(name: "Planetary Orbit", coordinates: "0.00°N 0.00°E", celestial_body: earth)

# 2. Load mission files
manifest_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'crypto_mining_satellite_01_manifest_v2.json')
manifest = JSON.parse(File.read(manifest_path), symbolize_names: true)
task_path = GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'gcc_satellite_mining_tasks_v1.json')
tasks = JSON.parse(File.read(task_path), symbolize_names: true) if File.exist?(task_path)

# 3. Build and deploy craft
satellite = CraftFactoryService.build_from_blueprint(
  blueprint_id: manifest.dig(:craft, :blueprint_id),
  variant_data: manifest[:variant_data],
  owner: ldc,
  location: orbit_location
)
raise "Satellite build failed" unless satellite&.persisted?

# Apply operational data separately
if manifest[:operational_data]
  satellite.update!(operational_data: manifest[:operational_data])
end

# Assign location and deploy satellite (like working script)
orbit_location.update(locationable: satellite)
satellite.reload

# Deploy satellite 
valid_locations = satellite.operational_data.dig('deployment', 'deployment_locations') || []
start_location_type = 'orbital' # or get from profile
if valid_locations.include?(start_location_type)
  satellite.deploy(start_location_type, celestial_body: earth)
else
  puts "⚠️ Using 'orbital' deployment type."
  satellite.deploy('orbital', celestial_body: earth)
end
satellite.reload

puts "✔ Satellite deployed: #{satellite.name} in orbit around #{earth.name}"

# 4. Fit units/modules/rigs
fit_data = (manifest[:operational_data] && manifest[:operational_data]['recommended_fit']) || 
           manifest.dig(:variant_data, :recommended_fit) ||
           satellite.operational_data['recommended_fit']

if fit_data
  fit_result = FittingService.fit!(
    target: satellite,
    fit_data: fit_data,
    inventory: manifest[:inventory],
    dry_run: false
  )
  if fit_result.success?
    # Force recalculation of all effects
    satellite.reload
    satellite.recalculate_effects if satellite.respond_to?(:recalculate_effects)
    
    # Debug power systems
    puts "\n🔍 Post-fitting power check:"
    puts "  - Power Generation: #{satellite.power_generation.round(2)} kW"
    puts "  - Power Usage: #{satellite.power_usage.round(2)} kW"
    puts "  - Power Balance: #{(satellite.power_generation - satellite.power_usage).round(2)} kW"
  else
    puts "❌ Fitting failed: #{fit_result.errors.join(', ')}"
    exit 1
  end
else
  puts "⚠️ No fitting data found in manifest or operational data"
end

# Debug Module/Rig Associations
puts "\n🔧 Debug Module/Rig Associations:"
puts "  - Satellite base_units count: #{satellite.base_units.count}"
puts "  - Satellite modules count: #{satellite.modules.count}"
puts "  - Satellite rigs count: #{satellite.rigs.count}"

# Check if the satellite model has the right associations
puts "  - Satellite responds to modules?: #{satellite.respond_to?(:modules)}"
puts "  - Satellite responds to rigs?: #{satellite.respond_to?(:rigs)}"

# Try to access modules/rigs directly
if satellite.respond_to?(:modules)
  satellite.modules.each do |mod|
    puts "    - Module: #{mod.module_type} (#{mod.name})"
  end
end

if satellite.respond_to?(:rigs)  
  satellite.rigs.each do |rig|
    puts "    - Rig: #{rig.rig_type} (#{rig.name})"
  end
end

# In your integration script, add this debug after the rig installation error:
puts "\n🔧 Rig Installation Debug:"
if satellite.respond_to?(:available_rig_ports)
  puts "  - Available Rig Ports: #{satellite.available_rig_ports}"
  puts "  - Current Rig Count: #{satellite.base_rigs.count}"
end

# Try manual rig creation to see the actual error
begin
  rig_data = Lookup::RigLookupService.new.find_rig('gpu_coprocessor_rig')
  puts "  - Rig Data Found: #{rig_data.present?}"
  if rig_data
    puts "  - Rig Data Keys: #{rig_data.keys}"
  else
    puts "  - ❌ No rig data found for 'gpu_coprocessor_rig'"
  end
rescue => e
  puts "  - ❌ Error loading rig data: #{e.message}"
end

# 5. Calculate mass and pay launch costs
puts "\n💰 Calculating Construction Costs..."

puts "\n💰 Detailed Cost Breakdown:"
construction_cost = satellite.calculate_construction_cost rescue 0
puts "  - Construction Cost: #{construction_cost} GCC ($#{(construction_cost).round(2)} USD)"

# Individual component costs
satellite.base_units.each do |unit|
  cost = satellite.get_component_blueprint_cost(unit.unit_type, 'unit') rescue 0
  puts "    - #{unit.unit_type}: #{cost} GCC"
end

satellite.base_modules.each do |mod|
  cost = satellite.get_component_blueprint_cost(mod.module_type, 'module') rescue 0
  puts "    - #{mod.module_type}: #{cost} GCC"
end

satellite.base_rigs.each do |rig|
  cost = satellite.get_component_blueprint_cost(rig.rig_type, 'rig') rescue 0
  puts "    - #{rig.rig_type}: #{cost} GCC"
end

# Standardize on kg for all backend calculations
actual_launch_cost_per_kg = 544.22  # $1200/lb converted to $/kg
satellite_mass_kg = satellite.calculate_mass
satellite_mass_lbs = satellite_mass_kg * 2.20462

launch_cost = satellite_mass_kg * actual_launch_cost_per_kg
total_project_cost = construction_cost + launch_cost

puts "  - Satellite Mass: #{satellite_mass_kg.round(1)} kg (#{satellite_mass_lbs.round(1)} lbs)"
puts "  - Launch Cost: $#{launch_cost.round(2)} USD (equivalent to $#{(actual_launch_cost_per_kg * 2.20462).round(2)}/lb)"  
puts "  - Total Project Cost: $#{total_project_cost.round(2)} USD"
puts "  - Base satellite mass: #{satellite.get_base_craft_mass rescue 'N/A'} kg"

# Pay for both construction and launch:
LaunchPaymentService.pay_for_launch!(
  craft: satellite,
  customer_accounts: { 
    gcc: ldc_gcc_account, 
    usd: ldc_usd_account 
  },
  provider_accounts: { 
    gcc: astrolift_gcc_account, 
    usd: astrolift_usd_account 
  },
  launch_config: {
    pricing: {
      cost_per_kg: actual_launch_cost_per_kg,  # Use kg consistently
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
        description: "Launch service bond for satellite deployment"
      }
    }
  }
)

# 6. Run mission tasks
MissionTaskRunnerService.run(
  satellite: satellite,
  tasks: tasks,
  accounts: { ldc: ldc_gcc_account, astrolift: astrolift_gcc_account }
)

# 7. Verify power and mining systems
puts "\n🔍 Verifying satellite systems..."
if satellite.respond_to?(:power_generation)
  power_gen = satellite.power_generation
  power_use = satellite.power_usage
  puts "  - Power Generation: #{power_gen.round(2)} kW"
  puts "  - Power Usage: #{power_use.round(2)} kW"
  puts "  - Power Balance: #{(power_gen - power_use).round(2)} kW"
end

# Test mining
if satellite.respond_to?(:mine_gcc)
  initial_gcc = satellite.mine_gcc
  if initial_gcc&.positive?
    ldc_gcc_account.deposit(initial_gcc, "Test mining from #{satellite.name}")
    puts "  ✅ Mining test successful: #{initial_gcc} GCC"
  else
    puts "  ❌ Mining test failed: No GCC produced"
  end
end

# Debug installed components
puts "\n🔧 Installed Components Debug:"
puts "  - Base Units: #{satellite.base_units.count}"
puts "  - Base Modules: #{satellite.base_modules.count}"
puts "  - Base Rigs: #{satellite.base_rigs.count}"

satellite.base_modules.each do |mod|
  puts "    - #{mod.module_type}: #{mod.name} (ID: #{mod.id})"
end

satellite.base_rigs.each do |rig|
  puts "    - #{rig.rig_type}: #{rig.name} (ID: #{rig.id})"
end

# After fitting, activate solar panels
puts "\n🔧 Activating Solar Panels..."
satellite.base_units.each do |unit|
  if unit.unit_type == 'solar_panel'
    unit.operational_data['operational_status']['status'] = 'online'
    unit.save!
    puts "  ✅ Activated #{unit.name} - Status: #{unit.operational_data['operational_status']['status']}"
  end
end

# Recalculate power after activation
satellite.reload
puts "  - Updated Power Generation: #{satellite.power_generation} kW"

# Check if solar panel is properly contributing to power
solar_panels = satellite.base_units.select { |unit| unit.unit_type == 'solar_panel' }
puts "  - Solar Panels Found: #{solar_panels.count}"
solar_panels.each do |panel|
  power_output = panel.operational_data.dig('power_generation', 'output_kw') || 0
  puts "    - #{panel.name}: #{power_output} kW potential output"
end

# Test direct file access
puts "\n🔧 Direct File Access Test:"
direct_files = [
  'blueprints/modules/sensor/basic_sensor_bp.json',
  'blueprints/modules/energy/power_controller_bp.json', 
  'blueprints/modules/utility/radiator_array_bp.json',
  'blueprints/rigs/computer/gpu_coprocessor_rig_bp.json'
]

direct_files.each do |file_path|
  full_path = Rails.root.join('app', 'data', file_path)
  exists = File.exist?(full_path)
  puts "  - #{file_path}: #{exists ? 'EXISTS' : 'MISSING'}"
  
  if exists
    begin
      data = JSON.parse(File.read(full_path))
      puts "    - ID: #{data['id']}"
      puts "    - Category: #{data['category']}"
      puts "    - Blueprint Type: #{data['blueprint_type']}"
    rescue => e
      puts "    - ERROR reading: #{e.message}"
    end
  end
end

# Add this debug to your integration script after fitting:
puts "\n🔧 Mining Rate Debug:"
base_rate = satellite.operational_data.dig('operational_properties', 'base_mining_rate_gcc_per_hour') || 0
puts "  - Base Mining Rate: #{base_rate} GCC/hour"

# Check if effects are tracked
if satellite.operational_data['active_module_effects']
  puts "  - Active Module Effects: #{satellite.operational_data['active_module_effects'].count}"
  satellite.operational_data['active_module_effects'].each do |effect|
    puts "    - #{effect['module_type']}: #{effect['effects'].map { |e| e['type'] }.join(', ')}"
  end
else
  puts "  - ❌ No active module effects tracked"
end

if satellite.operational_data['active_rig_effects']
  puts "  - Active Rig Effects: #{satellite.operational_data['active_rig_effects'].count}"
  satellite.operational_data['active_rig_effects'].each do |effect|
    puts "    - #{effect['rig_type']}: #{effect['effects'].map { |e| e['type'] }.join(', ')}"
  end
else
  puts "  - ❌ No active rig effects tracked"
end

# Check thermal effects
thermal_effects = satellite.operational_data['thermal_effects']
puts "  - Thermal Effects: #{thermal_effects || 'None'}"

# Check processing effects
processing_effects = satellite.operational_data['processing_effects']
puts "  - Processing Effects: #{processing_effects || 'None'}"

# Check mining effects
mining_effects = satellite.operational_data['mining_effects']
puts "  - Mining Effects: #{mining_effects || 'None'}"

puts "\n🏁 Integration test complete!"
puts "  - Satellite: #{satellite.name} (ID: #{satellite.id})"
puts "  - Owner: #{satellite.owner.name}"
puts "  - Units installed: #{satellite.base_units.count}"
puts "  - LDC GCC Balance: #{ldc_gcc_account.reload.balance.to_f} GCC"

# Add this after the mining test:
puts "\n🔧 Enhanced Mining Debug:"
puts "  - Mining Units Found: #{satellite.mining_units.count}"
satellite.mining_units.each_with_index do |unit, i|
  base_rate = unit.instance_variable_get(:@unit).operational_data&.dig('performance', 'mining_power') || 45.0
  puts "    - Unit #{i+1}: #{base_rate} GCC/hour base rate"
end

puts "  - Effect Calculations:"
thermal_boost = satellite.calculate_thermal_efficiency_boost
puts "    - Thermal Efficiency: #{thermal_boost}x (#{((thermal_boost-1)*100).round(1)}% boost)"

processing_boost = satellite.calculate_processing_boost  
puts "    - Processing Boost: #{processing_boost}x (#{((processing_boost-1)*100).round(1)}% boost)"

direct_boost = satellite.calculate_direct_mining_boost
puts "    - Direct Mining Boost: +#{direct_boost.round(1)} GCC"

base_mining = satellite.mining_units.sum { |u| u.mine(1.0, 1.0) }
puts "    - Base Mining (4 units): #{base_mining.round(1)} GCC"
puts "    - With Thermal: #{(base_mining * thermal_boost).round(1)} GCC"
puts "    - With Processing: #{(base_mining * thermal_boost * processing_boost).round(1)} GCC" 
puts "    - With Direct Boost: #{(base_mining * thermal_boost * processing_boost + direct_boost).round(1)} GCC"

# Missing from simplified script - add this section:
puts "\n💳 Bond Maturity and Repayment Check..."
current_date = Date.current # or use game state date if available

bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)
bonds.each do |bond|
  if current_date >= bond.due_at
    # Calculate GCC equivalent for USD bond
    exchange_rate = 1.0 # Define your USD->GCC rate
    gcc_needed = (bond.amount * exchange_rate).round(2)
    available_gcc = ldc_gcc_account.balance.to_f

    if available_gcc >= gcc_needed
      ldc_gcc_account.transfer_funds(gcc_needed, astrolift_gcc_account, "Bond repayment for Bond ##{bond.id}")
      bond.update!(status: :paid)
      puts "💸 Bond ##{bond.id} repaid: #{gcc_needed} GCC"
    else
      puts "⚠️ Insufficient GCC for Bond ##{bond.id}. Need: #{gcc_needed}, Have: #{available_gcc}"
    end
  else
    puts "⏳ Bond ##{bond.id} not yet due. Due: #{bond.due_at}"
  end
end

# After the mining test, add time simulation:
puts "\n📅 Mining Operations Simulation..."
simulation_days = 1
total_mined_over_time = 0

simulation_days.times do |day|
  puts "Day #{day + 1}:"
  
  daily_gcc = satellite.mine_gcc
  if daily_gcc > 0
    ldc_gcc_account.deposit(daily_gcc, "Daily mining from #{satellite.name}")
    total_mined_over_time += daily_gcc
    puts "  - Daily Mining: #{daily_gcc} GCC"
  end
  
  # Simulate battery discharge/recharge cycles
  simulate_power_cycles(satellite)
  
  puts "  - Running Balance: #{ldc_gcc_account.reload.balance.to_f} GCC"
end

puts "✅ Total mined over #{simulation_days} days: #{total_mined_over_time} GCC"

# Add bond payment check:
puts "\n💳 Checking Bond Obligations..."
bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)
if bonds.any?
  bonds.each do |bond|
    puts "  - Bond ##{bond.id}: #{bond.amount} USD due #{bond.due_at}"
    
    # Simulate bond maturity after simulation period
    if ldc_gcc_account.balance >= bond.amount
      puts "  ✅ Sufficient GCC to cover bond when due"
    else
      shortage = bond.amount - ldc_gcc_account.balance.to_f
      puts "  ⚠️ GCC shortage of #{shortage.round(2)} for bond payment"
    end
  end
else
  puts "  - No outstanding bonds"
end

# Add background job simulation:
puts "\n🔄 Testing Background Mining Job..."
begin
  if defined?(MineGccJob)
    job_result = MineGccJob.perform_now(satellite.id, { test_mode: true })
    puts "  ✅ Background job mined: #{job_result} GCC"
  else
    puts "  ℹ️ Background mining job class not loaded (expected in development)"
  end
rescue => e
  puts "  ℹ️ Background job simulation skipped: #{e.message}"
end

puts "\n🔧 DEBUG: Testing BlueprintLookupService..."
service = Lookup::BlueprintLookupService.new

# Test specific blueprints
test_items = [
  { id: 'solar_panel', category: 'energy' },        # not 'units'
  { id: 'advanced_computer', category: 'computers' }, # not 'units'  
  { id: 'basic_sensor', category: 'sensors' },       # not 'modules'
  { id: 'gpu_coprocessor_rig', category: 'expansion_rig' } # not 'rigs'
]

test_items.each do |item|
  puts "  Testing #{item[:id]} (#{item[:category]}):"
  blueprint = service.find_blueprint(item[:id], item[:category])
  
  if blueprint
    puts "    ✅ Found blueprint"
    puts "    Keys: #{blueprint.keys}"
    cost_data = blueprint.dig('cost_data', 'purchase_cost')
    if cost_data
      puts "    💰 Cost: #{cost_data['amount']} #{cost_data['currency']}"
    else
      puts "    ❌ No cost_data.purchase_cost found"
    end
  else
    puts "    ❌ Blueprint not found"
  end
end

puts "\nTotal blueprints loaded: #{service.all_blueprints.count}"
puts "Categories found: #{service.all_blueprints.map { |bp| bp['category'] }.uniq.compact}"

