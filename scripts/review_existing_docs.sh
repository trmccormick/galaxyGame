#!/bin/bash
# Review existing documentation to identify gaps

echo "📚 EXISTING DOCUMENTATION REVIEW"
echo "================================="
echo ""

echo "Step 1: List All Documentation Files"
echo "-------------------------------------"
docker exec -it web bash -c "
find . -name '*.md' -type f | grep -v node_modules | grep -v vendor | sort
"

echo ""
echo "Step 2: Check for Mission-Related Docs"
echo "---------------------------------------"
docker exec -it web bash -c "
echo 'Searching for mission-related documentation...'
find . -name '*mission*.md' -o -name '*MISSION*.md' -o -name '*Mission*.md' | grep -v node_modules
"

echo ""
echo "Step 3: Check for System/Architecture Docs"
echo "-------------------------------------------"
docker exec -it web bash -c "
echo 'Searching for system/architecture documentation...'
find . -name '*architecture*.md' -o -name '*ARCHITECTURE*.md' -o -name '*system*.md' -o -name '*SYSTEM*.md' | grep -v node_modules
"

echo ""
echo "Step 4: Check for Geosphere/Planet Docs"
echo "----------------------------------------"
docker exec -it web bash -c "
echo 'Searching for geosphere/planet documentation...'
find . -name '*geosphere*.md' -o -name '*planet*.md' -o -name '*celestial*.md' | grep -v node_modules
"

echo ""
echo "Step 5: Check for Testing Docs"
echo "-------------------------------"
docker exec -it web bash -c "
echo 'Searching for testing documentation...'
find . -name '*test*.md' -o -name '*TEST*.md' -o -name '*spec*.md' | grep -v node_modules
"

echo ""
echo "Step 6: Check for Wormhole/Network Docs"
echo "----------------------------------------"
docker exec -it web bash -c "
echo 'Searching for wormhole/network documentation...'
find . -name '*wormhole*.md' -o -name '*network*.md' -o -name '*transport*.md' | grep -v node_modules
"

echo ""
echo "Step 7: List Documentation Directory Contents"
echo "----------------------------------------------"
docker exec -it web bash -c "
if [ -d docs ]; then
  echo 'Contents of docs/ directory:'
  ls -lah docs/
  echo ''
  find docs -name '*.md' -type f | sort
elif [ -d documentation ]; then
  echo 'Contents of documentation/ directory:'
  ls -lah documentation/
  echo ''
  find documentation -name '*.md' -type f | sort
else
  echo 'No docs/ or documentation/ directory found'
fi
"

echo ""
echo "Step 8: Check README and Top-Level Docs"
echo "----------------------------------------"
docker exec -it web bash -c "
ls -1 *.md 2>/dev/null || echo 'No markdown files in root directory'
"

echo ""
echo "Step 9: Sample Existing Contract/Economic Docs"
echo "-----------------------------------------------"
docker exec -it web bash -c "
if [ -f CONTRACTS.md ]; then
  echo '=== CONTRACTS.md (first 30 lines) ==='
  head -30 CONTRACTS.md
fi

if [ -f LEDGERS.md ]; then
  echo ''
  echo '=== LEDGERS.md (first 30 lines) ==='
  head -30 LEDGERS.md
fi

if [ -f GUARDRAILS.md ]; then
  echo ''
  echo '=== GUARDRAILS.md (first 30 lines) ==='
  head -30 GUARDRAILS.md
fi
"

echo ""
echo "📋 NEXT STEPS"
echo "============="
echo "Review the output above to identify:"
echo "  1. What documentation already exists"
echo "  2. What's missing that needs to be created"
echo "  3. What needs to be updated/expanded"
echo ""
echo "Then we can assign tasks appropriately to Claude/Grok/GPT-4.1"