# scripts/visualize_patterns.rb

puts "=== Generating Pattern Visualizations ==="

require 'json'
require 'fileutils'

# Create visualization directory
viz_dir = 'tmp/pattern_visualizations'
FileUtils.mkdir_p(viz_dir)

# Load master patterns
master_file = 'data/ai_patterns/geotiff_master.json'
unless File.exist?(master_file)
  puts "❌ Master pattern file not found: #{master_file}"
  exit 1
end

master = JSON.parse(File.read(master_file))
patterns = master['patterns']

puts "Generating visualizations for #{patterns.keys.size} pattern types..."

# Generate elevation distribution chart
if patterns['elevation']
  puts "Creating elevation distribution visualization..."
  elevation = patterns['elevation']

  # Create simple text-based histogram
  histogram = elevation['distribution']['histogram']
  max_count = histogram.max

  chart = []
  chart << "Elevation Distribution (Beta: α=#{elevation['distribution']['alpha']}, β=#{elevation['distribution']['beta']})"
  chart << "=" * 80

  histogram.each_with_index do |count, bin|
    bar_length = (count * 50).to_i  # Scale to 50 chars max
    bar = '█' * bar_length
    percentage = (count * 100).round(1)
    chart << sprintf("%2d: %-50s %5.1f%%", bin, bar, percentage)
  end

  # Add statistics
  stats = elevation['statistics']
  chart << ""
  chart << "Statistics:"
  chart << sprintf("  Mean: %.3f", stats['mean'])
  chart << sprintf("  Median: %.3f", stats['median'])
  chart << sprintf("  Std Dev: %.3f", stats['std_dev'])
  chart << sprintf("  Range: %.3f - %.3f", stats['min'], stats['max'])
  chart << sprintf("  90th percentile: %.3f", stats['percentiles']['p90'])

  File.write("#{viz_dir}/elevation_distribution.txt", chart.join("\n"))
  puts "✓ Elevation distribution saved to #{viz_dir}/elevation_distribution.txt"
end

# Generate coastline complexity summary
if patterns['coastline']
  puts "Creating coastline complexity visualization..."
  coastline = patterns['coastline']

  summary = []
  summary << "Coastline Complexity Analysis"
  summary << "=" * 40
  summary << ""
  summary << "Total coastline tiles: #{coastline['complexity']['total_tiles']}"
  summary << sprintf("Direction changes per 100 tiles: %.1f", coastline['complexity']['direction_changes_per_100'])
  summary << sprintf("Average tile spacing: %.2f", coastline['complexity']['avg_tile_spacing'])
  summary << ""
  summary << "Interpretation:"
  complexity = coastline['complexity']['direction_changes_per_100']
  if complexity > 50
    summary << "  HIGH complexity - Very jagged, realistic coastline"
  elsif complexity > 25
    summary << "  MEDIUM complexity - Moderately complex coastline"
  else
    summary << "  LOW complexity - Relatively straight coastline"
  end

  File.write("#{viz_dir}/coastline_complexity.txt", summary.join("\n"))
  puts "✓ Coastline complexity saved to #{viz_dir}/coastline_complexity.txt"
end

# Generate mountain chain analysis
if patterns['mountain']
  puts "Creating mountain chain visualization..."
  mountains = patterns['mountain']

  analysis = []
  analysis << "Mountain Chain Analysis"
  analysis << "=" * 30
  analysis << ""
  analysis << "Total mountain chains: #{mountains['chains']['count']}"
  analysis << sprintf("Average chain length: %.1f tiles", mountains['chains']['avg_length'])
  analysis << sprintf("Total mountain tiles: %d", mountains['chains']['total_mountain_tiles'])
  analysis << sprintf("Mountain density: %.3f%%", mountains['chains']['mountain_density'] * 100)
  analysis << ""
  analysis << "Chain length distribution:"
  # Simple categorization
  if mountains['chains']['avg_length'] > 100
    analysis << "  LONG chains - Mountain ranges dominate"
  elsif mountains['chains']['avg_length'] > 50
    analysis << "  MEDIUM chains - Balanced mountain distribution"
  else
    analysis << "  SHORT chains - Scattered mountain peaks"
  end

  File.write("#{viz_dir}/mountain_chains.txt", analysis.join("\n"))
  puts "✓ Mountain chain analysis saved to #{viz_dir}/mountain_chains.txt"
end

# Generate slope analysis
if patterns['slope']
  puts "Creating slope gradient visualization..."
  slope = patterns['slope']

  slope_analysis = []
  slope_analysis << "Slope Gradient Analysis"
  slope_analysis << "=" * 30
  slope_analysis << ""
  slope_analysis << sprintf("Mean slope: %.3f", slope['statistics']['mean'])
  slope_analysis << sprintf("Median slope: %.3f", slope['statistics']['median'])
  slope_analysis << sprintf("Maximum slope: %.3f", slope['statistics']['max'])
  slope_analysis << sprintf("90th percentile slope: %.3f", slope['statistics']['p90'])
  slope_analysis << ""
  slope_analysis << "Terrain steepness:"
  max_slope = slope['statistics']['max']
  if max_slope > 1.0
    slope_analysis << "  VERY STEEP - Extreme elevation changes"
  elsif max_slope > 0.5
    slope_analysis << "  STEEP - Significant elevation changes"
  elsif max_slope > 0.2
    slope_analysis << "  MODERATE - Normal elevation variation"
  else
    slope_analysis << "  GENTLE - Mostly flat terrain"
  end

  File.write("#{viz_dir}/slope_analysis.txt", slope_analysis.join("\n"))
  puts "✓ Slope analysis saved to #{viz_dir}/slope_analysis.txt"
end

# Create summary report
summary = []
summary << "Pattern Extraction Summary Report"
summary << "=" * 50
summary << ""
summary << "Extraction completed: #{master['extracted_at']}"
summary << "Source: #{master['source']}"
summary << "Resolution: #{master['resolution']}"
summary << "Total tiles processed: #{master['metadata']['total_tiles']}"
summary << ""
summary << "Pattern types extracted:"
patterns.each_key do |pattern_type|
  summary << "  ✓ #{pattern_type.capitalize}"
end
summary << ""
summary << "Files generated:"
Dir.glob("#{viz_dir}/*.txt").each do |file|
  summary << "  - #{File.basename(file)} (#{File.size(file)} bytes)"
end

File.write("#{viz_dir}/summary_report.txt", summary.join("\n"))

puts ""
puts "=== Visualization Complete ==="
puts "All visualizations saved to: #{viz_dir}/"
puts "Summary report: #{viz_dir}/summary_report.txt"
puts ""
puts "To view visualizations:"
puts "  cat #{viz_dir}/*.txt"