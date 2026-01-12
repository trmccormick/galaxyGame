require 'json'
require 'securerandom'

puts "\n🚀 Starting Full GCC Mining Satellite Integration Test..."

# === Bond maturity period (days) ===
bond_maturity_days = 180

# === Parse number of game days from ARGV or default to bond maturity ===
game_days = (ARGV[0]&.to_i || bond_maturity_days)
puts "\nSimulating #{game_days} game days..."

# === Initialize Game and GameState ===
game = Game.new
game_state = game.game_state

# === 1. Load Manifest ===
puts "\n1. Loading mission manifest..."
manifest_path = File.join(
  GalaxyGame::Paths::JSON_DATA,
  'missions',
  'gcc_sat_mining_deployment',
  'gcc_mining_satellite_01_phases_v1.json'
)

begin
  manifest = JSON.parse(File.read(manifest_path))
  puts "✔ Manifest loaded: #{manifest['mission_id'] || 'Unnamed Phase'}"
rescue => e
  puts "❌ ERROR: Failed to load manifest – #{e.message}"
  exit 1
end

craft_lookup_service = Lookup::CraftLookupService.new
unit_lookup_service = Lookup::UnitLookupService.new
blueprint_service = Lookup::BlueprintLookupService.new

# === 2. Load Continuous Tasks ===
puts "\n2. Loading continuous mining tasks..."
task_path = File.join(
  GalaxyGame::Paths::JSON_DATA,
  'missions',
  'gcc_sat_mining_deployment',
  'gcc_satellite_mining_tasks_v1.json'
)

task_list = []
if File.exist?(task_path)
  begin
    task_list = JSON.parse(File.read(task_path))
    puts "✔ Loaded #{task_list.length} mining tasks"
  rescue => e
    puts "⚠️ Warning: Failed to parse tasks – #{e.message}"
  end
else
  puts "⚠️ No mining tasks file found — simulation will continue with defaults"
end

# === 3. Load mission profile and extract location ===
puts "\n3. Loading mission profile..."
profile_path = File.join(GalaxyGame::Paths::JSON_DATA, 'missions', 'gcc_sat_mining_deployment', 'gcc_mining_satellite_01_profile_v1.json')
begin
  profile = JSON.parse(File.read(profile_path))
  start_location_type = profile.dig('start_conditions', 'location') || 'planetary_orbit'
  puts "✔ Profile loaded: Start location type: #{start_location_type}"
rescue => e
  puts "❌ ERROR: Failed to load profile: #{e.message}"
  exit
end

# === 4. Setup celestial context and owning organization ===
puts "\n4. Setting up orbiting context and LDC..."
earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.where(name: "Earth").first ||
        CelestialBodies::CelestialBody.where(name: "Earth").first
if earth.nil?
  puts "❌ Earth not found. Check database seeding."
  exit 1
else
  puts "✅ Found Earth (ID: #{earth.id}, Identifier: #{earth.identifier})"
end

orbit_location = Location::CelestialLocation.find_by(
  coordinates: "0.00°N 0.00°E",
  celestial_body: earth
)

if orbit_location
  if orbit_location.locationable
    puts "⚠️ Location already assigned to: #{orbit_location.locationable.class.name} (ID: #{orbit_location.locationable.id})"
  else
    puts "✅ Reusing existing location: #{orbit_location.name} (ID: #{orbit_location.id})"
  end
else
  orbit_location = Location::CelestialLocation.create!(
    name: "Planetary Orbit",
    coordinates: "0.00°N 0.00°E",
    celestial_body: earth
  )
  puts "✅ Created new location: #{orbit_location.name} (ID: #{orbit_location.id})"
end

ldc = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Lunar Development Corporation',
  identifier: 'LDC',
  organization_type: :corporation
)
puts "✅ Using organization: #{ldc.name} (ID: #{ldc.id})"

# === 5. Setup Currencies and Accounts ===
puts "\n5. Setting up Currencies and LDC Accounts..."
gcc_currency = Currency.find_by(symbol: 'GCC')
usd_currency = Currency.find_by(symbol: 'USD')
if gcc_currency.nil? || usd_currency.nil?
  puts "❌ ERROR: GCC or USD Currency not found. Please run `rails db:seed`."
  exit 1
end
puts "✅ Found GCC Currency (ID: #{gcc_currency.id}, Symbol: #{gcc_currency.symbol})"
puts "✅ Found USD Currency (ID: #{usd_currency.id}, Symbol: #{usd_currency.symbol})"

ldc_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: gcc_currency)
ldc_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: ldc, currency: usd_currency)
puts "✅ LDC's GCC Account: ID #{ldc_gcc_account.id}, Initial Balance: #{ldc_gcc_account.balance.to_f} GCC"
puts "✅ LDC's USD Account: ID #{ldc_usd_account.id}, Initial Balance: #{ldc_usd_account.balance.to_f} USD"

# === 6. Setup AstroLift and their accounts ===
puts "\n6. Setting up AstroLift and their accounts..."
astrolift = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift',
  identifier: 'ASTROLIFT',
  organization_type: :corporation
)
puts "✅ Using organization: #{astrolift.name} (ID: #{astrolift.id})"

astrolift_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: gcc_currency)
astrolift_gcc_account.update(balance: 0.0) # Ensure AstroLift starts with 0 GCC
astrolift_usd_account = Account.find_or_create_for_entity_and_currency(accountable_entity: astrolift, currency: usd_currency)
puts "✅ AstroLift's GCC Account: ID #{astrolift_gcc_account.id}, Balance: #{astrolift_gcc_account.balance.to_f} GCC"
puts "✅ AstroLift's USD Account: ID #{astrolift_usd_account.id}, Balance: #{astrolift_usd_account.balance.to_f} USD"

# === 7. Load craft variant from manifest and create satellite ===
craft_id = manifest.dig("craft", "id") || "crypto_mining_satellite"
blueprint_id = manifest.dig("craft", "blueprint_id") || "generic_satellite"

satellite_data = craft_lookup_service.find_craft(craft_id)
sat_bp = blueprint_service.find_blueprint(blueprint_id, "satellite")

base_mass_kg = sat_bp&.dig("physical_properties", "empty_mass_kg").to_f rescue 0.0

satellite = Craft::Satellite::BaseSatellite.create!(
  name: "GCCSat-#{SecureRandom.hex(4)}",
  craft_name: satellite_data['name'] || "Generic Satellite",
  craft_type: satellite_data['subcategory'] || "space/satellites/mining",
  owner: ldc,
  deployed: false,
  operational_data: satellite_data
)
orbit_location.update(locationable: satellite)
satellite.reload

valid_locations = satellite_data.dig('deployment', 'deployment_locations') || []
if valid_locations.include?(start_location_type)
  satellite.deploy(start_location_type, celestial_body: earth)
else
  puts "⚠️ Profile location type '#{start_location_type}' not supported by satellite."
  puts "✅ Using 'orbital' instead."
  satellite.deploy('orbital', celestial_body: earth)
end
satellite.reload
puts "✔ Satellite deployed by AstroLift: #{satellite.name} in orbit around #{earth.name}"

# === 8. Install Units ===
puts "\n8. Installing units from manifest or recommended fit..."
units_to_install = manifest.dig("craft", "installed_units") ||
                   satellite_data.dig("recommended_fit", "units") || []
missing_units = []
units_to_install.each do |unit|
  unit_id = unit['id']
  count = unit['count'] || 1
  unit_data = unit_lookup_service.find_unit(unit_id)
  if unit_data.nil?
    missing_units << unit_id
    puts "  ❌ Unknown unit type: #{unit_id}"
    next
  end
  puts "  - Installing #{count}x #{unit_id}"
  count.times do |i|
    klass = if unit_id.include?('computer')
      Units::Computer
    elsif unit_id == 'satellite_battery'
      Units::Battery
    else
      Units::BaseUnit
    end
    unit = klass.new(
      name: "#{unit_id}_#{i + 1}",
      unit_type: unit_id,
      owner: ldc,
      identifier: "#{unit_id.upcase}_#{satellite.name}_#{i + 1}_#{SecureRandom.hex(4)}",
      operational_data: unit_data
    )
    if unit.save && satellite.install_unit(unit)
      puts "    ✅ Installed #{unit_id} (ID: #{unit.id})"
    else
      puts "    ❌ Failed to install #{unit_id}: #{unit.errors.full_messages.join(', ')}"
    end
  end
end
if missing_units.any?
  puts "❌ ERROR: The following unit types are required but not defined in the system:"
  missing_units.each { |u| puts "  - #{u}" }
  exit 1
end

# === 9. Calculate Satellite Mass and Pay Launch Costs ===
puts "\n9. Calculating satellite mass and paying AstroLift for launch costs..."

bp_id = satellite_data['blueprint_id'] || "generic_satellite"
sat_bp = blueprint_service.find_blueprint(bp_id, "satellite") ||
         blueprint_service.find_blueprint("Generic Satellite", "satellite")
base_mass_kg = sat_bp&.dig("physical_properties", "empty_mass_kg").to_f rescue 0.0

puts "    Satellite base mass: #{base_mass_kg > 0 ? base_mass_kg : 'N/A'} kg"

def find_unit_blueprint(blueprint_service, unit_type)
  %w[unit computers energy propulsion storage].each do |cat|
    bp = blueprint_service.find_blueprint(unit_type, cat)
    return bp if bp
  end
  nil
end

def extract_unit_mass(unit_bp)
  mass = unit_bp.dig("physical_properties", "empty_mass_kg") ||
         unit_bp.dig("physical_properties", "mass_kg")
  return mass.to_f if mass
  mass = unit_bp.dig("operational_data_reference", "physical_properties", "mass_kg")
  return mass.to_f if mass
  if unit_bp["required_materials"]
    estimated_mass = unit_bp["required_materials"].values.select { |mat| mat["unit"] == "kilogram" }.sum { |mat| mat["amount"].to_f }
    return estimated_mass if estimated_mass > 0
  end
  0.0
end

units_mass_kg = satellite.base_units.sum do |unit|
  unit_bp = find_unit_blueprint(blueprint_service, unit.unit_type)
  if unit_bp
    unit_mass = extract_unit_mass(unit_bp)
    puts "    Unit #{unit.name} mass: #{unit_mass > 0 ? unit_mass : 'N/A'} kg"
    unit_mass
  else
    puts "    ⚠️ No blueprint found for unit_type: #{unit.unit_type}"
    0.0
  end
end

total_mass_kg = base_mass_kg + units_mass_kg
total_mass_lbs = total_mass_kg * 2.20462

if total_mass_lbs <= 0
  puts "  ⚠️ WARNING: Satellite mass could not be determined. Using default mass of 2000 lbs."
  total_mass_lbs = 2000.0
end
puts "  - Calculated satellite mass: #{total_mass_kg.round(2)} kg (#{total_mass_lbs.round(2)} lbs)"

launch_cost_usd = (total_mass_lbs * 1200).round(2)

# Try to pay up to 50% of launch cost in GCC, but not more than LDC has
max_gcc_portion = (launch_cost_usd * 0.5).round(2)
available_gcc = ldc_gcc_account.balance.to_f
gcc_paid = [max_gcc_portion, available_gcc].min.round(2)
usd_paid = (launch_cost_usd - gcc_paid).round(2)

puts "LDC USD Balance before launch payment: #{ldc_usd_account.balance.to_f} USD"
puts "LDC GCC Balance before launch payment: #{ldc_gcc_account.balance.to_f} GCC"

if gcc_paid > 0
  ldc_gcc_account.transfer_funds(gcc_paid, astrolift_gcc_account, "Satellite launch service fee (GCC portion)")
end

usd_available = ldc_usd_account.balance.to_f
usd_cash_paid = [usd_paid, usd_available].min.round(2)
usd_bond_amount = (usd_paid - usd_cash_paid).round(2)

if usd_cash_paid > 0
  ldc_usd_account.transfer_funds(usd_cash_paid, astrolift_usd_account, "Satellite launch service fee (USD portion)")
end

bond = nil
if usd_bond_amount > 0
  # Issue a bond from LDC to AstroLift for the unpaid USD portion
  issued_at = Date.new(game_state.year, 1, 1) + (game_state.day - 1)
  due_at = issued_at + bond_maturity_days
  bond = Bond.create!(
    issuer: ldc,
    holder: astrolift,
    currency: usd_currency,
    amount: usd_bond_amount,
    issued_at: issued_at,
    due_at: due_at,
    status: :issued,
    description: "Bond issued for unpaid launch cost (USD portion)"
  )
  puts "🪙 LDC issued a bond to AstroLift for #{usd_bond_amount} USD (unpaid portion of launch cost). Bond ID: #{bond.id}"
end

puts "✅ LDC paid #{usd_cash_paid} USD and #{gcc_paid} GCC to AstroLift for launch."
puts "   LDC USD Balance: #{ldc_usd_account.reload.balance.to_f} USD"
puts "   LDC GCC Balance: #{ldc_gcc_account.reload.balance.to_f} GCC"
puts "   AstroLift USD Balance: #{astrolift_usd_account.reload.balance.to_f} USD"
puts "   AstroLift GCC Balance: #{astrolift_gcc_account.reload.balance.to_f} GCC"

# === 10. Verifying power systems ===
puts "\n10. Verifying power systems..."
power_gen = satellite.power_generation
power_use = satellite.power_usage
power_balance = power_gen - power_use
puts "  - Power Generation: #{power_gen.round(2)} kW"
puts "  - Power Usage: #{power_use.round(2)} kW"
puts "  - Power Balance: #{power_balance.round(2)} kW"
battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
if battery_unit
  battery_capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
  battery_charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
  puts "  - Battery Unit: #{battery_unit.name}"
  puts "  - Battery Capacity: #{battery_capacity.round(2)} kWh"
  puts "  - Current Charge: #{battery_charge.round(2)} kWh (#{(battery_charge / battery_capacity * 100).round(1)}%)"
  if power_balance < 0
    puts "  ⚠️ WARNING: Power deficit detected. Mining will rely on batteries."
    hours_remaining = battery_charge / power_use.abs
    puts "  - Estimated battery duration: #{hours_remaining.round(1)} hours"
  else
    puts "  ✅ Power systems nominal. Generating surplus of #{power_balance.round(2)} kW"
  end
else
  puts "  ⚠️ WARNING: No battery units installed. Mining will halt during eclipses."
end

# === 11. Initial Mining Test ===
puts "\n11. Performing first mining cycle..."
initial_gcc_amount = satellite.mine_gcc
if initial_gcc_amount.positive?
  ldc_gcc_account.deposit(initial_gcc_amount, "Initial GCC mining from #{satellite.name}")
  puts "✔ Initial GCC mined: #{initial_gcc_amount}. Deposited to LDC Account. New Balance: #{ldc_gcc_account.balance.to_f} GCC"
else
  puts "❌ No GCC mined in first cycle"
end

# === 12. Simulate Game Days Mining ===
puts "\n12. Simulating mining over game days using Game loop..."
game_days.times do |day|
  game.advance_by_days(1)
  game_state.reload
  current_date = Date.new(game_state.year, 1, 1) + (game_state.day - 1)

  puts "\n📅 Game Day #{day + 1} (Simulated Date: #{current_date.strftime('%Y-%m-%d')})..."
  power_status = satellite.power_generation >= satellite.power_usage
  mined_amount_this_day = 0
  if !power_status
    puts "  ⚠️ Power deficit detected. Checking battery..."
    battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
    if battery_unit && (battery_unit.operational_data.dig('battery', 'current_charge') || 0) > 0
      battery_charge_before = battery_unit.operational_data.dig('battery', 'current_charge') || 0
      power_needed = satellite.power_usage - satellite.power_generation
      if battery_charge_before >= power_needed
        new_charge = battery_charge_before - power_needed
        battery_unit.operational_data['battery']['current_charge'] = new_charge
        battery_unit.save!
        puts "  🔋 Battery used: #{power_needed.round(2)} kWh (#{new_charge.round(2)} kWh remaining)"
        mined_amount_this_day = satellite.mine_gcc
      else
        puts "  ❌ Insufficient battery charge for mining"
        mined_amount_this_day = 0
      end
    else
      puts "  ❌ No battery available for mining"
      mined_amount_this_day = 0
    end
  else
    mined_amount_this_day = satellite.mine_gcc
    battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
    if battery_unit
      battery_capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
      current_charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
      max_charge_rate = battery_unit.operational_data.dig('battery', 'max_charge_rate_kw') || 10.0
      excess_power = [satellite.power_generation - satellite.power_usage, max_charge_rate].min
      new_charge = [current_charge + excess_power, battery_capacity].min
      if new_charge > current_charge
        battery_unit.operational_data['battery']['current_charge'] = new_charge
        battery_unit.save!
        puts "  🔋 Battery charged: +#{(new_charge - current_charge).round(2)} kWh (#{new_charge.round(2)}/#{battery_capacity} kWh)"
      end
    end
  end
  if mined_amount_this_day.positive?
    ldc_gcc_account.deposit(mined_amount_this_day, "GCC mining day #{day + 1} from #{satellite.name}")
    puts "  ⛏️  Mined: #{mined_amount_this_day} GCC. Deposited. Current LDC Balance: #{ldc_gcc_account.balance.to_f} GCC"
  else
    puts "  ⚠️ No GCC mined this day"
  end
  puts "  ⚡ Power status: #{satellite.power_generation.round(2)} kW generation, #{satellite.power_usage.round(2)} kW usage"
  sleep(0.2)
end

# === 13. Bond Maturity and Repayment ===
puts "\n13. Bond Maturity and Repayment..."
exchange_service = ExchangeRateService.new({ ["USD", "GCC"] => 1.0 }) # Set your rate here

bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)
bonds.each do |bond|
  current_date = Date.new(game_state.year, 1, 1) + (game_state.day - 1)
  if current_date >= bond.due_at
    gcc_amount = exchange_service.convert(bond.amount, "USD", "GCC").round(2)
    available_gcc = ldc_gcc_account.balance.to_f

    if available_gcc >= gcc_amount
      ldc_gcc_account.transfer_funds(gcc_amount, astrolift_gcc_account, "Bond repayment in GCC for Bond ##{bond.id}")
      bond.update!(status: :paid)
      puts "💸 Bond ##{bond.id} repaid: #{gcc_amount} GCC transferred to AstroLift."
    else
      puts "⚠️ Not enough GCC to repay Bond ##{bond.id}. Outstanding: #{gcc_amount} GCC, Available: #{available_gcc} GCC"
    end
  else
    puts "⏳ Bond ##{bond.id} not yet matured. Due: #{bond.due_at.strftime('%Y-%m-%d')}"
  end
end

# === 14. Final Verification ===
puts "\n✅ Final Satellite Status:"
puts "  - Satellite: #{satellite.name}"
puts "  - Owner: #{satellite.owner.name}"
puts "  - Online: #{satellite.deployed? ? 'Yes' : 'No'}"
puts "  - Units: #{satellite.base_units.count}"

ldc_gcc_account.reload
ldc_usd_account.reload
puts "  - LDC GCC Account Balance: #{ldc_gcc_account.balance.to_f} GCC"
puts "  - LDC USD Account Balance: #{ldc_usd_account.balance.to_f} USD"

astrolift_gcc_account.reload
astrolift_usd_account.reload
puts "  - AstroLift GCC Account Balance: #{astrolift_gcc_account.balance.to_f} GCC"
puts "  - AstroLift USD Account Balance: #{astrolift_usd_account.balance.to_f} USD"

# === Outstanding Bonds ===
puts "\n📜 Outstanding Bonds:"
outstanding_bonds = Bond.where(issuer: ldc, holder: astrolift, status: :issued)
if outstanding_bonds.any?
  outstanding_bonds.each do |bond|
    puts "  - Bond ID: #{bond.id}, Amount: #{bond.amount} #{bond.currency.symbol}, Issued: #{bond.issued_at.strftime('%Y-%m-%d')}, Due: #{bond.due_at&.strftime('%Y-%m-%d')}, Status: #{bond.status}"
  end
else
  puts "  - None"
end

begin
  if MiningLog.table_exists?
    mining_logs = MiningLog.where(owner: satellite)
    puts "  - Mining Logs: #{mining_logs.count}"
  else
    puts "  ⚠️ MiningLog table not found. Did you run `rails db:migrate` after creating the migration?"
  end
rescue ActiveRecord::ActiveRecordError => e
  puts "  ❌ Error accessing MiningLogs: #{e.message}. Ensure database is set up correctly."
end

battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
if battery_unit
  puts "  - Battery Level: #{charge.round(2)}/#{capacity} kWh (#{(charge/capacity*100).round(1)}%)"
end

puts "\n🏁 Integration test complete!"
