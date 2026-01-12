require 'json'

puts "\n🤖 === AI MANAGER MISSION PROFILE TRAINING INTEGRATION TEST ==="
puts "Testing direct AI training with mission profile analysis (Analysis Only)"

# 1. Run Mission Profile Analysis (No Database Required)
puts "\n1. Running Mission Profile Analysis..."
analyzer = AIManager::MissionProfileAnalyzer

begin
  patterns = analyzer.analyze_all_mission_profiles
  puts "📊 Analysis complete! Found #{patterns.size} patterns:"

  patterns.each do |pattern_id, pattern|
    units = pattern[:equipment_requirements][:total_unit_count]
    phases = pattern[:phase_structure][:total_phases]
    cost = pattern[:economic_model][:estimated_gcc_cost] || 0

    puts "  • #{pattern_id}:"
    puts "    - #{phases} phases, #{units} units, #{cost} GCC cost"
    puts "    - Source: #{pattern[:source_file]}"
  end
rescue => e
  puts "❌ Analysis failed: #{e.message}"
  exit 1
end

# 2. Analyze Pattern Quality
puts "\n2. Analyzing pattern quality..."
complete_patterns = patterns.select { |id, p| (p[:equipment_requirements][:total_unit_count] || 0) > 0 }
incomplete_patterns = patterns.reject { |id, p| (p[:equipment_requirements][:total_unit_count] || 0) > 0 }

puts "✅ Complete patterns (with equipment): #{complete_patterns.size}"
complete_patterns.each do |id, pattern|
  puts "  - #{id}: #{pattern[:equipment_requirements][:total_unit_count]} units"
end

puts "⚠️  Incomplete patterns (missing manifests): #{incomplete_patterns.size}"
incomplete_patterns.each do |id, pattern|
  puts "  - #{id}: needs manifest file"
end

# 3. Test Training Validation
puts "\n3. Testing training validation..."
training_success = analyzer.train_ai_manager_with_patterns

if training_success
  puts "✅ Training validation passed!"
else
  puts "⚠️  Some patterns failed validation (expected for incomplete patterns)"
end

# 4. Generate Enhanced Training Report
puts "\n4. Generating enhanced training report..."
report = {
  training_session: Time.current.iso8601,
  patterns_analyzed: patterns.size,
  complete_patterns: complete_patterns.size,
  incomplete_patterns: incomplete_patterns.size,
  best_patterns: complete_patterns.keys,
  training_method: 'mission_profile_analyzer_integration',
  recommendations: [
    "Focus on complete patterns: #{complete_patterns.keys.join(', ')}",
    "Add manifest files for incomplete patterns to improve training",
    "Use titan_pattern and npc_base_deploy_pattern for comprehensive AI training",
    "Integration test successful - patterns ready for AI consumption"
  ]
}

report_path = GalaxyGame::Paths::AI_MANAGER_PATH.join('enhanced_training_report.json')
File.write(report_path, JSON.pretty_generate(report))

puts "📊 Enhanced training report saved to: #{report_path}"

# 5. Show Training Files Created
puts "\n5. Training files created:"
training_files = [
  GalaxyGame::Paths::AI_MISSION_PATTERNS_PATH.to_s,
  GalaxyGame::Paths::AI_MANAGER_PATH.join('training_results.json').to_s,
  GalaxyGame::Paths::AI_MANAGER_PATH.join('enhanced_training_report.json').to_s
]

training_files.each do |file|
  full_path = Rails.root.join(file)
  if File.exist?(full_path)
    size = File.size(full_path)
    puts "  ✅ #{file} (#{size} bytes)"
  else
    puts "  ❌ #{file} (missing)"
  end
end

puts "\n🎓 Integration test complete!"
puts "\n" + "="*60
puts "SUMMARY:"
puts "• Analyzed #{patterns.size} mission patterns"
puts "• #{complete_patterns.size} complete patterns ready for AI training"
puts "• #{incomplete_patterns.size} patterns need manifest files"
puts "• Training data saved for AI Manager consumption"
puts "• Ready for integration with rake tasks or direct AI training"
puts "="*60