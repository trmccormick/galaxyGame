#!/usr/bin/env ruby
# Star System Validator for Anchor Law & Basic Schema

require 'json'
require 'optparse'

options = {
  input: 'app/data/star_systems/alpha_centauri.json',
  anchor_min_mass_kg: 1.0e16
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby star_system_validator.rb [options]'
  opts.on('--input PATH', String, 'Input star system JSON (default: data/json-data/star_systems/alpha_centauri.json)') { |v| options[:input] = v }
  opts.on('--anchor-min-mass KG', String, 'Anchor Law minimum mass in kg (default: 1e16)') { |v| options[:anchor_min_mass_kg] = v.to_f }
  opts.on('-h', '--help', 'Show help') { puts opts; exit 0 }
end.parse!

begin
  raw = File.read(options[:input])
  data = JSON.parse(raw)
rescue => e
  warn "Error: failed to read/parse #{options[:input]} — #{e.message}"
  exit 1
end

report = { file: options[:input], checks: [] }

# Basic schema checks
report[:checks] << { name: 'has_galaxy_block', passed: data.key?('galaxy') }
report[:checks] << { name: 'has_stars_list', passed: data.key?('stars') && data['stars'].is_a?(Array) && !data['stars'].empty? }
report[:checks] << { name: 'has_bodies_list', passed: data.key?('celestial_bodies') && data['celestial_bodies'].is_a?(Array) }

# Anchor Law mass check
min_mass = options[:anchor_min_mass_kg]
earth_mass_kg = 5.972e24

max_body_mass = 0.0

# Check star masses (if present)
if data['stars'].is_a?(Array)
  data['stars'].each do |star|
    mass = star['mass'] || star['mass_kg']
    if mass && mass.to_f > max_body_mass
      max_body_mass = mass.to_f
    end
  end
end

# Check body masses (convert Earth-relative if present)
if data['celestial_bodies'].is_a?(Array)
  data['celestial_bodies'].each do |body|
    mass_kg = nil
    if body.key?('mass_kg')
      mass_kg = body['mass_kg'].to_f
    elsif body.key?('mass_earth_relative')
      mass_kg = body['mass_earth_relative'].to_f * earth_mass_kg
    end
    if mass_kg && mass_kg > max_body_mass
      max_body_mass = mass_kg
    end
  end
end

report[:checks] << {
  name: 'anchor_law_min_mass_compliance',
  passed: max_body_mass >= min_mass,
  details: { min_mass_kg: min_mass, max_detected_mass_kg: max_body_mass }
}

# Optional metadata note
report[:checks] << { name: 'has_metadata', passed: data.key?('metadata') }

# Print report
puts JSON.pretty_generate(report)

# Exit non-zero if critical checks fail
critical_fail = report[:checks].any? { |c| c[:name] == 'has_stars_list' && !c[:passed] } ||
                report[:checks].any? { |c| c[:name] == 'has_galaxy_block' && !c[:passed] }
exit(critical_fail ? 2 : 0)
