#!/usr/bin/env ruby
# Demonstration of the new hierarchical DC formation system

# Simple mock of the DC formation logic
def determine_dc_type(world_analysis)
  world_name = world_analysis[:world_name] || "unknown"

  case world_name.downcase
  when "mars"
    { dc_type: :mars_development_corporation, alignment: :independent, region: :inner_solar }
  when "venus"
    { dc_type: :venus_development_corporation, alignment: :independent, region: :inner_solar }
  when "earth", "luna"
    { dc_type: :earth_development_corporation, alignment: :independent, region: :inner_solar }
  when "ceres"
    { dc_type: :ceres_development_corporation, alignment: :mars_development_corporation, region: :asteroid_belt }
  when "vesta", "pallas"
    { dc_type: :vesta_development_corporation, alignment: :mars_development_corporation, region: :asteroid_belt }
  when "titan"
    { dc_type: :titan_development_corporation, alignment: :saturn_development_corporation, region: :saturn_system }
  when "enceladus", "iapetus"
    { dc_type: :enceladus_development_corporation, alignment: :saturn_development_corporation, region: :saturn_system }
  when "europa", "ganymede", "callisto", "io"
    { dc_type: :jupiter_development_corporation, alignment: :independent, region: :jupiter_system }
  when "triton"
    { dc_type: :triton_development_corporation, alignment: :neptune_development_corporation, region: :neptune_system }
  else
    # Fallback to world type-based classification
    case world_analysis[:world_type]
    when :gas_giant_moon
      { dc_type: :saturn_development_corporation, alignment: :regional_coordination, region: :outer_solar }
    when :ice_giant_moon
      { dc_type: :neptune_development_corporation, alignment: :regional_coordination, region: :outer_solar }
    when :terrestrial_planet
      { dc_type: :mars_development_corporation, alignment: :regional_coordination, region: :inner_solar }
    when :venus_like
      { dc_type: :venus_development_corporation, alignment: :regional_coordination, region: :inner_solar }
    else
      { dc_type: :independent_development_corporation, alignment: :independent, region: :unknown }
    end
  end
end

puts "=== Hierarchical Development Corporation Formation Demo ===\n"

# Test worlds and their expected DC formations
test_worlds = [
  { name: 'Ceres', expected: 'Ceres Development Corporation (aligned with Mars)' },
  { name: 'Mars', expected: 'Mars Development Corporation (independent)' },
  { name: 'Titan', expected: 'Titan Development Corporation (aligned with Saturn)' },
  { name: 'Europa', expected: 'Jupiter Development Corporation (independent)' },
  { name: 'Vesta', expected: 'Vesta Development Corporation (aligned with Mars)' },
  { name: 'Triton', expected: 'Triton Development Corporation (aligned with Neptune)' }
]

test_worlds.each do |world|
  world_analysis = {
    world_name: world[:name],
    world_type: :terrestrial_planet
  }

  dc_info = determine_dc_type(world_analysis)

  puts "#{world[:name]}:"
  puts "  DC Type: #{dc_info[:dc_type].to_s.gsub('_', ' ').capitalize}"
  puts "  Alignment: #{dc_info[:alignment].to_s.gsub('_', ' ').capitalize}"
  puts "  Region: #{dc_info[:region].to_s.gsub('_', ' ').capitalize}"
  puts "  Expected: #{world[:expected]}"
  puts ""
end

puts "=== Trade Opportunities Demo ===\n"

# Show trade opportunities for Ceres
def generate_trade_opportunities(dc_info, world_analysis)
  dc_type = dc_info.is_a?(Hash) ? dc_info[:dc_type] : dc_info
  alignment = dc_info.is_a?(Hash) ? dc_info[:alignment] : :independent
  region = dc_info.is_a?(Hash) ? dc_info[:region] : :unknown

  opportunities = []

  case dc_type
  when :ceres_development_corporation
    opportunities << {
      resource: :water_ice,
      partners: [:mars_development_corporation, :vesta_development_corporation],
      volume: :high,
      priority: :primary,
      region: :asteroid_belt
    }
    opportunities << {
      resource: :nickel_iron_ore,
      partners: [:mars_development_corporation, :earth_development_corporation],
      volume: :high,
      priority: :primary,
      region: :asteroid_belt
    }
  end

  opportunities
end

world_analysis = { world_name: 'Ceres', world_type: :terrestrial_planet }
dc_info = determine_dc_type(world_analysis)
trade_opportunities = generate_trade_opportunities(dc_info, world_analysis)

puts "Ceres Development Corporation Trade Opportunities:"
trade_opportunities.each do |opp|
  puts "  #{opp[:resource].to_s.capitalize}: #{opp[:volume]} volume, #{opp[:priority]} priority"
  puts "    Partners: #{opp[:partners].map(&:to_s).join(', ')}"
  puts "    Region: #{opp[:region].to_s.capitalize}"
  puts ""
end