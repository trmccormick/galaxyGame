#!/bin/bash
# Prepare Test Database with Core Seed Data
# This ensures Sol, planets, materials always exist in tests

echo "🌟 PREPARING TEST DATABASE WITH SEED DATA"
echo "=========================================="
echo ""

echo "Step 1: Clean and Reset Test Database"
echo "--------------------------------------"
docker exec -it web bash -c "
echo 'Dropping and recreating test database...'
RAILS_ENV=test rails db:drop
RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:schema:load
echo '✅ Test database reset'
"

echo ""
echo "Step 2: Seed Test Database with Core Data"
echo "------------------------------------------"
docker exec -it web bash -c "
echo 'Seeding test database with core reference data...'
RAILS_ENV=test rails db:seed

echo ''
echo 'Verification - Core data in TEST database:'
RAILS_ENV=test rails runner \"
  puts 'CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
  
  # Check for essential bodies
  sol = CelestialBodies::CelestialBody.find_by(identifier: 'sol')
  mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
  earth = CelestialBodies::CelestialBody.find_by(identifier: 'earth')
  
  puts 'Sol: ' + (sol ? '✅ ' + sol.name : '❌ MISSING')
  puts 'Earth: ' + (earth ? '✅ ' + earth.name : '❌ MISSING')
  puts 'Mars: ' + (mars ? '✅ ' + mars.name : '❌ MISSING')
  
  # Check other core data
  puts ''
  puts 'Other Core Data:'
  puts 'Locations: ' + Location.count.to_s rescue puts 'Locations: N/A'
  puts 'Materials: ' + Material.count.to_s rescue puts 'Materials: N/A'
\"
"

echo ""
echo "Step 3: Verify Development Database Still Intact"
echo "-------------------------------------------------"
docker exec -it web bash -c "
echo 'Checking development database (should be unchanged)...'
RAILS_ENV=development rails runner \"
  puts 'CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
  mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
  puts 'Mars: ' + (mars ? '✅ ' + mars.name : '❌ MISSING - Need to re-seed dev!')
\"
"

echo ""
echo "Step 4: Configure RSpec to NOT Clean Core Tables"
echo "-------------------------------------------------"
docker exec -it web bash -c "
# Create or update spec/support/database_cleaner.rb
mkdir -p spec/support

cat > spec/support/database_cleaner.rb << 'DBCLEANER'
# Database Cleaner Configuration
# Keeps core reference data (celestial bodies, materials) intact between tests

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean all tables EXCEPT core reference data
    DatabaseCleaner.clean_with(:truncation, except: %w[
      celestial_bodies_celestial_bodies
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
        celestial_bodies_celestial_bodies
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
DBCLEANER

echo '✅ Created spec/support/database_cleaner.rb'
echo 'Core tables (celestial_bodies, locations, materials) will be preserved'
"

echo ""
echo "Step 5: Update spec/rails_helper.rb to Load Support Files"
echo "----------------------------------------------------------"
docker exec -it web bash -c "
if [ -f spec/rails_helper.rb ]; then
  # Check if support files are already loaded
  if ! grep -q 'Dir\[Rails.root.join.*support' spec/rails_helper.rb; then
    # Add support file loading after 'require rspec/rails'
    sed -i \"/require 'rspec\/rails'/a\\\\
\\\\
# Load support files\\\\
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }\" spec/rails_helper.rb
    echo '✅ Updated spec/rails_helper.rb to load support files'
  else
    echo '✅ spec/rails_helper.rb already loads support files'
  fi
else
  echo '⚠️  spec/rails_helper.rb not found - using default test setup'
fi
"

echo ""
echo "Step 6: Run a Quick Test to Verify Setup"
echo "-----------------------------------------"
docker exec -it web bash -c "
echo 'Running quick test to verify database state...'
RAILS_ENV=test rails runner \"
  puts ''
  puts '=== TEST DATABASE VERIFICATION ==='
  puts 'Environment: ' + Rails.env
  puts 'Database: ' + ActiveRecord::Base.connection.current_database
  puts ''
  puts 'Core Data Available:'
  puts '  CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
  puts '  Sol exists: ' + (CelestialBodies::CelestialBody.find_by(identifier: 'sol') ? 'YES ✅' : 'NO ❌')
  puts '  Mars exists: ' + (CelestialBodies::CelestialBody.find_by(identifier: 'mars') ? 'YES ✅' : 'NO ❌')
  puts ''
  puts 'If all core data shows ✅, you are ready to run tests!'
\"
"

echo ""
echo "📋 SUMMARY"
echo "=========="
echo ""
echo "✅ Test database reset and seeded with core data"
echo "✅ DatabaseCleaner configured to preserve core tables"
echo "✅ Development database unchanged"
echo ""
echo "NOW YOU CAN RUN TESTS SAFELY:"
echo ""
echo "  docker-compose -f docker-compose.dev.yml exec web bash -c \\"
echo "    \"RAILS_ENV=test bundle exec rspec > ./log/rspec_full_\\\$(date +%s).log 2>&1\""
echo ""
echo "OR run tests interactively:"
echo ""
echo "  docker exec -it web bash"
echo "  RAILS_ENV=test bundle exec rspec"
echo ""
echo "CORE DATA (Sol, planets, materials) will persist across test runs!"
echo "Only test-created data (missions, player data, etc.) will be cleaned."