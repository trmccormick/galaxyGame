#!/bin/bash
# scripts/overnight_pattern_extraction.sh

set -e

echo "=== NIGHT 2: Pattern Extraction ==="
echo "Started at: $(date)"

exec > >(tee -a logs/night2_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Verifying Night 1 output..."
if [ ! -f data/geotiff/processed/earth_1800x900.asc.gz ]; then
    echo "ERROR: Night 1 data not found!"
    exit 1
fi

echo "Step 2: Running Ruby pattern extraction..."
cd "$(dirname "$0")/.."
bundle exec rails runner scripts/extract_all_patterns.rb

echo "Step 3: Validating extracted patterns..."
bundle exec rails runner scripts/validate_patterns.rb

echo "Step 4: Generating pattern visualization..."
bundle exec rails runner scripts/visualize_patterns.rb

echo "Step 5: Creating backup of patterns..."
cp -r data/ai_patterns data/ai_patterns_backup_$(date +%Y%m%d)

echo "=== NIGHT 2 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Patterns created:"
ls -lh data/ai_patterns/
echo ""
echo "Ready for Night 3: Integration & Testing"