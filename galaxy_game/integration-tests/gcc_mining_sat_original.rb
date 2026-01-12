require 'json'
require 'securerandom'

# IMPORTANT: This script assumes it's being run within a Rails environment
# (e.g., using `rails runner path/to/this_script.rb`).
# This means:
# 1. All your Rails models in `app/models/` (like Account, Currency, Organization,
#    CelestialBody, Craft, Unit, Transaction, AND NOW MiningLog) are automatically
#    loaded by Rails. We DO NOT redefine them here.
# 2. Database connection is already established by Rails.
# 3. Lookup services (GalaxyGame::Paths, Lookup::CraftLookupService, Lookup::UnitLookupService)
#    are accessible, implying their files are loaded too.


puts "\n🚀 Starting Full GCC Mining Satellite Integration Test..."

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

# 3. Load mission profile and extract location
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

# 4. Setup celestial context (e.g. Earth) and owning organization
puts "\n4. Setting up orbiting context and LDC..."

# Find existing Earth - it's already in the database
earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.where(name: "Earth").first
if earth.nil?
  puts "⚠️ Warning: Earth not found in database, seeded data may be missing"
  puts "🔍 Attempting to find Earth with any class type..."
  earth = CelestialBodies::CelestialBody.where(name: "Earth").first

  if earth.nil?
    puts "❌ Earth not found with any type. Check database seeding."
    exit 1
  else
    puts "✅ Found Earth with type: #{earth.type}"
  end
else
  puts "✅ Found Earth (ID: #{earth.id}, Identifier: #{earth.identifier})"
end

# Create a celestial location for planetary orbit around Earth
orbit_location = Location::CelestialLocation.find_or_create_by!(
  name: start_location_type.humanize,
  coordinates: "0.00°N 0.00°E", # Generic coordinates for orbit
  celestial_body: earth
)
puts "✅ Using location: #{orbit_location.name} (ID: #{orbit_location.id})"

# Create or find Lunar Development Corporation (LDC)
ldc = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Lunar Development Corporation',
  identifier: 'LDC',
  organization_type: :corporation
)
puts "✅ Using organization: #{ldc.name} (ID: #{ldc.id})"

# --- NEW: Setup Currencies and LDC Accounts ---
puts "\n5. Setting up Currencies and LDC Accounts..."
# Find the GCC Currency (should be seeded via db/seeds.rb)
gcc_currency = Currency.find_by(symbol: 'GCC')
usd_currency = Currency.find_by(symbol: 'USD') # Also get USD currency

if gcc_currency.nil? || usd_currency.nil?
  puts "❌ ERROR: GCC or USD Currency not found. Please run `rails db:seed`."
  exit 1
end
puts "✅ Found GCC Currency (ID: #{gcc_currency.id}, Symbol: #{gcc_currency.symbol})"
puts "✅ Found USD Currency (ID: #{usd_currency.id}, Symbol: #{usd_currency.symbol})"

# Find or create LDC's GCC Account using the new helper
ldc_gcc_account = Account.find_or_create_for_entity_and_currency(
  accountable_entity: ldc,
  currency: gcc_currency
)
puts "✅ LDC's GCC Account: ID #{ldc_gcc_account.id}, Initial Balance: #{ldc_gcc_account.balance.to_f} #{ldc_gcc_account.currency.symbol}"

# Find or create LDC's USD Account using the new helper
ldc_usd_account = Account.find_or_create_for_entity_and_currency(
  accountable_entity: ldc,
  currency: usd_currency
)
puts "✅ LDC's USD Account: ID #{ldc_usd_account.id}, Initial Balance: #{ldc_usd_account.balance.to_f} #{ldc_usd_account.currency.symbol}"


# --- NEW: Setup AstroLift Corporation and their accounts ---
puts "\n6. Setting up AstroLift Corporation and their accounts..."
spacex = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift Corporation',
  identifier: 'ASTROLIFT',
  organization_type: :corporation
)
puts "✅ Using organization: #{spacex.name} (ID: #{spacex.id})"

# Find or create AstroLift Corporation's GCC Account
spacex_gcc_account = Account.find_or_create_for_entity_and_currency(
  accountable_entity: spacex,
  currency: gcc_currency
)
puts "✅ AstroLift Corporation's GCC Account: ID #{spacex_gcc_account.id}, Balance: #{spacex_gcc_account.balance.to_f} GCC"

# Find or create AstroLift Corporation's USD Account
spacex_usd_account = Account.find_or_create_for_entity_and_currency(
  accountable_entity: spacex,
  currency: usd_currency
)
puts "✅ AstroLift Corporation's USD Account: ID #{spacex_usd_account.id}, Balance: #{spacex_usd_account.balance.to_f} USD"


# === 7. Create Satellite ===
puts "\n7. Creating satellite..."

# Use CraftLookupService to find the satellite operational data
craft_lookup_service = Lookup::CraftLookupService.new
satellite_data = craft_lookup_service.find_craft("crypto_mining_satellite")

if satellite_data.nil?
  puts "❌ ERROR: Could not find operational data for crypto_mining_satellite"
  puts "Please ensure the operational data file exists at:"
  puts "  /home/galaxy_game/app/data/operational_data/crafts/space/satellites/crypto_mining_satellite_data.json"
  exit 1
else
  puts "✅ Found satellite operational data: #{satellite_data['name'] || satellite_data['id']}"
end

# Create the satellite with the operational data directly from lookup service
satellite = Craft::Satellite::BaseSatellite.create!(
  name: "GCCSat-#{SecureRandom.hex(4)}",
  craft_name: satellite_data['name'] || "Cryptocurrency Mining Satellite",
  craft_type: satellite_data['subcategory'] || "space/satellites/mining",
  owner: ldc,
  deployed: false,
  operational_data: satellite_data  # Use the operational data directly
)

# Now correctly associate with the orbit location and deploy the satellite
orbit_location.update(locationable: satellite)
satellite.reload

# Before deploying, check if the location is valid
valid_locations = satellite_data.dig('deployment', 'deployment_locations') || []
if valid_locations.include?(start_location_type)
  satellite.deploy(start_location_type, celestial_body: earth)
else
  puts "⚠️ Profile location type '#{start_location_type}' not supported by satellite."
  puts "✅ Using 'orbital' instead of '#{start_location_type}'."
  satellite.deploy('orbital', celestial_body: earth)
end
satellite.reload

puts "✔ Created satellite: #{satellite.name} in orbit around #{earth.name}"

# --- NEW: Port Capacity Check ---
# Get recommended fit arrays from operational data
recommended_fit = satellite.operational_data['recommended_fit'] || {}
recommended_units = recommended_fit['units'] || []
recommended_modules = recommended_fit['modules'] || []
recommended_rigs = recommended_fit['rigs'] || []

# Get all available ports from operational data
available_ports = satellite.operational_data['ports'] || {}

# Map unit categories to port types
PORT_MAP = {
  'computers' => 'internal_unit_ports',
  'energy' => 'external_unit_ports',
  'propulsion' => ['propulsion_ports', 'external_unit_ports'],
  'storage' => 'internal_fuel_storage_ports',
  # Add more as needed
}

required_ports = Hash.new(0)
recommended_units.each do |unit|
  category = unit['category'] || 'unit'
  port_type = PORT_MAP[category] || 'internal_unit_ports'
  if port_type.is_a?(Array)
    # Try to fit on any available port type
    fitted = false
    port_type.each do |pt|
      if (available_ports[pt] || 0) > (required_ports[pt] || 0)
        required_ports[pt] += unit['count'] || 1
        fitted = true
        break
      end
    end
    required_ports[port_type.first] += unit['count'] || 1 unless fitted
  else
    required_ports[port_type] += unit['count'] || 1
  end
end

MODULE_PORT_MAP = {
  'internal' => 'internal_module_ports',
  'external' => 'external_module_ports'
}
recommended_modules.each do |mod|
  location = mod['location'] || 'internal'
  port_type = MODULE_PORT_MAP[location] || 'internal_module_ports'
  required_ports[port_type] += mod['count'] || 1
end

RIG_PORT_MAP = {
  'internal' => 'internal_rig_ports',
  'external' => 'external_rig_ports'
}
recommended_rigs.each do |rig|
  location = rig['location'] || 'internal'
  port_type = RIG_PORT_MAP[location] || 'internal_rig_ports'
  required_ports[port_type] += rig['count'] || 1
end

puts "\n🔎 Port Capacity Check:"
available_ports.each do |port_type, port_count|
  req_count = required_ports[port_type] || 0
  puts "  - #{port_type.humanize}: #{port_count}, Required: #{req_count}"
  if req_count > port_count
    puts "❌ ERROR: Recommended fit exceeds available #{port_type} (#{req_count} > #{port_count})"
    exit 1
  end
end

puts "✅ Port capacity checks passed."

# === 8. Install Units ===
puts "\n8. Installing recommended units..."

# Get the unit lookup service
unit_lookup_service = Lookup::UnitLookupService.new
missing_units = []

# Access recommended units correctly from satellite_data
recommended_units = satellite_data.dig('recommended_fit', 'units')
if recommended_units.is_a?(Array) && recommended_units.any?
  recommended_units.each do |unit|
    unit_id = unit['id']
    count = unit['count'] || 1

    # Verify unit type exists in system
    unit_data = unit_lookup_service.find_unit(unit_id)
    if unit_data.nil?
      missing_units << unit_id
      puts "  ❌ Unknown unit type: #{unit_id}"
      next
    end

    puts "  - Installing #{count}x #{unit_id}"
    count.times do |i|
      # Create a unique identifier for each unit
      unit_identifier = "#{unit_id.upcase}_#{satellite.name}_#{i + 1}_#{SecureRandom.hex(4)}"

      # For computer units, explicitly create the Computer class
      if unit_id.include?('computer')
        klass = Units::Computer
      # For battery units, handle them specially
      elsif unit_id == 'satellite_battery'
        klass = Units::Battery
      else
        klass = Units::BaseUnit
      end

      # Create the unit first
      unit = klass.new(
        name: "#{unit_id}_#{i + 1}",
        unit_type: unit_id,
        owner: ldc,
        identifier: unit_identifier,
        operational_data: unit_data
      )

      # Then properly install it using the BaseCraft method
      if unit.save && satellite.install_unit(unit)
        puts "    ✅ Installed #{unit_id} (ID: #{unit.id})"
      else
        puts "    ❌ Failed to install #{unit_id}: #{unit.errors.full_messages.join(', ')}"
      end
    end
  end

  # Fail if any required units were missing
  if missing_units.any?
    puts "❌ ERROR: The following unit types are required but not defined in the system:"
    missing_units.each { |u| puts "  - #{u}" }
    puts "Please ensure these unit definitions exist in your data files."
    exit 1
  end
else
  puts "❌ ERROR: No units found in satellite operational data"
  puts "Satellite operational data lacks proper recommended_fit.units array"
  exit 1
end

# === 8b. Verifying power systems...
puts "\n8b. Verifying power systems..."

# Check power generation
power_gen = satellite.power_generation
power_use = satellite.power_usage
power_balance = power_gen - power_use

puts "  - Power Generation: #{power_gen.round(2)} kW"
puts "  - Power Usage: #{power_use.round(2)} kW"
puts "  - Power Balance: #{power_balance.round(2)} kW"

# Check battery status - proper check for installed battery units
battery_units = satellite.base_units.select { |unit| unit.unit_type == 'satellite_battery' }
if battery_units.any?
  battery_unit = battery_units.first

  # Get battery capacity from operational data
  battery_capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
  battery_charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0

  puts "  - Battery Unit: #{battery_unit.name}"
  puts "  - Battery Capacity: #{battery_capacity.round(2)} kWh"
  puts "  - Current Charge: #{battery_charge.round(2)} kWh (#{(battery_charge / battery_capacity * 100).round(1)}%)"

  if power_balance < 0
    puts "  ⚠️ WARNING: Power deficit detected. Mining will rely on batteries."

    # Estimate how long battery will last
    hours_remaining = battery_charge / power_use.abs
    puts "  - Estimated battery duration: #{hours_remaining.round(1)} hours"
  else
    puts "  ✅ Power systems nominal. Generating surplus of #{power_balance.round(2)} kW"
  end
else
  puts "  ⚠️ WARNING: No battery units installed. Mining will halt during eclipses."
end

# === 9. Initial Mining Test ===
puts "\n9. Performing first mining cycle..."
# satellite.mine_gcc should return the amount mined
initial_gcc_amount = satellite.mine_gcc
if initial_gcc_amount.positive?
  # Deposit the mined amount into LDC's GCC account
  begin
    ldc_gcc_account.deposit(initial_gcc_amount, "Initial GCC mining from #{satellite.name}")
    puts "✔ Initial GCC mined: #{initial_gcc_amount}. Deposited to LDC Account. New Balance: #{ldc_gcc_account.balance.to_f} GCC"
  rescue => e
    puts "❌ Failed to deposit initial GCC: #{e.message}"
  end
else
  puts "❌ No GCC mined in first cycle"
end


# === 10. Simulated Task Loop (In-Game Time) ===
puts "\n10. Simulating time-based mining..."
simulated_cycles = task_list.any? ? task_list.size : 5

simulated_cycles.times do |i|
  puts "\n⏱️ Cycle #{i + 1}..."

  # Check power status before mining
  power_status = satellite.power_generation >= satellite.power_usage

  mined_amount_this_cycle = 0 # Initialize for this cycle

  if !power_status
    puts "  ⚠️ Power deficit detected. Checking battery..."

    # Get the first battery unit
    battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }

    if battery_unit && (battery_unit.operational_data.dig('battery', 'current_charge') || 0) > 0
      # Get current battery charge
      battery_charge_before = battery_unit.operational_data.dig('battery', 'current_charge') || 0

      # Calculate power needed for this cycle (assume 1 hour)
      power_needed = satellite.power_usage - satellite.power_generation

      # Check if battery has enough charge
      if battery_charge_before >= power_needed
        # Discharge the battery
        new_charge = battery_charge_before - power_needed
        battery_unit.operational_data['battery']['current_charge'] = new_charge
        battery_unit.save!

        puts "  🔋 Battery used: #{power_needed.round(2)} kWh (#{new_charge.round(2)} kWh remaining)"

        # Perform mining with the battery power
        mined_amount_this_cycle = satellite.mine_gcc
      else
        puts "  ❌ Insufficient battery charge for mining"
        mined_amount_this_cycle = 0
      end
    else
      puts "  ❌ No battery available for mining"
      mined_amount_this_cycle = 0
    end
  else
    # Normal mining with surplus power
    mined_amount_this_cycle = satellite.mine_gcc

    # If we have a battery, charge it with excess power
    battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
    if battery_unit
      battery_capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
      current_charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
      max_charge_rate = battery_unit.operational_data.dig('battery', 'max_charge_rate_kw') || 10.0 # Default if not set

      # Calculate how much power we can use to charge the battery
      excess_power = [power_balance, max_charge_rate].min

      # Don't exceed battery capacity
      new_charge = [current_charge + excess_power, battery_capacity].min

      # Only update if we actually charged the battery
      if new_charge > current_charge
        battery_unit.operational_data['battery']['current_charge'] = new_charge
        battery_unit.save!
        puts "  🔋 Battery charged: +#{(new_charge - current_charge).round(2)} kWh (#{new_charge.round(2)}/#{battery_capacity} kWh)"
      end
    end
  end

  # Deposit mined amount to LDC's GCC account
  if mined_amount_this_cycle.positive?
    begin
      ldc_gcc_account.deposit(mined_amount_this_cycle, "GCC mining cycle #{i + 1} from #{satellite.name}")
      puts "  ⛏️  Mined: #{mined_amount_this_cycle} GCC. Deposited. Current LDC Balance: #{ldc_gcc_account.balance.to_f} GCC"
    rescue => e
      puts "  ❌ Failed to deposit mined GCC this cycle: #{e.message}"
    end
  else
    puts "  ⚠️ No GCC mined this cycle"
  end

  # Add a power status update after mining
  puts "  ⚡ Power status: #{satellite.power_generation.round(2)} kW generation, #{satellite.power_usage.round(2)} kW usage"

  sleep(0.2) # simulate a pause per cycle (optional)
end

# --- NEW: LDC Receiving a Grant (USD) ---
puts "\n11. LDC receiving a USD grant..."
grant_amount = 5000.0
begin
  # The ldc_usd_account was already created in step 5 using find_or_create_for_entity_and_currency
  ldc_usd_account.deposit(grant_amount, "Grant from Earth UN Space Agency")
  puts "✅ LDC received #{grant_amount} USD. New LDC USD Balance: #{ldc_usd_account.balance.to_f} USD"
rescue => e
  puts "❌ Error receiving USD grant: #{e.message}"
end


# --- NEW: LDC Paying AstroLift Corporation ---
puts "\n12. LDC paying AstroLift Corporation for supplies..."
cost_in_gcc = 250.0
cost_in_usd = 150.0

# Ensure LDC has funds in its GCC account (e.g., from mining)
ldc_gcc_account.reload # Reload to get latest balance after mining cycles
if ldc_gcc_account.balance < cost_in_gcc
  puts "⚠️ LDC GCC balance too low for GCC purchase. Current: #{ldc_gcc_account.balance.to_f} GCC, Needed: #{cost_in_gcc} GCC. Adding funds for test."
  ldc_gcc_account.deposit(cost_in_gcc * 2, "Test funds for GCC purchase") # Add more than needed
  ldc_gcc_account.reload
end
puts "LDC GCC Balance before purchase: #{ldc_gcc_account.balance.to_f} GCC"

# Payment in GCC
begin
  ldc_gcc_account.transfer_funds(cost_in_gcc, spacex_gcc_account, "Purchase of mining equipment (GCC)")
  puts "✅ LDC paid #{cost_in_gcc} GCC to AstroLift Corporation. LDC GCC Balance: #{ldc_gcc_account.balance.to_f} GCC"
  puts "   AstroLift Corporation GCC Balance: #{spacex_gcc_account.reload.balance.to_f} GCC"
rescue => e
  puts "❌ Error paying in GCC: #{e.message}"
end


# Payment in USD
ldc_usd_account.reload # Reload to get latest balance after grant
if ldc_usd_account.balance < cost_in_usd
  puts "⚠️ LDC USD balance too low to pay AstroLift Corporation in USD. Current: #{ldc_usd_account.balance.to_f} USD, Needed: #{cost_in_usd} USD. Adding funds for test."
  ldc_usd_account.deposit(cost_in_usd * 2, "Test funds for USD purchase") # Add more than needed
  ldc_usd_account.reload
end
puts "LDC USD Balance before purchase: #{ldc_usd_account.balance.to_f} USD"

begin
  ldc_usd_account.transfer_funds(cost_in_usd, spacex_usd_account, "Launch service fee (USD)")
  puts "✅ LDC paid #{cost_in_usd} USD to AstroLift Corporation. LDC USD Balance: #{ldc_usd_account.balance.to_f} USD"
  puts "   AstroLift Corporation USD Balance: #{spacex_usd_account.reload.balance.to_f} USD"
rescue => e
  puts "❌ Error paying in USD: #{e.message}"
end


# === 13. Final Verification ===
puts "\n✅ Final Satellite Status:"
puts "  - Satellite: #{satellite.name}"
puts "  - Owner: #{satellite.owner.name}"
puts "  - Online: #{satellite.deployed? ? 'Yes' : 'No'}"
puts "  - Units: #{satellite.base_units.count}"

# Reload LDC accounts to show final balances
ldc_gcc_account.reload
ldc_usd_account.reload
puts "  - LDC GCC Account Balance: #{ldc_gcc_account.balance.to_f} #{ldc_gcc_account.currency.symbol}"
puts "  - LDC USD Account Balance: #{ldc_usd_account.balance.to_f} #{ldc_usd_account.currency.symbol}"

# Reload AstroLift Corporation accounts to show final balances
spacex_gcc_account.reload
spacex_usd_account.reload
puts "  - AstroLift Corporation GCC Account Balance: #{spacex_gcc_account.balance.to_f} #{spacex_gcc_account.currency.symbol}"
puts "  - AstroLift Corporation USD Account Balance: #{spacex_usd_account.balance.to_f} #{spacex_usd_account.currency.symbol}"


# Check for mining logs - now relying on the proper model definition
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


# Battery status at end
battery_unit = satellite.base_units.find { |unit| unit.unit_type == 'satellite_battery' }
if battery_unit
  capacity = battery_unit.operational_data.dig('battery', 'capacity') || 0
  charge = battery_unit.operational_data.dig('battery', 'current_charge') || 0
  puts "  - Battery Level: #{charge.round(2)}/#{capacity} kWh (#{(charge/capacity*100).round(1)}%)"
end

puts "\n🏁 Integration test complete!"

# After installing units and rigs, calculate mining rate boost from rigs
mining_rate_boost = 0
satellite.base_rigs.each do |rig|
  if rig.unit_type == 'gpu_coprocessor_rig'
    boost = rig.operational_data['processing_boost_gcc_per_hour'] || 0
    mining_rate_boost += boost
    puts "  - GPU Co-Processor Rig detected: +#{boost} GCC/hr mining rate"
  end
end

base_mining_rate = satellite.operational_data.dig('operational_properties', 'base_mining_rate_gcc_per_hour') || 0
total_mining_rate = base_mining_rate + mining_rate_boost

puts "  - Total Mining Rate: #{total_mining_rate} GCC/hr"

# Use total_mining_rate for mining cycles
satellite.define_singleton_method(:mine_gcc) do
  total_mining_rate
end

# Get all available ports from operational data
available_ports = satellite.operational_data['ports'] || {}

# Map unit categories to port types
PORT_MAP = {
  'computers' => 'internal_unit_ports',
  'energy' => 'external_unit_ports',
  'propulsion' => ['propulsion_ports', 'external_unit_ports'],
  'storage' => 'internal_fuel_storage_ports',
  # Add more as needed
}

required_ports = Hash.new(0)
(recommended_units || []).each do |unit|
  category = unit['category'] || 'unit'
  port_type = PORT_MAP[category] || 'internal_unit_ports'
  if port_type.is_a?(Array)
    # Try to fit on any available port type
    fitted = false
    port_type.each do |pt|
      if (available_ports[pt] || 0) > (required_ports[pt] || 0)
        required_ports[pt] += unit['count'] || 1
        fitted = true
        break
      end
    end
    required_ports[port_type.first] += unit['count'] || 1 unless fitted
  else
    required_ports[port_type] += unit['count'] || 1
  end
end

MODULE_PORT_MAP = {
  'internal' => 'internal_module_ports',
  'external' => 'external_module_ports'
}
(recommended_modules || []).each do |mod|
  location = mod['location'] || 'internal'
  port_type = MODULE_PORT_MAP[location] || 'internal_module_ports'
  required_ports[port_type] += mod['count'] || 1
end

RIG_PORT_MAP = {
  'internal' => 'internal_rig_ports',
  'external' => 'external_rig_ports'
}
(recommended_rigs || []).each do |rig|
  location = rig['location'] || 'internal'
  port_type = RIG_PORT_MAP[location] || 'internal_rig_ports'
  required_ports[port_type] += rig['count'] || 1
end

puts "\n🔎 Port Capacity Check:"
available_ports.each do |port_type, port_count|
  req_count = required_ports[port_type] || 0
  puts "  - #{port_type.humanize}: #{port_count}, Required: #{req_count}"
  if req_count > port_count
    puts "❌ ERROR: Recommended fit exceeds available #{port_type} (#{req_count} > #{port_count})"
    exit 1
  end
end

puts "✅ Port capacity checks passed."