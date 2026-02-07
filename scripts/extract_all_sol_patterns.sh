#!/bin/bash
# Extract elevation patterns from all Sol system body DEMs
# Creates geotiff_patterns_<body>.json files for realistic terrain generation

set -e

echo "=========================================="
echo "Sol System Multi-Body Pattern Extraction"
echo "Started at: $(date)"
echo "=========================================="
echo ""

exec > >(tee -a logs/pattern_extraction_$(date +%Y%m%d_%H%M%S).log) 2>&1

# List of all bodies to process
BODIES=(
    "earth"
    "luna"
    "mars"
    "mercury"
    "venus"
    "titan"
    "io"
    "europa"
    "ganymede"
    "callisto"
    "enceladus"
)

# Verify data availability
echo "Step 0: Verifying data availability..."
echo ""

AVAILABLE_BODIES=()

for body in "${BODIES[@]}"; do
    data_file="data/geotiff/processed/${body}_1800x900.asc.gz"
    
    if [ -f "$data_file" ]; then
        echo "✓ $body data found"
        AVAILABLE_BODIES+=("$body")
    else
        echo "⊘ $body data not found (will skip)"
    fi
done

echo ""
echo "Found ${#AVAILABLE_BODIES[@]} bodies with elevation data"
echo ""

# Extract patterns for each available body
for body in "${AVAILABLE_BODIES[@]}"; do
    echo "=========================================="
    echo "Extracting patterns for ${body^^}"
    echo "=========================================="
    echo ""
    
    bundle exec rails runner "
      require './scripts/lib/pattern_extractor'
      PatternExtractor.extract_body_patterns('$body', 'data/geotiff/processed/${body}_1800x900.asc.gz')
    "
    
    echo ""
done

# Validate all extracted patterns
echo "=========================================="
echo "Validating Pattern Files"
echo "=========================================="
echo ""

bundle exec rails runner "
  require './scripts/lib/pattern_validator'
  PatternValidator.validate_all
"

echo ""

# Create summary
echo "=========================================="
echo "Creating Pattern Summary"
echo "=========================================="
echo ""

bundle exec rails runner "
  require './scripts/lib/pattern_summarizer'
  PatternSummarizer.create_summary
"

echo ""
echo "=========================================="
echo "PATTERN EXTRACTION COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""

echo "Pattern files created:"
ls -lh app/data/ai_manager/geotiff_patterns_*.json 2>/dev/null || echo "  (none yet - run pattern extraction Ruby scripts)"
echo ""

echo "Total pattern storage:"
du -sh app/data/ai_manager/ 2>/dev/null || echo "  (directory not found)"
echo ""

echo "Bodies processed: ${#AVAILABLE_BODIES[@]}"
echo "Bodies with patterns: $(ls app/data/ai_manager/geotiff_patterns_*.json 2>/dev/null | wc -l)"
