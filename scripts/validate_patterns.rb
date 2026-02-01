# scripts/validate_patterns.rb

puts "=== Validating Extracted Patterns ==="

require 'json'

patterns_dir = 'data/ai_patterns'
errors = []
warnings = []

# Check if pattern files exist
pattern_files = [
  'geotiff_elevation.json',
  'geotiff_coastline.json',
  'geotiff_mountain.json',
  'geotiff_slope.json',
  'geotiff_master.json'
]

pattern_files.each do |filename|
  filepath = File.join(patterns_dir, filename)
  if File.exist?(filepath)
    puts "✓ Found #{filename} (#{File.size(filepath)} bytes)"
  else
    errors << "Missing pattern file: #{filename}"
  end
end

# Validate elevation patterns
if File.exist?('data/ai_patterns/geotiff_elevation.json')
  elevation = JSON.parse(File.read('data/ai_patterns/geotiff_elevation.json'))

  # Check required fields
  required_fields = ['distribution', 'statistics']
  required_fields.each do |field|
    if elevation[field].nil?
      errors << "Elevation patterns missing #{field}"
    else
      puts "✓ Elevation patterns have #{field}"
    end
  end

  # Check distribution type
  if elevation['distribution'] && elevation['distribution']['type'] != 'beta'
    warnings << "Elevation distribution type is #{elevation['distribution']['type']}, expected 'beta'"
  end

  # Check statistics
  if elevation['statistics']
    stats = elevation['statistics']
    required_stats = ['mean', 'median', 'std_dev', 'min', 'max', 'percentiles']
    required_stats.each do |stat|
      if stats[stat].nil?
        errors << "Elevation statistics missing #{stat}"
      end
    end
  end
end

# Validate coastline patterns
if File.exist?('data/ai_patterns/geotiff_coastline.json')
  coastline = JSON.parse(File.read('data/ai_patterns/geotiff_coastline.json'))

  if coastline['complexity'].nil?
    errors << "Coastline patterns missing complexity data"
  else
    puts "✓ Coastline patterns have complexity metrics"
  end
end

# Validate mountain patterns
if File.exist?('data/ai_patterns/geotiff_mountain.json')
  mountains = JSON.parse(File.read('data/ai_patterns/geotiff_mountain.json'))

  if mountains['chains'].nil?
    errors << "Mountain patterns missing chain data"
  else
    puts "✓ Mountain patterns have chain analysis"
  end
end

# Validate master file
if File.exist?('data/ai_patterns/geotiff_master.json')
  master = JSON.parse(File.read('data/ai_patterns/geotiff_master.json'))

  required_master_fields = ['version', 'extracted_at', 'source', 'patterns']
  required_master_fields.each do |field|
    if master[field].nil?
      errors << "Master patterns missing #{field}"
    end
  end

  # Check that all pattern types are included
  if master['patterns']
    expected_patterns = ['elevation', 'coastline', 'mountain', 'slope']
    expected_patterns.each do |pattern_type|
      if master['patterns'][pattern_type].nil?
        errors << "Master patterns missing #{pattern_type} data"
      end
    end
  end

  puts "✓ Master pattern file validated"
end

# Report results
puts ""
if errors.empty?
  puts "🎉 All validations passed!"
  puts "Patterns are ready for use."
else
  puts "❌ Validation failed with #{errors.size} errors:"
  errors.each { |error| puts "  - #{error}" }
  exit 1
end

if warnings.any?
  puts ""
  puts "⚠️  Warnings (non-critical):"
  warnings.each { |warning| puts "  - #{warning}" }
end

puts ""
puts "=== Validation Complete ==="