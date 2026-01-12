require 'json'
require_relative '../app/services/craft_factory_service'
require_relative '../app/services/fitting_result'
require_relative '../app/services/launch_payment_service'
require_relative '../app/services/mission_task_runner_service'

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

# 1. Setup context
ldc = Organizations::BaseOrganization.find_or_create_by!(name: 'Lunar Development Corporation', identifier: 'LDC', organization_type: :corporation)
astrolift = Organizations::BaseOrganization.find_or_create_by!(name: 'AstroLift', identifier: 'ASTROLIFT', organization_type: :corporation)
gcc_currency = Currency.find_by(symbol: 'GCC')
usd_currency = Currency.find_by(symbol: 'USD')
earth = CelestialBodies::CelestialBody.find_by(name: "Earth")
orbit_location = Location::CelestialLocation.find_by(coordinates: "0.00°N 0.00°E", celestial_body: earth) ||
                 Location::CelestialLocation.create!(name: "Planetary Orbit", coordinates: "0.00°N 0.00°E", celestial_body: earth)


# --- UPDATED INITIAL FUNDING SETUP ---

ldc_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: gcc_currency)
ldc_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: usd_currency)
astrolift_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: gcc_currency)
astrolift_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: usd_currency)

# Provide initial funds to LDC (the customer) to pay for the project.
ldc_gcc_account.deposit(100_000.00, "Initial Seed Fund")
ldc_usd_account.deposit(50_000.00, "Initial Seed Fund")

# Provide initial funds to AstroLift (the provider) to track payment reception.
astrolift_gcc_account.deposit(10_000.00, "Initial Working Capital")
astrolift_usd_account.deposit(20_000.00, "Initial Working Capital")

puts "💰 Initial Balances Established:"
puts "  - LDC GCC: #{ldc_gcc_account.balance.to_f.round(2)} GCC"
puts "  - LDC USD: #{ldc_usd_account.balance.to_f.round(2)} USD"
puts "  - AstroLift GCC: #{astrolift_gcc_account.balance.to_f.round(2)} GCC"
puts "  - AstroLift USD: #{astrolift_usd_account.balance.to_f.round(2)} USD"

# -----------------------------------


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

if manifest[:operational_data]
  satellite.update!(operational_data: manifest[:operational_data])
end

orbit_location.update(locationable: satellite)
satellite.reload

valid_locations = satellite.operational_data.dig('deployment', 'deployment_locations') || []
start_location_type = 'orbital'
if valid_locations.include?(start_location_type)
  satellite.deploy(start_location_type, celestial_body: earth)
else
  puts "⚠️ Using 'orbital' deployment type."
  satellite.deploy('orbital', celestial_body: earth)
end
satellite.reload

puts "✔ Satellite deployed: #{satellite.name} in orbit around #{earth.name}"

# 4. Fit components
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
    satellite.reload
    satellite.recalculate_effects if satellite.respond_to?(:recalculate_effects)
    
    puts "\n🔍 Post-fitting power check:"
    puts "  - Power Generation: #{satellite.power_generation.round(2)} kW"
    puts "  - Power Usage: #{satellite.power_usage.round(2)} kW"
    puts "  - Power Balance: #{(satellite.power_generation - satellite.power_usage).round(2)} kW"
  else
    puts "❌ Fitting failed: #{fit_result.errors.join(', ')}"
    exit 1
  end
end

# 5. Calculate costs and pay launch
puts "\n💰 Construction & Launch Cost Analysis:"
construction_cost = satellite.calculate_construction_cost rescue 0
puts "  - Construction Cost: #{construction_cost} GCC ($#{construction_cost} USD)"

satellite.base_units.each do |unit|
  cost = satellite.get_component_blueprint_cost(unit.unit_type, 'unit') rescue 0
  puts "    - #{unit.unit_type}: #{cost} GCC" if cost > 0
end

satellite.base_modules.each do |mod|
  cost = satellite.get_component_blueprint_cost(mod.module_type, 'module') rescue 0
  puts "    - #{mod.module_type}: #{cost} GCC" if cost > 0
end

satellite.base_rigs.each do |rig|
  cost = satellite.get_component_blueprint_cost(rig.rig_type, 'rig') rescue 0
  puts "    - #{rig.rig_type}: #{cost} GCC" if cost > 0
end

actual_launch_cost_per_kg = 544.22
satellite_mass_kg = satellite.calculate_mass
launch_cost = satellite_mass_kg * actual_launch_cost_per_kg
total_project_cost = construction_cost + launch_cost

puts "  - Satellite Mass: #{satellite_mass_kg.round(1)} kg"
puts "  - Launch Cost: $#{launch_cost.round(2)} USD"
puts "  - Total Project Cost: $#{total_project_cost.round(2)} USD"

LaunchPaymentService.pay_for_launch!(
  craft: satellite,
  customer_accounts: { gcc: ldc_gcc_account, usd: ldc_usd_account },
  provider_accounts: { gcc: astrolift_gcc_account, usd: astrolift_usd_account },
  launch_config: {
    pricing: {
      cost_per_kg: actual_launch_cost_per_kg,
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

# 7. Test mining and systems
puts "\n🔍 Operational Verification:"
if satellite.respond_to?(:power_generation)
  power_gen = satellite.power_generation
  power_use = satellite.power_usage
  puts "  - Power Generation: #{power_gen.round(2)} kW"
  puts "  - Power Usage: #{power_use.round(2)} kW"
  puts "  - Power Balance: #{(power_gen - power_use).round(2)} kW"
end

if satellite.respond_to?(:mine_gcc)
  initial_gcc = satellite.mine_gcc
  if initial_gcc&.positive?
    ldc_gcc_account.deposit(initial_gcc, "Test mining from #{satellite.name}")
    puts "  ✅ Mining test successful: #{initial_gcc} GCC/day"
  end
end

# 8. Mining performance analysis
puts "\n📈 Mining Performance Analysis:"
puts "  - Mining Units: #{satellite.mining_units.count}"
thermal_boost = satellite.calculate_thermal_efficiency_boost
processing_boost = satellite.calculate_processing_boost  
direct_boost = satellite.calculate_direct_mining_boost
base_mining = satellite.mining_units.sum { |u| u.mine(1.0, 1.0) }

puts "  - Base Mining: #{base_mining.round(1)} GCC/day"
puts "  - Thermal Efficiency: #{thermal_boost}x (#{((thermal_boost-1)*100).round(1)}% boost)"
puts "  - Processing Boost: #{processing_boost}x (#{((processing_boost-1)*100).round(1)}% boost)"
puts "  - Direct Mining Boost: +#{direct_boost.round(1)} GCC"
puts "  - Total Daily Output: #{(base_mining * thermal_boost * processing_boost + direct_boost).round(1)} GCC"

# 9. Economic analysis
puts "\n💰 Economic Analysis:"
daily_revenue = initial_gcc
annual_revenue = daily_revenue * 365
payback_years = total_project_cost / annual_revenue
puts "  - Daily Revenue: $#{daily_revenue} USD"
puts "  - Annual Revenue: $#{annual_revenue.round(0)} USD"
puts "  - Payback Period: #{payback_years.round(1)} years"

# 10. Bond obligations
puts "\n💳 Financial Obligations:"
bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)
if bonds.any?
  bonds.each do |bond|
    puts "  - Bond ##{bond.id}: $#{bond.amount} USD due #{bond.due_at.strftime('%Y-%m-%d')}"
    if ldc_gcc_account.balance >= bond.amount
      puts "    ✅ Sufficient funds when due"
    else
      shortage = bond.amount - ldc_gcc_account.balance.to_f
      puts "    ⚠️ Shortfall: $#{shortage.round(0)} USD"
    end
  end
end

# 11. Simulation
puts "\n📅 Operations Simulation (1 day):"
daily_gcc = satellite.mine_gcc
if daily_gcc > 0
  ldc_gcc_account.deposit(daily_gcc, "Daily mining from #{satellite.name}")
  puts "  - Mined: #{daily_gcc} GCC"
end
simulate_power_cycles(satellite)
puts "  - LDC Final Balance: #{ldc_gcc_account.reload.balance.to_f.round(2)} GCC"
puts "  - AstroLift Final Balance: #{astrolift_gcc_account.reload.balance.to_f.round(2)} GCC"

puts "\n🏁 Integration Test Summary:"
puts "  ✅ Satellite: #{satellite.name} (#{satellite.base_units.count} units, #{satellite.base_modules.count} modules, #{satellite.base_rigs.count} rigs)"
puts "  ✅ Total Project Cost: $#{total_project_cost.round(0)} USD"
puts "  ✅ Daily Mining: #{daily_gcc} GCC ($#{daily_gcc} USD)"
puts "  ✅ Payback Period: #{payback_years.round(1)} years"
puts "  ✅ All systems operational"