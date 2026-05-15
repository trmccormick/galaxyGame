#!/usr/bin/env ruby

require 'fileutils'
require 'date'
require 'digest'

# Configuration
BACKLOG_BASE = '/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/'
SOURCE_MONTH = '2026-02'
ARCHIVE_DIR = BACKLOG_BASE + 'archive/'

# Task type mapping - correct DOCUMENTATION and other misclassifications
TYPE_MAPPINGS = {
  'documentation' => 'REFACTOR',  # cleanup tasks
  'DOCUMENTATION' => 'REFACTOR',
  'feature' => 'FEATURE',
  'FEATURE' => 'FEATURE',
  'bug-fix' => 'BUG-FIX',
  'BUG-FIX' => 'BUG-FIX',
  'architecture' => 'ARCHITECTURE',
  'ARCHITECTURE' => 'ARCHITECTURE',
  'refactor' => 'REFACTOR',
  'REFACTOR' => 'REFACTOR',
  'test' => 'TEST',
  'TEST' => 'TEST',
  'data' => 'DATA',
  'DATA' => 'DATA',
  'chore' => 'CHORE',
  'CHORE' => 'CHORE',
  'performance' => 'PERFORMANCE',
  'PERFORMANCE' => 'PERFORMANCE'
}

FileUtils.mkdir_p(ARCHIVE_DIR)

# Hash to track seen content (for duplicate detection)
seen_content = {}
duplicates = []
fixes = []
analysis = []

Dir.glob(File.join(BACKLOG_BASE, SOURCE_MONTH, '*.md')).sort.each do |file|
  basename = File.basename(file)
  content = File.read(file)
  
  # Extract current type, priority from filename
  filename_parts = basename.gsub('.md', '').split('-')
  current_priority = filename_parts[2]  # should be at index 2 after date
  current_type_in_filename = filename_parts[3] || 'UNKNOWN'
  
  # Extract actual type and priority from content
  actual_type = 'FEATURE'  # default
  actual_priority = 'MEDIUM'  # default
  
  if content =~ /\*\*Type\*\*:\s*(\w+)/i
    actual_type_match = $1
    actual_type = TYPE_MAPPINGS[actual_type_match] || actual_type_match.upcase
  end
  
  if content =~ /\*\*Priority\*\*:\s*(\w+)/i
    actual_priority_match = $1
    actual_priority = actual_priority_match.upcase
  end
  
  # Check for duplicates by content hash
  content_hash = Digest::SHA256.hexdigest(content)
  if seen_content[content_hash]
    duplicates << {
      original: seen_content[content_hash],
      duplicate: file,
      match: 'EXACT_CONTENT'
    }
    analysis << "DUPLICATE: #{basename}"
    next
  end
  seen_content[content_hash] = file
  
  # Check if filename needs fixing
  needs_rename = false
  new_type = actual_type
  
  # Special handling for DOCUMENTATION files
  if current_type_in_filename.include?('DOCUMENTATION') && actual_type == 'REFACTOR'
    needs_rename = true
    new_type = actual_type
  elsif actual_type != current_type_in_filename.upcase
    needs_rename = true
  end
  
  # Fix case inconsistencies in content
  needs_content_fix = false
  new_content = content
  
  if content =~ /\*\*Type\*\*:\s*documentation\s*\n/i
    new_content = content.gsub(/\*\*Type\*\*:\s*documentation\s*\n/i, "**Type**: REFACTOR\n")
    needs_content_fix = true
  elsif content =~ /\*\*Type\*\*:\s*feature\s*\n/i
    new_content = content.gsub(/\*\*Type\*\*:\s*feature\s*\n/i, "**Type**: FEATURE\n")
    needs_content_fix = true
  end
  
  # Normalize priority to uppercase
  if content =~ /\*\*Priority\*\*:\s*[a-z]/
    new_content = new_content.gsub(/\*\*Priority\*\*:\s*([a-z]+)/, "**Priority**: \\1".upcase)
    needs_content_fix = true
  end
  
  # Construct new filename
  if needs_rename
    new_basename = "#{filename_parts[0]}-#{filename_parts[1]}-#{current_priority}-#{new_type}-#{filename_parts[4..-1].join('-')}"
    new_path = File.join(BACKLOG_BASE, SOURCE_MONTH, new_basename)
    
    # Apply fixes
    File.write(file, new_content) if needs_content_fix
    FileUtils.mv(file, new_path)
    
    fixes << {
      old: basename,
      new: new_basename,
      old_type: current_type_in_filename,
      new_type: new_type,
      content_fixed: needs_content_fix
    }
    analysis << "FIXED: #{basename} -> #{new_basename}"
  elsif needs_content_fix
    File.write(file, new_content)
    analysis << "CONTENT_FIXED: #{basename}"
  else
    analysis << "OK: #{basename}"
  end
end

# Report
puts "=" * 80
puts "MIGRATION FIX ANALYSIS REPORT"
puts "=" * 80
puts ""
puts "DUPLICATES FOUND: #{duplicates.length}"
duplicates.each do |dup|
  puts "  Original: #{File.basename(dup[:original])}"
  puts "  Duplicate: #{File.basename(dup[:duplicate])}"
  puts ""
end

puts ""
puts "FILES RENAMED: #{fixes.length}"
fixes.each do |fix|
  puts "  #{fix[:old]} -> #{fix[:new]}"
  puts "    Type: #{fix[:old_type]} -> #{fix[:new_type]}"
  puts "    Content fixed: #{fix[:content_fixed]}"
end

puts ""
puts "TOTAL PROCESSED: #{analysis.length}"
puts "  OK: #{analysis.count { |a| a.include?('OK:') }}"
puts "  Fixed: #{analysis.count { |a| a.include?('FIXED:') }}"
puts "  Content Fixed: #{analysis.count { |a| a.include?('CONTENT_FIXED:') }}"
puts "  Duplicates: #{analysis.count { |a| a.include?('DUPLICATE:') }}"

# Archive duplicates
if duplicates.any?
  puts ""
  puts "Archiving duplicates..."
  duplicates.each do |dup|
    duplicate_file = dup[:duplicate]
    archive_path = File.join(ARCHIVE_DIR, File.basename(duplicate_file))
    FileUtils.mv(duplicate_file, archive_path)
    puts "  Archived: #{File.basename(duplicate_file)}"
  end
end

puts ""
puts "✓ Fix process complete"
