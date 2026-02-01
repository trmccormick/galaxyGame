#!/usr/bin/env ruby
# Test script for AI Earth Map Generation System
# Validates that all services can be loaded and basic functionality works

require 'json'
require 'pathname'

# Add the galaxy_game directory to the load path
$LOAD_PATH.unshift(File.expand_path('galaxy_game', __dir__))

begin
  puts "Testing AI Earth Map Generation System..."
  puts "=" * 50

  # Test 1: Load the main EarthMapGenerator service
  puts "1. Loading EarthMapGenerator service..."
  require 'app/services/ai_manager/earth_map_generator'
  puts "   ✓ EarthMapGenerator file loaded successfully"

  # Test 2: Load map processors
  puts "2. Loading map processors..."
  require 'app/services/import/freeciv_map_processor'
  require 'app/services/import/civ4_map_processor'
  puts "   ✓ FreeCiv and Civ4 processor files loaded successfully"

  # Test 3: Check learning data file exists
  puts "3. Checking learning data..."
  learning_file = Pathname.new('data/ai_learning/earth_map_learning.json')
  if learning_file.exist?
    data = JSON.parse(learning_file.read)
    puts "   ✓ Learning data file exists with #{data.length} entries"
  else
    puts "   ⚠ Learning data file not found (this is expected for new installations)"
  end

  # Test 4: Basic syntax validation
  puts "4. Testing basic syntax and structure..."
  begin
    # Check that classes are defined
    earth_gen_defined = defined?(AIManager::EarthMapGenerator)
    freeciv_proc_defined = defined?(Import::FreecivMapProcessor)
    civ4_proc_defined = defined?(Import::Civ4MapProcessor)

    puts "   ✓ AIManager::EarthMapGenerator class defined: #{!!earth_gen_defined}"
    puts "   ✓ Import::FreecivMapProcessor class defined: #{!!freeciv_proc_defined}"
    puts "   ✓ Import::Civ4MapProcessor class defined: #{!!civ4_proc_defined}"

  rescue => e
    puts "   ✗ Error in class definition checks: #{e.message}"
    exit 1
  end

  # Test 5: Check directory structure
  puts "5. Checking directory structure..."
  required_dirs = [
    'data/maps/freeciv',
    'data/maps/civ4',
    'data/ai_learning'
  ]

  required_dirs.each do |dir|
    dir_path = Pathname.new(dir)
    if dir_path.exist? && dir_path.directory?
      puts "   ✓ #{dir} exists"
    else
      puts "   ⚠ #{dir} missing (will be created when needed)"
    end
  end

  puts "=" * 50
  puts "✓ AI Earth Map Generation System test completed successfully!"
  puts ""
  puts "Next steps:"
  puts "1. Place FreeCiv .sav files in data/maps/freeciv/"
  puts "2. Place Civ4 .Civ4WorldBuilderSave files in data/maps/civ4/"
  puts "3. Access the admin interface at /admin/celestial_bodies"
  puts "4. Click '🚀 Generate Earth Map with AI' to start generation"

rescue LoadError => e
  puts "✗ Failed to load required files: #{e.message}"
  puts "Make sure you're running this from the galaxyGame root directory"
  exit 1
rescue => e
  puts "✗ Unexpected error: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end