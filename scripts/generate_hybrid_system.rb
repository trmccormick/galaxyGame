# Generic Hybrid Seed Runner
# Run via: ruby ./scripts/generate_hybrid_system.rb --seed [path]

require 'json'
require 'optparse'
require_relative '../config/environment'

options = { seed: nil }

OptionParser.new do |opts|
  opts.banner = 'Usage: rails runner generate_hybrid_system.rb --seed PATH'
  opts.on('--seed PATH', String, 'Canonical star system JSON seed (required)') { |v| options[:seed] = v }
  opts.on('-h', '--help', 'Show help') { puts opts; exit 0 }
end.parse!

if options[:seed].nil? || !File.exist?(options[:seed])
  puts 'Error: --seed PATH is required and must exist'
  exit 1
end

seed_path = options[:seed]
seed_data = JSON.parse(File.read(seed_path))
identifier = seed_data['identifier'] || 'UNKNOWN'
timestamp = Time.now.strftime('%Y%m%d_%H%M%S')

pg = StarSim::ProceduralGenerator.new
system_data = pg.generate_hybrid_system_from_seed(seed_path)

out_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
FileUtils.mkdir_p(out_dir) unless Dir.exist?(out_dir)
out_path = File.join(out_dir, "hybrid_#{identifier}_#{timestamp}.json")

File.open(out_path, 'w') { |f| f.write(JSON.pretty_generate(system_data)) }
puts "Generated hybrid system: #{out_path}"