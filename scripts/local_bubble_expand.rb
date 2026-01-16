# Local Bubble Expansion Runner
# Iterates canonical seeds and generates hybrid outputs using the generic method.
# Run: ruby ./scripts/local_bubble_expand.rb --dir app/data/star_systems

require 'json'
require 'optparse'
require 'find'
require_relative '../config/environment'

options = { dir: 'app/data/star_systems' }

OptionParser.new do |opts|
  opts.banner = 'Usage: rails runner local_bubble_expand.rb --dir PATH'
  opts.on('--dir PATH', String, 'Directory containing star system seed JSON files (default: data/json-data/star_systems)') { |v| options[:dir] = v }
  opts.on('-h', '--help', 'Show help') { puts opts; exit 0 }
end.parse!

seed_dir = options[:dir]
unless Dir.exist?(seed_dir)
  puts "Seed directory not found: #{seed_dir}"
  exit 1
end

pg = StarSim::ProceduralGenerator.new
out_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
Dir.mkdir(out_dir) unless Dir.exist?(out_dir)

count = 0
Find.find(seed_dir) do |path|
  next unless path.end_with?('.json')
  begin
    data = JSON.parse(File.read(path))
    identifier = data['identifier'] || File.basename(path, '.json')
    ts = Time.now.strftime('%Y%m%d_%H%M%S')
    system = pg.generate_hybrid_system_from_seed_generic(path)
    out_path = File.join(out_dir, "hybrid_#{identifier}_#{ts}.json")
    File.open(out_path, 'w') { |f| f.write(JSON.pretty_generate(system)) }
    puts "Generated: #{out_path}"
    count += 1
  rescue => e
    warn "Skip #{path}: #{e.message}"
  end
end

puts "Completed local bubble expansion for #{count} system(s)."