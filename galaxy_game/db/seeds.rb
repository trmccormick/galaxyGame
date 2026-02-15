require_relative 'seeds/calculators'

# Build the Sol star system using StarSim from JSON data (complete version)
puts "Building Sol star system (complete version)..."
StarSim::SystemBuilderService.new(name: 'sol-complete', debug_mode: true).build!

# Build the Gaia star system (AOL-732356)
puts "Building Gaia star system (AOL-732356)..."
StarSim::SystemBuilderService.new(name: 'AOL-732356', debug_mode: true).build!

# Create system currencies
puts "Creating system currencies..."
usd_currency = Financial::Currency.find_or_create_by!(
  name: 'US Dollar',
  symbol: 'USD',
  is_system_currency: true,
  precision: 2
)

gcc_currency = Financial::Currency.find_or_create_by!(
  name: 'Galactic Crypto Currency',
  symbol: 'GCC',
  is_system_currency: true,
  precision: 8
)

# Create Development Corporations (planet-focused development)
puts "Creating Development Corporations..."
ldc = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Lunar Development Corporation',
  identifier: 'LDC',
  organization_type: :development_corporation,
  description: 'Lunar infrastructure and ISRU operations'
) do |org|
  org.operational_data = { 'is_npc' => true }
end

# Create logistics and service corporations
# Note: These companies compete for contracts but can collaborate on joint ventures
# for major infrastructure projects, similar to real-world business alliances
puts "Creating logistics corporations..."
astrolift = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift',
  identifier: 'ASTROLIFT',
  organization_type: :corporation,
  description: 'Orbital logistics and LEO depot operations'
) do |org|
  org.operational_data = { 'is_npc' => true, 'specialization' => 'orbital_logistics' }
end

zenith = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Zenith Orbital',
  identifier: 'ZENITH',
  organization_type: :corporation,
  description: 'Orbital station construction and management'
) do |org|
  org.operational_data = { 'is_npc' => true, 'specialization' => 'station_construction' }
end

vector = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Vector Hauling',
  identifier: 'VECTOR',
  organization_type: :corporation,
  description: 'Interplanetary cargo transport'
) do |org|
  org.operational_data = { 'is_npc' => true, 'specialization' => 'cargo_transport' }
end

# Note: Wormhole Transit Consortium is NOT created during initial seed
# It will be formed later during the "Snap Event" storyline when access to 
# the first extrasolar system is lost, forcing LDC and AstroLift to collaborate
# on artificial wormhole technology
puts "Note: Wormhole Transit Consortium will be created during Snap Event storyline"