#!/usr/bin/env ruby
# Test MissionPlanner with Mars

planner = AIManager::MissionPlannerService.new('mars-terraforming')
puts '✅ MissionPlanner initialized successfully'
puts ''

results = planner.simulate

puts '=== LOCAL CAPABILITIES FOR MARS ==='
puts "Atmosphere resources: #{results[:local_capabilities][:atmosphere].join(', ')}"
puts "Surface resources: #{results[:local_capabilities][:surface].join(', ')}"
puts "Subsurface resources: #{results[:local_capabilities][:subsurface].join(', ')}"
puts ''

puts '=== SAMPLE MISSION COSTS ==='
results[:costs][:breakdown].first(5).each do |resource, data|
  puts "#{resource}: #{data[:source]} (formula: #{data[:chemical_formula] || 'N/A'})"
end
puts ''

puts '=== SUMMARY ==='
puts "Total cost: #{results[:costs][:total]}"
puts "Mission viable: #{results[:viable]}"
