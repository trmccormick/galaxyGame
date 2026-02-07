#!/usr/bin/env ruby

require_relative 'app/services/star_sim/procedural_generator'
require_relative 'app/services/star_sim/accretion_simulation_service'

# Test accretion integration
generator = StarSim::ProceduralGenerator.new(use_accretion: true)
system_data = generator.generate_system_seed(num_stars: 1, num_planets: 5)

puts "Generated system with accretion:"
puts JSON.pretty_generate(system_data)