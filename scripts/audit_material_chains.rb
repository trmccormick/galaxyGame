#!/usr/bin/env ruby
# audit_material_chains.rb
# Audit manifest, blueprint, and material chains for completeness and playability.
# Outputs a report of missing, circular, or unobtainable dependencies.

require 'json'
require 'set'

# CONFIG: Update these paths as needed
MANIFEST_PATH = 'data/json-data/missions/lunar-precursor/lunar_precursor_manifest_v1.json'
BLUEPRINTS_DIR = 'data/json-data/blueprints/'
ITEMS_DIR = 'data/json-data/items/'
RESOURCES_DIR = 'data/json-data/resources/'
AUDIT_REPORT = 'audit_report.txt'

# Helper to load all JSON files in a directory
def load_json_dir(dir)
  Dir[File.join(dir, '*.json')].map { |f| [File.basename(f, '.json'), JSON.parse(File.read(f))] }.to_h
end

# Load data
def load_data
  manifest = JSON.parse(File.read(MANIFEST_PATH))
  blueprints = load_json_dir(BLUEPRINTS_DIR)
  items = load_json_dir(ITEMS_DIR)
  resources = load_json_dir(RESOURCES_DIR)
  [manifest, blueprints, items, resources]
end

# Recursively check if an item is buildable from obtainable resources
def buildable?(item, blueprints, items, resources, visited = Set.new, chain = [])
  return [true, []] if resources.key?(item)
  return [false, ["Missing resource: #{item}"]] unless blueprints.key?(item)
  return [false, ["Circular dependency: #{(chain + [item]).join(' -> ')}"]] if visited.include?(item)
  visited << item
  blueprint = blueprints[item]
  issues = []
  (blueprint['requirements'] || []).each do |req|
    ok, sub_issues = buildable?(req, blueprints, items, resources, visited.dup, chain + [item])
    issues.concat(sub_issues) unless ok
  end
  [issues.empty?, issues]
end

# Main audit logic
def audit
  manifest, blueprints, items, resources = load_data
  issues = []
  manifest_items = manifest['items'] || []
  manifest_items.each do |item|
    ok, item_issues = buildable?(item, blueprints, items, resources)
    unless ok
      issues << "Item: #{item} - Issues: #{item_issues.join('; ')}"
    end
  end
  File.open(AUDIT_REPORT, 'w') do |f|
    if issues.empty?
      f.puts 'All manifest items are buildable from obtainable resources.'
    else
      f.puts 'Audit Report: Issues Found'
      issues.each { |issue| f.puts issue }
    end
  end
  puts "Audit complete. See #{AUDIT_REPORT} for results."
end

audit if __FILE__ == $0
