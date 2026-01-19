#!/bin/bash
# Check if the docs/ directory referenced in README actually exists

echo "📚 CHECKING DOCUMENTATION STRUCTURE"
echo "===================================="
echo ""

echo "Step 1: Check Root-Level docs/ Directory"
echo "-----------------------------------------"
if [ -d docs ]; then
  echo "✅ docs/ directory EXISTS"
  echo ""
  echo "Directory structure:"
  tree docs -L 3 2>/dev/null || find docs -type d | sort
  echo ""
  echo "All markdown files:"
  find docs -name "*.md" -type f | sort
else
  echo "❌ docs/ directory DOES NOT EXIST at root level"
fi

echo ""
echo "Step 2: Check Application-Level docs/"
echo "--------------------------------------"
cd galaxy_game 2>/dev/null || cd galaxyGame 2>/dev/null || echo "Could not find galaxy_game directory"

if [ -d docs ]; then
  echo "✅ docs/ directory EXISTS in application folder"
  echo ""
  echo "Directory structure:"
  tree docs -L 3 2>/dev/null || find docs -type d | sort
  echo ""
  echo "All markdown files:"
  find docs -name "*.md" -type f | sort
else
  echo "❌ docs/ directory DOES NOT EXIST in application folder"
fi

echo ""
echo "Step 3: List All Referenced Docs from README"
echo "---------------------------------------------"
echo "README references these docs that should exist:"
echo "  - docs/README.md"
echo "  - docs/architecture/SIMEARTH_ADMIN_VISION.md"
echo "  - docs/development/active/CURRENT_STATUS.md"
echo "  - docs/development/planning/RESTORATION_AND_ENHANCEMENT_PLAN.md"
echo "  - docs/developer/setup.md"
echo "  - docs/architecture/overview.md"
echo "  - docs/gameplay/mechanics.md"
echo "  - docs/development/reference/ENVIRONMENT_BOUNDARIES.md"
echo "  - docs/developer/ai_testing_framework.md"
echo "  - docs/architecture/SYSTEM_INDUSTRIAL_CHAINS.md"
echo "  - docs/architecture/financial_system.md"
echo "  - docs/architecture/organizations_system.md"
echo ""

echo "Step 4: Check Which Docs Actually Exist"
echo "----------------------------------------"
cd .. 2>/dev/null
for doc in \
  "docs/README.md" \
  "docs/architecture/SIMEARTH_ADMIN_VISION.md" \
  "docs/development/active/CURRENT_STATUS.md" \
  "docs/developer/setup.md" \
  "docs/architecture/SYSTEM_INDUSTRIAL_CHAINS.md"
do
  if [ -f "$doc" ]; then
    echo "✅ $doc"
  else
    echo "❌ $doc (MISSING)"
  fi
done