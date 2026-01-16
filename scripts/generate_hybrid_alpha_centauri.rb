# Hybrid Seed Runner for Alpha Centauri
# Run via: ruby ./scripts/generate_hybrid_alpha_centauri.rb --seed app/data/star_systems/alpha_centauri.json

require 'json'
require 'optparse'
require_relative '../config/environment'

options = {
  seed: 'data/json-data/star_systems/alpha_centauri.json'
}

OptionParser.new do |opts|
  opts.banner = 'Usage: rails runner generate_hybrid_alpha_centauri.rb [options]'
  opts.on('--seed PATH', String, 'Canonical star system JSON seed (default: data/json-data/star_systems/alpha_centauri.json)') { |v| options[:seed] = v }
  opts.on('-h', '--help', 'Show help') { puts opts; exit 0 }
end.parse!

seed_path = options[:seed]
unless File.exist?(seed_path)
  puts "Seed not found: #{seed_path}"
  exit 1
end

# Parse seed to build filename
seed_data = JSON.parse(File.read(seed_path))
identifier = seed_data['identifier'] || 'UNKNOWN'
timestamp = Time.now.strftime('%Y%m%d_%H%M%S')

# Generate hybrid system using StarSim procedural generator
pg = StarSim::ProceduralGenerator.new
system_data = pg.generate_hybrid_system_from_seed(seed_path)

# Write to generated systems path
out_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
FileUtils.mkdir_p(out_dir) unless Dir.exist?(out_dir)
out_path = File.join(out_dir, "hybrid_#{identifier}_#{timestamp}.json")

File.open(out_path, 'w') { |f| f.write(JSON.pretty_generate(system_data)) }
puts "Generated hybrid system: #{out_path}"