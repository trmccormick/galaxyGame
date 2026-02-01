#!/bin/bash

# Night 2: Multi-Body Pattern Extraction# Night 2: Multi-Body Pattern Extraction
# Orchestrates overnight processing of elevation patterns for Earth, Luna, and Marsestrates overnight processing of elevation patterns for Earth, Luna, and Mars

set -e  # Exit on any error

echo "=== Galaxy Game: Night 2 Multi-Body Pattern Extraction ==="ht 2 Multi-Body Pattern Extraction ==="
echo "Started at: $(date)"
echo ""

# Function to check if data file exists







































































echo "Summary available in: data/patterns/pattern_summary.json"echo "Pattern files created in: data/patterns/"echo "Finished at: $(date)"echo "=== Night 2 Complete ==="echo ""bundle exec rails runner "require './scripts/lib/pattern_summarizer.rb'; PatternSummarizer.generate_summary"echo "=== Generating Pattern Summary ==="echo ""# Generate summarybundle exec rails runner "require './scripts/lib/pattern_validator.rb'; PatternValidator.validate_all_patterns"echo "=== Validating Extracted Patterns ==="echo ""# Validate extracted patternsdone    extract_patterns "$body"for body in "${available_bodies[@]}"; doecho "=== Starting Pattern Extraction ==="echo ""# Extract patterns for available bodiesfi    exit 1    echo "Please ensure elevation data files are present in data/processed/"    echo "ERROR: No elevation data found. Cannot proceed with pattern extraction."if [ ${#available_bodies[@]} -eq 0 ]; thenecho "Available bodies for pattern extraction: ${available_bodies[*]}"echo ""done    fi        available_bodies+=("$body")    if check_data_file "$body"; thenfor body in "${bodies[@]}"; doavailable_bodies=()bodies=("Earth" "Luna" "Mars")echo "=== Checking Data Availability ==="# Check available data}    echo "${body} pattern extraction completed at: $(date)"    bundle exec rails runner "require './scripts/lib/pattern_extractor.rb'; PatternExtractor.extract_body_patterns('${body}')"    echo "Running pattern extraction for ${body}..."    fi        return 1        echo "Skipping ${body} pattern extraction due to missing data"    if ! check_data_file "$body"; then    echo "Started at: $(date)"    echo "=== Extracting ${body} patterns ==="    echo ""    local body=$1extract_patterns() {# Function to extract patterns for a body}    fi        return 1        echo "✗ ${body} elevation data missing: $file_path"    else        return 0        echo "✓ ${body} elevation data found: $file_path"    if [ -f "$file_path" ]; then    local file_path="data/processed/${body}_elevation_1800x900.asc.gz"    local body=$1check_data_file() {check_data_file() {
    local body=$1
    local file_path="data/processed/${body}_elevation_1800x900.asc.gz"
    if [ -f "$file_path" ]; then
        echo "✓ ${body} elevation data found: $file_path"
        return 0
    else
        echo "✗ ${body} elevation data missing: $file_path"
        return 1
    fi
}

# Function to extract patterns for a body
extract_patterns() {
    local body=$1
    echo ""
    echo "=== Extracting ${body} patterns ==="
    echo "Started at: $(date)"

    if ! check_data_file "$body"; then
        echo "Skipping ${body} pattern extraction due to missing data"
        return 1
    fi

    echo "Running pattern extraction for ${body}..."
    bundle exec rails runner "require './scripts/lib/pattern_extractor.rb'; PatternExtractor.extract_body_patterns('${body}')"
    echo "${body} pattern extraction completed at: $(date)"
}

# Check available data
echo "=== Checking Data Availability ==="
bodies=("Earth" "Luna" "Mars")
available_bodies=()

for body in "${bodies[@]}"; do
    if check_data_file "$body"; then
        available_bodies+=("$body")
    fi
done

echo ""
echo "Available bodies for pattern extraction: ${available_bodies[*]}"

if [ ${#available_bodies[@]} -eq 0 ]; then
    echo "ERROR: No elevation data found. Cannot proceed with pattern extraction."
    echo "Please ensure elevation data files are present in data/processed/"
    exit 1
fi

# Extract patterns for available bodies
echo ""
echo "=== Starting Pattern Extraction ==="
for body in "${available_bodies[@]}"; do
    extract_patterns "$body"
done

# Validate extracted patterns
echo ""
echo "=== Validating Extracted Patterns ==="
bundle exec rails runner "require './scripts/lib/pattern_validator.rb'; PatternValidator.validate_all_patterns"

# Generate summary
echo ""
echo "=== Generating Pattern Summary ==="
bundle exec rails runner "require './scripts/lib/pattern_summarizer.rb'; PatternSummarizer.generate_summary"

echo ""
echo "=== Night 2 Complete ==="
echo "Finished at: $(date)"
echo "Pattern files created in: data/patterns/"
echo "Summary available in: data/patterns/pattern_summary.json"







































































echo "Summary available in: data/patterns/pattern_summary.json"echo "Pattern files created in: data/patterns/"echo "Finished at: $(date)"echo "=== Night 2 Complete ==="echo ""bundle exec rails runner "require './scripts/lib/pattern_summarizer.rb'; PatternSummarizer.generate_summary"echo "=== Generating Pattern Summary ==="echo ""# Generate summarybundle exec rails runner "require './scripts/lib/pattern_validator.rb'; PatternValidator.validate_all_patterns"echo "=== Validating Extracted Patterns ==="echo ""# Validate extracted patternsdone    extract_patterns "$body"for body in "${available_bodies[@]}"; doecho "=== Starting Pattern Extraction ==="echo ""# Extract patterns for available bodiesfi    exit 1    echo "Please ensure elevation data files are present in data/processed/"    echo "ERROR: No elevation data found. Cannot proceed with pattern extraction."if [ ${#available_bodies[@]} -eq 0 ]; thenecho "Available bodies for pattern extraction: ${available_bodies[*]}"echo ""done    fi        available_bodies+=("$body")    if check_data_file "$body"; thenfor body in "${bodies[@]}"; doavailable_bodies=()bodies=("Earth" "Luna" "Mars")echo "=== Checking Data Availability ==="# Check available data}    echo "${body} pattern extraction completed at: $(date)"    bundle exec rails runner "require './scripts/lib/pattern_extractor.rb'; PatternExtractor.extract_body_patterns('${body}')"    echo "Running pattern extraction for ${body}..."    fi        return 1        echo "Skipping ${body} pattern extraction due to missing data"    if ! check_data_file "$body"; then    echo "Started at: $(date)"    echo "=== Extracting ${body} patterns ==="    echo ""    local body=$1extract_patterns() {# Function to extract patterns for a body}    fi        return 1        echo "✗ ${body} elevation data missing: $file_path"    else        return 0        echo "✓ ${body} elevation data found: $file_path"    if [ -f "$file_path" ]; then    local file_path="data/processed/${body}_elevation_1800x900.asc.gz"    local body=$1check_data_file() {

















































































echo "Ready for Night 3: Integration & Testing"echo ""du -sh app/data/ai_manager/echo "Total pattern storage:"echo ""ls -lh app/data/ai_manager/geotiff_patterns_*.jsonecho "Pattern files created:"echo ""echo "=========================================="echo "Finished at: $(date)"echo "NIGHT 2 COMPLETE!"echo "=========================================="echo ""echo "✓ Summary created""  PatternSummarizer.create_summary  require './scripts/lib/pattern_summarizer'bundle exec rails runner "echo "Step 5: Creating pattern summary..."echo ""echo "✓ Validation complete""  PatternValidator.validate_all  require './scripts/lib/pattern_validator'bundle exec rails runner "echo "Step 4: Validating all pattern files..."echo ""echo "✓ Mars patterns complete""  PatternExtractor.extract_body_patterns('mars', '$MARS_DATA')  require './scripts/lib/pattern_extractor'bundle exec rails runner "echo "Step 3: Extracting MARS patterns..."echo ""echo "✓ Luna patterns complete""  PatternExtractor.extract_body_patterns('luna', '$LUNA_DATA')  require './scripts/lib/pattern_extractor'bundle exec rails runner "echo "Step 2: Extracting LUNA patterns..."echo ""echo "✓ Earth patterns complete""  PatternExtractor.extract_body_patterns('earth', '$EARTH_DATA')  require './scripts/lib/pattern_extractor'bundle exec rails runner "echo "Step 1: Extracting EARTH patterns..."# Extract patterns for each body typeecho ""echo "✓ All three body types available"fi    exit 1    echo "Run: ./scripts/download_luna_mars.sh first"    echo "❌ ERROR: Mars data not found!"if [ ! -f "$MARS_DATA" ]; thenfi    exit 1    echo "Run: ./scripts/download_luna_mars.sh first"    echo "❌ ERROR: Luna data not found!"if [ ! -f "$LUNA_DATA" ]; thenfi    exit 1    echo "Expected: $EARTH_DATA"    echo "❌ ERROR: Earth data not found!"if [ ! -f "$EARTH_DATA" ]; thenMARS_DATA="data/geotiff/processed/mars_1800x900.asc.gz"LUNA_DATA="data/geotiff/processed/luna_1800x900.asc.gz"EARTH_DATA="app/data/geotiff/processed/earth_1800x900.asc.gz"echo "Step 0: Verifying data availability..."# Verify all three bodies are availableexec > >(tee -a logs/night2_$(date +%Y%m%d_%H%M%S).log) 2>&1
exec > >(tee -a logs/night2_$(date +%Y%m%d_%H%M%S).log) 2>&1

# Verify all three bodies are available
echo "Step 0: Verifying data availability..."

EARTH_DATA="app/data/geotiff/processed/earth_1800x900.asc.gz"
LUNA_DATA="data/geotiff/processed/luna_1800x900.asc.gz"
MARS_DATA="data/geotiff/processed/mars_1800x900.asc.gz"

if [ ! -f "$EARTH_DATA" ]; then
    echo "❌ ERROR: Earth data not found!"
    echo "Expected: $EARTH_DATA"
    exit 1
fi

if [ ! -f "$LUNA_DATA" ]; then
    echo "❌ ERROR: Luna data not found!"
    echo "Run: ./scripts/download_luna_mars.sh first"
    exit 1
fi

if [ ! -f "$MARS_DATA" ]; then
    echo "❌ ERROR: Mars data not found!"
    echo "Run: ./scripts/download_luna_mars.sh first"
    exit 1
fi

echo "✓ All three body types available"
echo ""

# Extract patterns for each body type
echo "Step 1: Extracting EARTH patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('earth', '$EARTH_DATA')
"
echo "✓ Earth patterns complete"
echo ""

echo "Step 2: Extracting LUNA patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('luna', '$LUNA_DATA')
"
echo "✓ Luna patterns complete"
echo ""

echo "Step 3: Extracting MARS patterns..."
bundle exec rails runner "
  require './scripts/lib/pattern_extractor'
  PatternExtractor.extract_body_patterns('mars', '$MARS_DATA')
"
echo "✓ Mars patterns complete"
echo ""

echo "Step 4: Validating all pattern files..."
bundle exec rails runner "
  require './scripts/lib/pattern_validator'
  PatternValidator.validate_all
"
echo "✓ Validation complete"
echo ""

echo "Step 5: Creating pattern summary..."
bundle exec rails runner "
  require './scripts/lib/pattern_summarizer'
  PatternSummarizer.create_summary
"
echo "✓ Summary created"
echo ""

echo "=========================================="
echo "NIGHT 2 COMPLETE!"
echo "Finished at: $(date)"
echo "=========================================="
echo ""
echo "Pattern files created:"
ls -lh app/data/ai_manager/geotiff_patterns_*.json
echo ""
echo "Total pattern storage:"
du -sh app/data/ai_manager/
echo ""
echo "Ready for Night 3: Integration & Testing"