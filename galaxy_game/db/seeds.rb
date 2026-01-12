require_relative 'seeds/calculators'

# Build the Sol star system using StarSim from JSON data
puts "Building Sol star system..."
StarSim::SystemBuilderService.new(name: 'Sol', debug_mode: true).build!

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

# Create initial corporations
puts "Creating initial corporations..."
ldc = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Lunar Development Corporation',
  identifier: 'LDC',
  organization_type: :corporation
)

astrolift = Organizations::BaseOrganization.find_or_create_by!(
  name: 'AstroLift',
  identifier: 'ASTROLIFT',
  organization_type: :corporation
)

zenith = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Zenith Orbital',
  identifier: 'ZENITH',
  organization_type: :corporation
)

vector = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Vector Hauling',
  identifier: 'VECTOR',
  organization_type: :corporation
)

# Create Wormhole Transit Consortium
consortium = Organizations::BaseOrganization.find_or_create_by!(
  name: 'Wormhole Transit Consortium',
  identifier: 'WH-CONSORTIUM',
  organization_type: :consortium,
  operational_data: {}
)