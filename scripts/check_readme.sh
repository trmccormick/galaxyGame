#!/bin/bash
# Check what's in the README and look for any embedded docs

echo "📖 CHECKING EXISTING DOCUMENTATION"
echo "==================================="
echo ""

echo "Step 1: README.md Contents"
echo "--------------------------"
docker exec -it web cat README.md

echo ""
echo ""
echo "Step 2: Check for Inline Documentation in Code"
echo "-----------------------------------------------"
docker exec -it web bash -c "
echo 'Checking for large comment blocks or documentation in key files...'
echo ''

# Check MissionPlannerService
if [ -f app/services/ai_manager/mission_planner_service.rb ]; then
  echo '=== MissionPlannerService (first 50 lines) ==='
  head -50 app/services/ai_manager/mission_planner_service.rb
fi

echo ''
# Check for any existing pattern definitions
if [ -f app/services/ai_manager/mission_patterns.rb ]; then
  echo '=== Mission Patterns File Found ==='
  head -30 app/services/ai_manager/mission_patterns.rb
fi
"

echo ""
echo "Step 3: Check for Schema Documentation"
echo "---------------------------------------"
docker exec -it web bash -c "
if [ -f db/schema.rb ]; then
  echo 'Looking for key tables in schema.rb...'
  grep -A 3 'create_table.*celestial' db/schema.rb | head -20
  echo ''
  grep -A 3 'create_table.*mission' db/schema.rb | head -20
fi
"

echo ""
echo "📋 DOCUMENTATION GAP ANALYSIS"
echo "=============================="
echo ""
echo "MISSING (Need to Create):"
echo "  ❌ Mission Profile Standards"
echo "  ❌ System Architecture Overview"
echo "  ❌ Geosphere/Planetary Model Documentation"
echo "  ❌ Testing Philosophy & Grinder Protocol"
echo "  ❌ Wormhole Network Design"
echo "  ❌ Economic System Documentation (CONTRACTS, LEDGERS, GUARDRAILS)"
echo "  ❌ API Documentation"
echo "  ❌ Development Setup Guide"
echo ""
echo "RECOMMENDATION: Create structured docs/ directory with:"
echo "  docs/"
echo "    ├── architecture/"
echo "    │   ├── SYSTEM_OVERVIEW.md"
echo "    │   ├── MISSION_PROFILES.md"
echo "    │   └── DATA_MODEL.md"
echo "    ├── economics/"
echo "    │   ├── CONTRACTS.md"
echo "    │   ├── LEDGERS.md"
echo "    │   └── GUARDRAILS.md"
echo "    ├── gameplay/"
echo "    │   ├── GEOSPHERE.md"
echo "    │   ├── WORMHOLE_NETWORK.md"
echo "    │   └── TERRAFORMING.md"
echo "    ├── testing/"
echo "    │   ├── TESTING_PHILOSOPHY.md"
echo "    │   └── GRINDER_PROTOCOL.md"
echo "    └── development/"
echo "        ├── SETUP.md"
echo "        └── CONTRIBUTION_GUIDE.md"