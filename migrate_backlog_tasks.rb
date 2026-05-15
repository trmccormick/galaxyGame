#!/usr/bin/env ruby

require 'fileutils'
require 'date'

# Configuration
BACKLOG_DIR = '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
OUTPUT_BASE = '/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/'

# Task date distribution strategy:
# - Spread tasks across April 2026 based on:
#   1. Content analysis (type, priority extracted from filename/content)
#   2. Dependency chains (features before bugs, architecture before implementation)
#   3. Rough monthly load balancing (avoiding Mondays/post-weekends if possible)

def parse_task_filename(filename)
  # Extract type, priority from content
  {
    name: filename.gsub('.md', '').gsub('.MD', ''),
    path: File.join(BACKLOG_DIR, filename)
  }
end

def extract_priority_from_content(content)
  case content
  when /priority|HIGH|high/i
    'HIGH'
  when /medium|MEDIUM/i
    'MEDIUM'
  when /low|LOW|chore|CHORE/i
    'LOW'
  else
    'MEDIUM' # default
  end
end

def extract_type_from_content(content)
  case content
  when /architecture|ARCHITECTURE|structure|design/i
    'ARCHITECTURE'
  when /feature|FEATURE|implement|new/i
    'FEATURE'
  when /refactor|REFACTOR|cleanup|clean|reorgan/i
    'REFACTOR'
  when /bug|BUG|fix|issue|broken/i
    'BUG-FIX'
  when /test|TEST|spec|rspec/i
    'TEST'
  when /doc|DOC|document|guide|readme/i
    'DOC'
  when /data|DATA|migration|seed/i
    'DATA'
  when /chore|CHORE|maintenance|maintain/i
    'CHORE'
  when /performance|PERFORMANCE|optimize|optimiz/i
    'PERFORMANCE'
  else
    'FEATURE'
  end
end

def infer_date_for_task(task_name, content)
  # Strategy: Spread tasks across April 2-30, 2026
  # - Earlier: Architecture, high-priority features, refactors
  # - Middle: Regular features, data work
  # - Later: Bug fixes, chores, tests
  
  date_range = (2..30).to_a
  
  # Extract priority
  priority = extract_priority_from_content(content)
  task_type = extract_type_from_content(content)
  
  # Date assignment strategy:
  case task_type
  when 'ARCHITECTURE'
    base_day = 3 + rand(5)  # April 3-8
  when 'REFACTOR'
    base_day = 8 + rand(5)  # April 8-13
  when 'FEATURE'
    base_day = 13 + rand(8) # April 13-21
  when 'DATA'
    base_day = 10 + rand(8) # April 10-18
  when 'BUG-FIX'
    base_day = 18 + rand(10) # April 18-28
  when 'TEST'
    base_day = 20 + rand(8)  # April 20-28
  when 'CHORE'
    base_day = 25 + rand(5)  # April 25-30
  else
    base_day = 15 + rand(10) # April 15-25
  end
  
  # Adjust for priority within type
  if priority == 'HIGH'
    base_day = [base_day - 3, date_range.min].max
  elsif priority == 'LOW'
    base_day = [base_day + 3, date_range.max].min
  end
  
  # Return date object
  Date.new(2026, 4, [base_day, date_range.max].min)
end

def create_task_file(task_name, content, inferred_date)
  priority = extract_priority_from_content(content)
  task_type = extract_type_from_content(content)
  
  # Create task title from filename
  title = task_name.upcase
    .gsub('_', ' ')
    .gsub(/^(TASK|AI|ADD|IMPLEMENT)[\s_]+/, '')
    .gsub('-', ' ')
  
  # Build output filename
  date_str = inferred_date.strftime('%Y-%m-%d')
  output_filename = "#{date_str}-#{priority}-#{task_type}-#{title.gsub(' ', '-')}.md"
  output_dir = File.join(OUTPUT_BASE, inferred_date.strftime('%Y-%m'))
  output_path = File.join(output_dir, output_filename)
  
  # Avoid duplicates
  return if File.exist?(output_path)
  
  # Create directory
  FileUtils.mkdir_p(output_dir)
  
  # Extract first useful content
  summary = content.split("\n").first(5).join("\n").strip
  summary = summary[0...200] + "..." if summary.length > 200
  
  # Build task file content
  task_content = <<~TASK
    # #{date_str}-#{priority}-#{task_type}-#{title}
    
    **Agent:** GPT-4.1 (0.25x)
    **Priority:** #{priority}
    **Type:** #{task_type}
    **Status:** BACKLOG
    
    ## Context
    Migrated from backlog_april_2026 archive.
    
    ## Summary
    #{summary}
    
    ---
    
    ## Original Content
    
    #{content}
  TASK
  
  # Write file
  File.write(output_path, task_content)
  
  puts "✓ #{output_filename}"
  
  output_path
end

# Main migration loop
def migrate_all_tasks
  Dir.glob(File.join(BACKLOG_DIR, '*.md')) do |file|
    basename = File.basename(file)
    # Skip already-dated files
    next if basename.match?(/^\d{4}-\d{2}-\d{2}/)
    
    content = File.read(file)
    task_name = File.basename(file, '.md')
    inferred_date = infer_date_for_task(task_name, content)
    
    create_task_file(task_name, content, inferred_date)
  rescue => e
    puts "✗ Error processing #{basename}: #{e.message}"
  end
end

puts "Starting migration of undated backlog tasks..."
migrate_all_tasks
puts "Migration complete!"
