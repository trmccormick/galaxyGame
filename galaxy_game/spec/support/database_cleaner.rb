# Database Cleaner Configuration
# Keeps core reference data (celestial bodies, materials) intact between tests

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean all tables EXCEPT core reference data
    # Note: celestial_bodies and materials have FK relationships, both must be preserved
    DatabaseCleaner.clean_with(:truncation, except: %w[
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
    # For JavaScript/feature tests, use truncation
    # But still preserve core tables
    DatabaseCleaner.strategy = :truncation, {
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
