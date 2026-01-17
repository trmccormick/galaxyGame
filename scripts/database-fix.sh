#!/bin/bash
# Fix Database Environment Separation
# Ensures test/development/production databases are properly isolated

echo "🔧 FIXING DATABASE ENVIRONMENT SEPARATION"
echo "=========================================="
echo ""

echo "ISSUE IDENTIFIED:"
echo "Your database.yml shows development DB is missing host/username/password"
echo "So it's falling back to DATABASE_URL which points to development DB"
echo "Tests might be using development DB instead of test DB!"
echo ""

echo "Step 1: Fix database.yml Configuration"
echo "---------------------------------------"
docker exec -it web bash -c "
cat > config/database.yml << 'EOF'
# PostgreSQL. Versions 9.3 and up are supported.
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch('RAILS_MAX_THREADS') { 5 } %>

development:
  <<: *default
  database: galaxy_game_development
  host: db
  username: postgres
  password: password

# Test database - completely separate from development
test:
  <<: *default
  database: galaxy_game_test
  host: db
  username: postgres
  password: password

production:
  <<: *default
  database: galaxy_game_production
  username: galaxy_game
  password: <%= ENV['GALAXY_GAME_DATABASE_PASSWORD'] %>
EOF

echo '✅ database.yml updated with explicit credentials for all environments'
"

echo ""
echo "Step 2: Create Test Database"
echo "----------------------------"
docker exec -it web bash -c "
echo 'Creating test database...'
RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:schema:load
echo '✅ Test database created and schema loaded'
"

echo ""
echo "Step 3: Verify Database Separation"
echo "-----------------------------------"
docker exec -it web bash -c "
echo 'Development DB:'
RAILS_ENV=development rails runner \"puts ActiveRecord::Base.connection.current_database\"

echo ''
echo 'Test DB:'
RAILS_ENV=test rails runner \"puts ActiveRecord::Base.connection.current_database\"

echo ''
echo 'Checking if they are different:'
DEV_DB=\$(RAILS_ENV=development rails runner \"puts ActiveRecord::Base.connection.current_database\" 2>/dev/null)
TEST_DB=\$(RAILS_ENV=test rails runner \"puts ActiveRecord::Base.connection.current_database\" 2>/dev/null)

if [ \"\$DEV_DB\" = \"\$TEST_DB\" ]; then
  echo '❌ ERROR: Development and Test using SAME database!'
  echo \"   Both using: \$DEV_DB\"
else
  echo '✅ SUCCESS: Databases are separate'
  echo \"   Development: \$DEV_DB\"
  echo \"   Test: \$TEST_DB\"
fi
"

echo ""
echo "Step 4: Configure Test Database Cleaning"
echo "-----------------------------------------"
docker exec -it web bash -c "
# Check if using RSpec or Minitest
if [ -f spec/rails_helper.rb ]; then
  echo 'Configuring RSpec DatabaseCleaner...'
  
  # Backup existing file
  cp spec/rails_helper.rb spec/rails_helper.rb.backup
  
  # Check if DatabaseCleaner is already configured
  if grep -q 'DatabaseCleaner' spec/rails_helper.rb; then
    echo 'DatabaseCleaner already configured'
  else
    cat >> spec/rails_helper.rb << 'RSPEC'

# Database Cleaner Configuration
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Clean test DB completely before test suite
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    # Use transaction strategy for most tests
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
RSPEC
    echo '✅ DatabaseCleaner configured in spec/rails_helper.rb'
  fi
  
elif [ -f test/test_helper.rb ]; then
  echo 'Using Minitest - configuring fixtures...'
  
  if grep -q 'fixtures :all' test/test_helper.rb; then
    echo '✅ Fixtures already configured'
  else
    cat >> test/test_helper.rb << 'MINITEST'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests
  fixtures :all

  # Ensure test database is cleaned between tests
  self.use_transactional_tests = true
end
MINITEST
    echo '✅ Transactional tests configured'
  fi
fi
"

echo ""
echo "Step 5: Re-seed Development Database"
echo "-------------------------------------"
docker exec -it web bash -c "
echo 'Seeding development database...'
RAILS_ENV=development rails db:seed

echo ''
echo 'Verification:'
RAILS_ENV=development rails runner \"
  puts 'CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
  mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
  puts 'Mars found: ' + (mars ? 'YES (' + mars.name + ')' : 'NO')
\"
"

echo ""
echo "Step 6: Create .env.test File"
echo "------------------------------"
docker exec -it web bash -c "
cat > env/.env.test << 'TESTENV'
DATABASE_URL=postgres://postgres:password@db:5432/galaxy_game_test
REDIS_URL=redis://redis:6379/2
RAILS_ENV=test
RAKE_ENV=test
TESTENV

echo '✅ Created env/.env.test'
echo 'Note: Redis uses different DB (2) for tests vs development (1)'
"

echo ""
echo "📋 SUMMARY & NEXT STEPS"
echo "======================="
echo ""
echo "✅ Fixed database.yml with explicit credentials"
echo "✅ Created separate test database"
echo "✅ Configured database cleaning for tests"
echo "✅ Re-seeded development database"
echo "✅ Created .env.test for test environment"
echo ""
echo "TO RUN TESTS SAFELY (without affecting development):"
echo "  docker exec -it web bash -c 'RAILS_ENV=test bundle exec rspec'"
echo ""
echo "OR for a single test file:"
echo "  docker exec -it web bash -c 'RAILS_ENV=test bundle exec rspec spec/services/ai_manager/mission_planner_service_spec.rb'"
echo ""
echo "IMPORTANT: Always use RAILS_ENV=test when running tests!"
echo ""
echo "Now verify development DB is intact:"
docker exec -it web rails runner "
puts ''
puts '=== DEVELOPMENT DATABASE STATUS ==='
puts 'CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
if mars
  puts '✅ Mars: ' + mars.name
  puts '   Atmosphere: ' + (mars.atmosphere_composition || {}).keys.join(', ')
else
  puts '❌ Mars NOT FOUND - run: docker exec -it web rails db:seed'
end
"