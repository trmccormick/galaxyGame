# Database Cleaner Configuration
# Keeps core reference data (celestial bodies, materials) intact between tests

require 'database_cleaner'

# Allow remote database URL for test environment BEFORE any DatabaseCleaner operations
DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Ensure database connection is active after fresh reset
    # After `docker-compose down`, connection pool may be closed; reconnect before cleaner
    ActiveRecord::Base.connection_pool.disconnect!
    ActiveRecord::Base.establish_connection
    
    # Clean all tables EXCEPT core reference data
    # Note: celestial_bodies and materials have FK relationships, both must be preserved
    # Using :deletion instead of :truncation to avoid PostgreSQL deadlocks (2026-01-18)
    DatabaseCleaner.clean_with(:deletion, except: %w[
      galaxies
      solar_systems
      stars
      celestial_bodies
      atmospheres
      geospheres
      hydrospheres
      gases
      locations
      materials
      organizations
      ar_internal_metadata
      schema_migrations
    ])

    # Re-seed world constants after suite-level clean.
    # Sol bodies, currencies, and NPC orgs must always exist before any spec runs.
    # Sol celestial bodies are in the :except list so they persist across runs —
    # only call build! if Sol hasn't been seeded yet (first run or fresh DB).
    # See docs/agent/TEST_ENVIRONMENT_SETUP.md for full explanation.
    unless CelestialBodies::Star.exists?(name: 'Sol')
      StarSim::SystemBuilderService.new(name: 'sol', debug_mode: false).build!
    end
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
    if example.metadata[:uses_seeded_bodies]
      DatabaseCleaner.strategy = :deletion, {
        except: %w[
          galaxies solar_systems stars celestial_bodies
          atmospheres geospheres hydrospheres gases
          locations materials organizations ar_internal_metadata schema_migrations
        ]
      }
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.before(:each, js: true) do
    # For JavaScript/feature tests, use deletion instead of truncation
    # to avoid deadlocks while still preserving core tables
    DatabaseCleaner.strategy = :deletion, {
      except: %w[
        galaxies
        solar_systems
        stars
        celestial_bodies
        atmospheres
        geospheres
        hydrospheres
        gases
        locations
        materials
        organizations
        ar_internal_metadata
        schema_migrations
      ]
    }
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
