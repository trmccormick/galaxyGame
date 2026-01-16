#!/usr/bin/env ruby
# Alpha Centauri System JSON Generator (scaffold)
# Minimal, opinionated defaults to unblock tasks quickly.

require 'json'
require 'optparse'
require 'fileutils'

options = {
  system_name: 'Alpha Centauri',
  identifier: 'ALC-2026',
  star_type: 'G2V',
  anchor_law_min_mass_kg: 1.0e16,
  output: 'app/data/systems/alpha_centauri.json'
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby alpha_centauri_generator.rb [options]'

  opts.on('--system-name NAME', String, 'System name (default: Alpha Centauri)') { |v| options[:system_name] = v }
  opts.on('--identifier ID', String, 'System identifier (default: ALC-2026)') { |v| options[:identifier] = v }
  opts.on('--star-type TYPE', String, 'Star type (default: G2V)') { |v| options[:star_type] = v }
  opts.on('--anchor-min-mass KG', String, 'Anchor Law minimum mass (kg), default: 1e16') { |v| options[:anchor_law_min_mass_kg] = v.to_f }
  opts.on('--output PATH', String, 'Output JSON path (default: data/json-data/systems/alpha_centauri.json)') { |v| options[:output] = v }
  opts.on('-h', '--help', 'Show help') do
    puts opts
    exit 0
  end
end.parse!

# Opinionated defaults (lightweight, editable after generation)
system_json = {
  system: {
    name: options[:system_name],
    identifier: options[:identifier],
    star_type: options[:star_type],
    anchor_law: {
      min_mass_kg: options[:anchor_law_min_mass_kg],
      compliance_examples: [
        {
          body: 'Gas Giant 18',
          mass_kg: 5.72e27,
          is_primary_anchor: true
        },
        {
          body: 'Asteroid XXXV',
          mass_kg: 2.44e19,
          is_gravitational_anchor: true
        }
      ]
    },
    bodies: [
      {
        name: 'Proxima Centauri b',
        type: 'rocky',
        mass_kg: 1.25e24,
        capabilities: {
          lava_tubes: true,
          regolith_abundance: 'high',
          surface_power_ready: 'precursor'
        }
      },
      {
        name: 'Alpha Centauri A I',
        type: 'gas_giant',
        mass_kg: 5.72e27,
        is_primary_anchor: true
      }
    ],
    wormholes: [
      {
        status: 'stabilizing',
        linked_system: 'SOL-AOL-732356',
        method: 'Natural Wormhole Event Protocol',
        contract_id: 'WHP-ALC-01'
      }
    ],
    economics: {
      maintenance_tax_em: 33.3,
      ste_ratio: 15000,
      notes: 'Baseline values aligned with GUARDRAILS and AOL-732356 docs.'
    }
  }
}

# Ensure directory exists and write the JSON
out_path = options[:output]
FileUtils.mkdir_p(File.dirname(out_path))
File.write(out_path, JSON.pretty_generate(system_json))

puts "Generated: #{out_path}"
