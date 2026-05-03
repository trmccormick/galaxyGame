# Database Cleaner Configuration
# Keeps core reference data (celestial bodies, materials) intact between tests

require 'database_cleaner'

# Allow remote database URL for test environment BEFORE any DatabaseCleaner operations
DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean all tables EXCEPT core reference data
    # Note: celestial_bodies and materials have FK relationships, both must be preserved
    # Using :deletion instead of :truncation to avoid PostgreSQL deadlocks (2026-01-18)
    DatabaseCleaner.clean_with(:deletion, except: %w[
      galaxies
      solar_systems
      celestial_bodies
      locations
      materials
      ar_internal_metadata
      schema_migrations
    ])

    # Re-seed world constants after suite-level clean.
    # Sol bodies, currencies, and NPC orgs must always exist before any spec runs.
    # All calls use find_or_create — safe to run multiple times.
    # See docs/agent/TEST_ENVIRONMENT_SETUP.md for full explanation.
    StarSim::SystemBuilderService.new(name: 'sol', debug_mode: false).build!
    Financial::Currency.find_or_create_by!(
      symbol: 'GCC',
      name: 'Galactic Crypto Currency',
      is_system_currency: true,
      precision: 8
    )
    Financial::Currency.find_or_create_by!(
      symbol: 'USD',
      name: 'US Dollar',
      is_system_currency: true,
      precision: 2
    )
    Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |o|
      o.name = 'Lunar Development Corporation'
      o.organization_type = :development_corporation
      o.operational_data = { 'is_npc' => true }
    end
    Organizations::BaseOrganization.find_or_create_by!(identifier: 'ASTROLIFT') do |o|
      o.name = 'AstroLift'
      o.organization_type = :corporation
      o.operational_data = { 'is_npc' => true }
    end
  end

  config.before(:each) do |example|
    # For most tests, use transaction strategy (fast, isolated)
    # Transactions automatically rollback, preserving seed data
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.before(:each, js: true) do
    # For JavaScript/feature tests, use deletion instead of truncation
    # to avoid deadlocks while still preserving core tables
    DatabaseCleaner.strategy = :deletion, {
      except: %w[
        galaxies
        solar_systems
        celestial_bodies
        locations
        materials
        ar_internal_metadata
        schema_migrations
      ]
    }
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
