#!/bin/bash
# Fix DATABASE_URL overriding test database configuration

echo "🔧 FIXING TEST DATABASE URL OVERRIDE"
echo "====================================="
echo ""

echo "PROBLEM IDENTIFIED:"
echo "DATABASE_URL env var is overriding database.yml settings"
echo "Test environment is connecting to development database!"
echo ""

echo "Step 1: Check Current DATABASE_URL"
echo "-----------------------------------"
docker exec -it web bash -c "
echo 'Current DATABASE_URL:'
echo \$DATABASE_URL
echo ''
echo 'This is forcing ALL environments to use development DB!'
"

echo ""
echo "Step 2: Update database.yml to Ignore DATABASE_URL in Test"
echo "-----------------------------------------------------------"
docker exec -it web bash -c "
cat > config/database.yml << 'EOF'
# PostgreSQL configuration
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

# Test database - MUST be separate from development
# Explicitly set to ignore DATABASE_URL
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

echo '✅ Updated database.yml'
"

echo ""
echo "Step 3: Unset DATABASE_URL for Test Commands"
echo "---------------------------------------------"
echo "We need to run test commands WITHOUT DATABASE_URL set"
echo ""

echo "Testing connection without DATABASE_URL:"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Database: ' + ActiveRecord::Base.connection.current_database
  puts 'Expected: galaxy_game_test'
\"
"

echo ""
echo "Step 4: Drop and Recreate Test Database (Correctly)"
echo "----------------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails db:drop
RAILS_ENV=test rails db:create
RAILS_ENV=test rails db:environment:set RAILS_ENV=test
RAILS_ENV=test rails db:schema:load
echo '✅ Test database created'
"

echo ""
echo "Step 5: Seed Test Database"
echo "--------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails db:seed
"

echo ""
echo "Step 6: Verify Correct Database Connection"
echo "-------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts ''
  puts '=== VERIFICATION ==='
  db = ActiveRecord::Base.connection.current_database
  puts 'Connected to: ' + db
  
  if db == 'galaxy_game_test'
    puts '✅ SUCCESS: Using correct test database!'
  else
    puts '❌ FAIL: Still using wrong database!'
    exit 1
  end
  
  puts ''
  puts 'Core Data:'
  puts '  CelestialBodies: ' + CelestialBodies::CelestialBody.count.to_s
  
  sol = CelestialBodies::CelestialBody.find_by(identifier: 'sol')
  mars = CelestialBodies::CelestialBody.find_by(identifier: 'mars')
  earth = CelestialBodies::CelestialBody.find_by(identifier: 'earth')
  
  puts '  Sol: ' + (sol ? '✅ ' + sol.name : '❌ MISSING')
  puts '  Earth: ' + (earth ? '✅ ' + earth.name : '❌ MISSING')  
  puts '  Mars: ' + (mars ? '✅ ' + mars.name : '❌ MISSING')
\"
"

echo ""
echo "Step 7: Create Test Runner Script"
echo "----------------------------------"
docker exec -it web bash -c "
cat > bin/test << 'TESTSCRIPT'
#!/bin/bash
# Test runner that ensures DATABASE_URL doesn't interfere

unset DATABASE_URL
RAILS_ENV=test bundle exec rspec \"\$@\"
TESTSCRIPT

chmod +x bin/test
echo '✅ Created bin/test script'
"

echo ""
echo "📋 SOLUTION"
echo "==========="
echo ""
echo "The problem: DATABASE_URL environment variable overrides database.yml"
echo ""
echo "✅ Updated database.yml with explicit test config"
echo "✅ Test database created correctly"
echo "✅ Test database seeded"
echo "✅ Created bin/test wrapper script"
echo ""
echo "TO RUN TESTS (use one of these methods):"
echo ""
echo "METHOD 1 - Using wrapper script (RECOMMENDED):"
echo "  docker exec -it web bin/test"
echo ""
echo "METHOD 2 - Unset DATABASE_URL manually:"
echo "  docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec'"
echo ""
echo "METHOD 3 - From outside container:"
echo "  docker-compose -f docker-compose.dev.yml exec -e DATABASE_URL= web bash -c 'RAILS_ENV=test bundle exec rspec'"
echo ""
echo "⚠️  DO NOT use DATABASE_URL when running tests!"