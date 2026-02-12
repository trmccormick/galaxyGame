# Database Cleaner Configuration
# Keeps core reference data (celestial bodies, materials) intact between tests

# Allow remote database URL for test environment BEFORE any DatabaseCleaner operations
DatabaseCleaner.allow_remote_database_url = true

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean all tables EXCEPT core reference data
    # Note: celestial_bodies and materials have FK relationships, both must be preserved
    # Using :deletion instead of :truncation to avoid PostgreSQL deadlocks (2026-01-18)
    DatabaseCleaner.clean_with(:deletion, except: %w[
      celestial_bodies
      locations
      materials
      ar_internal_metadata
      schema_migrations
    ])
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
