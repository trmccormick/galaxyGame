#!/bin/bash
# Autonomous Nightly Grinder - Pre-flight & Launch
# Updated: 2026-01-17

echo "🚀 AUTONOMOUS NIGHTLY GRINDER - PRE-FLIGHT CHECKS"
echo "=================================================="
echo ""

# Step 1: Verify test database connection
echo "Step 1: Verifying test database connection..."
TEST_DB=$(docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts ActiveRecord::Base.connection.current_database"' 2>/dev/null | tr -d '\r')
if [[ "$TEST_DB" == *"galaxy_game_test"* ]]; then
    echo "✅ Connected to: galaxy_game_test"
else
    echo "❌ ERROR: Not connected to test database!"
    echo "   Current: $TEST_DB"
    echo "   Run: sh ./scripts/fix_test_database_url.sh"
    exit 1
fi
echo ""

# Step 2: Verify core seed data exists
echo "Step 2: Verifying test database has core data..."
BODY_COUNT=$(docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts CelestialBodies::CelestialBody.count"' 2>/dev/null | tail -1 | tr -d '\r\n ')
if [[ "$BODY_COUNT" =~ ^[0-9]+$ ]] && [[ "$BODY_COUNT" -ge 10 ]]; then
    echo "✅ Test database seeded: $BODY_COUNT celestial bodies"
else
    echo "⚠️  WARNING: Test database needs seeding (found: $BODY_COUNT)"
    echo "   Re-seeding test database..."
    docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails db:seed' > /dev/null 2>&1
    BODY_COUNT=$(docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test rails runner "puts CelestialBodies::CelestialBody.count"' 2>/dev/null | tail -1 | tr -d '\r\n ')
    echo "✅ Test database re-seeded: $BODY_COUNT celestial bodies"
fi
echo ""

# Step 3: Clear stale test cache
echo "Step 3: Clearing RSpec cache..."
docker exec -it web rm -f tmp/rspec_examples.txt 2>/dev/null
echo "✅ Cache cleared"
echo ""

# Step 4: Archive old logs
echo "Step 4: Archiving old log files..."
mkdir -p ./data/logs/archive
if ls ./data/logs/rspec_full_*.log 1> /dev/null 2>&1; then
    mv ./data/logs/rspec_full_*.log ./data/logs/archive/
    echo "✅ Old logs archived"
else
    echo "✅ No old logs to archive"
fi
echo ""

# Step 5: Generate fresh baseline log
echo "Step 5: Generating fresh baseline RSpec log..."
echo "   This will take several minutes..."
TIMESTAMP=$(date +%s)
LOG_FILE="./data/logs/rspec_full_${TIMESTAMP}.log"

docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec' > "$LOG_FILE" 2>&1

# Check log file size to verify it actually ran
LOG_SIZE=$(wc -c < "$LOG_FILE")
if [[ "$LOG_SIZE" -lt 1000 ]]; then
    echo "⚠️  WARNING: Log file is suspiciously small ($LOG_SIZE bytes)"
    echo "   Check: $LOG_FILE"
fi

# Count failures - look for both failure patterns

# If no failures, check if tests actually ran
if [[ "$TOTAL_FAILURES" == "0" ]]; then
    if [[ "$TOTAL_EXAMPLES" == "unknown" ]] || [[ "$TOTAL_EXAMPLES" == "0" ]]; then
        echo "❌ No tests appear to have run! Log may be incomplete."
        echo "   Check log file: $LOG_FILE"
        echo "   First 20 lines of log:"
        head -20 "$LOG_FILE"
        exit 1
    else
        echo "🎉 ALL TESTS PASSED! ($TOTAL_EXAMPLES examples, 0 failures)"
        echo ""
        echo "=================================================="
        echo "✅ TEST SUITE IS GREEN - NO GRINDER NEEDED"
        echo "=================================================="
        exit 0
    fi
fi

TOP_SPEC=$(grep "rspec ./spec" "$LOG_FILE" | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -nr | head -1)
TOP_FILE=$(echo "$TOP_SPEC" | awk '{print $2}')
TOP_COUNT=$(echo "$TOP_SPEC" | awk '{print $1}')

if [[ -n "$TOP_FILE" ]]; then
    echo "🎯 Top failing spec: $TOP_FILE"
    echo "   Failure count: $TOP_COUNT"
    echo ""
    
    # Check if backup exists
    BACKUP_FILE="/Users/tam0013/Documents/git/galaxyGame/data/old-code/galaxyGame-01-08-2026/galaxy_game/${TOP_FILE}"
    if [[ -f "$BACKUP_FILE" ]]; then
        echo "✅ Jan 8 backup exists for comparison"
    else
        echo "⚠️  No Jan 8 backup found - may be new file or schema issue"
    fi
else
    echo "⚠️  Could not identify top failing spec from log"
    echo "   Total failures reported: $TOTAL_FAILURES"
    echo "   Check log manually: $LOG_FILE"
fi
echo ""

echo "=================================================="
echo "✅ PRE-FLIGHT COMPLETE - READY FOR GRINDER"
echo "=================================================="
echo ""
echo "📋 GRINDER INSTRUCTIONS FOR AI:"
echo ""
echo "1. Target file: $TOP_FILE"
echo "2. Failure count: $TOP_COUNT"
echo "3. Log location: $LOG_FILE"
echo ""
echo "NEXT STEPS:"
echo "1. Compare $TOP_FILE with Jan 8 backup"
echo "2. Identify regression vs schema evolution"
echo "3. Fix code + update /docs"
echo "4. Run: docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [spec_file]'"
echo "5. Atomic commit: git add [fixed_files] docs/[updated_doc].md"
echo "6. Repeat for next highest failure"
echo ""
echo "Grinder ready for overnight autonomous execution"
