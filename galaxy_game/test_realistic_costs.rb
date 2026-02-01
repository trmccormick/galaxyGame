#!/usr/bin/env ruby
# Test script to demonstrate realistic infrastructure cost calculations

require_relative 'galaxy_game/app/services/economics/infrastructure_cost_calculator'
require_relative 'galaxy_game/app/services/economics/cost_validator'

puts "=== Realistic Space Infrastructure Cost Calculator ===\n"

# Test various infrastructure costs
test_cases = [
  { type: :basic_orbital_station, location: :mars_orbit, scale: :large },
  { type: :orbital_foundry, location: :venus_orbit, scale: :medium },
  { type: :medium_surface_base, location: :mars_surface, scale: :large },
  { type: :industrial_processing_plant, location: :lunar_surface, scale: :medium },
  { type: :orbital_elevator, location: :mars_surface, scale: :massive },
  { type: :research_laboratory, location: :neptune_system, scale: :small }
]

test_cases.each do |test_case|
  cost = Economics::InfrastructureCostCalculator.calculate_cost(
    test_case[:type],
    test_case[:location],
    scale: test_case[:scale],
    complexity: :high_risk
  )

  puts "#{test_case[:type].to_s.titleize} at #{test_case[:location].to_s.titleize} (#{test_case[:scale]})"
  puts "  Cost: #{format_cost(cost)}"
  puts "  USD Equivalent: $#{(cost / 1_000_000_000 * 1.0).round}B"
  puts ""
end

puts "=== Mission Cost Validation ===\n"

# Load and validate the example Venus foundry mission
require 'json'
mission_file = 'galaxy_game/data/json-data/templates/missions/example_venus_foundry_phase_v1.3.json'
mission_data = JSON.parse(File.read(mission_file))

issues = Economics::CostValidator.validate_mission_cost(mission_data)

if issues.empty?
  puts "✅ Venus Foundry Phase costs are realistic!"
else
  puts "❌ Cost validation issues found:"
  issues.each { |issue| puts "  - #{issue}" }
end

puts "\n=== Real-World Cost Comparisons ==="
puts "ISS Program Cost: $150B (150B GCC at $1:1 exchange)"
puts "Apollo Program: $280B (280B GCC)"
puts "Space Shuttle Program: $210B (210B GCC)"
puts "Hubble Telescope: $10B (10B GCC)"
puts "James Webb Telescope: $10B (10B GCC)"
puts ""
puts "Earth Construction Costs:"
puts "Burj Khalifa (tallest building): $1.5B (1.5B GCC)"
puts "Three Gorges Dam: $32B (32B GCC)"
puts "Channel Tunnel: $15B (15B GCC)"
puts "Large Airport: $4B (4B GCC)"
puts ""
puts "Key Insights:"
puts "• Space infrastructure costs 10-60x Earth equivalent"
puts "• Distance adds 2-25x multiplier"
puts "• Extreme environments (Venus, Neptune) add 30-60x multiplier"
puts "• A 'million GCC' base on Neptune would be like $1M for a skyscraper on Earth"
puts "• Realistic space costs reflect launch expenses, logistics complexity, and risk premiums"

def format_cost(amount)
  if amount >= 1_000_000_000_000
    "#{(amount / 1_000_000_000_000.0).round(1)}T GCC"
  elsif amount >= 1_000_000_000
    "#{(amount / 1_000_000_000.0).round(1)}B GCC"
  elsif amount >= 1_000_000
    "#{(amount / 1_000_000.0).round(1)}M GCC"
  else
    "#{amount.round} GCC"
  end
end