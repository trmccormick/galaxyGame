#!/bin/bash
# scripts/overnight_integration.sh

set -e

echo "=== NIGHT 3: Integration & Testing ==="
echo "Started at: $(date)"

exec > >(tee -a logs/night3_$(date +%Y%m%d).log) 2>&1

echo "Step 1: Running integration tests..."
bundle exec rspec spec/services/ai_manager/planetary_map_generator_spec.rb

echo "Step 2: Generating test maps with patterns..."
bundle exec rails runner scripts/generate_test_maps.rb

echo "Step 3: Comparing before/after quality..."
bundle exec rails runner scripts/compare_map_quality.rb

echo "Step 4: Creating final pattern package..."
tar -czf data/ai_patterns_final_$(date +%Y%m%d).tar.gz data/ai_patterns/*.json

echo "Step 5: Cleaning up temporary files..."
rm -rf data/geotiff/raw/*.nc
rm -rf data/geotiff/processed/*.tif
# Keep only: compressed ASCII and final patterns

echo "=== NIGHT 3 COMPLETE ==="
echo "Finished at: $(date)"
echo ""
echo "Final deliverables:"
ls -lh data/ai_patterns_final_*.tar.gz
ls -lh data/ai_patterns/*.json
echo ""
echo "READY FOR PRODUCTION DEPLOYMENT"