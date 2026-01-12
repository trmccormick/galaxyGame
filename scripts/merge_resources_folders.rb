#!/usr/bin/env ruby
require 'json'
require 'fileutils'

# Paths to the two source folders and the output merged folder (host machine paths)
RESTORED = '/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources'
GENERATED = '/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources new'
MERGED = '/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources_merged'

# Recursively collect all files in a folder
# Returns a hash: { relative_path => absolute_path }
def collect_files(base)
  files = {}
  Dir.chdir(base) do
    Dir.glob('**/*.json').each do |rel|
      files[rel] = File.join(base, rel)
    end
  end
  files
end

# Deep merge two hashes, preferring non-nil, non-empty, and more complete values
def deep_merge(a, b)
  return b if a.nil? || a == ''
  return a if b.nil? || b == ''
  if a.is_a?(Hash) && b.is_a?(Hash)
    merged = a.dup
    b.each do |k, v|
      merged[k] = deep_merge(a[k], v)
    end
    merged
  elsif a.is_a?(Array) && b.is_a?(Array)
    (a + b).uniq
  else
    # Prefer the more complete value (longer string, or non-empty)
    a.to_s.length >= b.to_s.length ? a : b
  end
end

# Main merge logic
restored_files = collect_files(RESTORED)
generated_files = collect_files(GENERATED)
all_keys = (restored_files.keys + generated_files.keys).uniq

all_keys.each do |rel|
  restored_path = restored_files[rel]
  generated_path = generated_files[rel]
  merged_path = File.join(MERGED, rel)
  FileUtils.mkdir_p(File.dirname(merged_path))

  if restored_path && generated_path
    # Merge JSON content
    begin
      restored_json = JSON.parse(File.read(restored_path))
      generated_json = JSON.parse(File.read(generated_path))
      merged_json = deep_merge(restored_json, generated_json)
      File.write(merged_path, JSON.pretty_generate(merged_json))
      puts "Merged: #{rel}"
    rescue => e
      puts "ERROR merging #{rel}: #{e.message}"
      # Fallback: copy restored
      FileUtils.cp(restored_path, merged_path) if restored_path
    end
  elsif restored_path
    FileUtils.cp(restored_path, merged_path)
    puts "Copied (restored): #{rel}"
  elsif generated_path
    FileUtils.cp(generated_path, merged_path)
    puts "Copied (generated): #{rel}"
  end
end

puts "\nMerge complete! Merged files are in: #{MERGED}"
puts "Both source folders remain unchanged for reference."
