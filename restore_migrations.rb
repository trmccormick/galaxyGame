#!/usr/bin/env ruby

require 'fileutils'

# Migration mapping from migration.md (corrected targets)
MIGRATION_MAP_2026_02 = {
  '2026-02-11-HIGH-AI_MANAGER-STRATEGIC-EVALUATION-ALGORITHM.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-STRATEGIC-EVALUATION-ALGORITHM.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-CRITICAL-MONITOR-FIX-MONITOR-LOADING.md' => {
    target: '2026-02/2026-02-11-CRITICAL-BUG-FIX-MONITOR-LOADING.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-ADMIN-ADD-CELESTIAL-BODY-SHOW-VIEW.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-ADD-CELESTIAL-BODY-SHOW-VIEW.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-ATMOSPHERIC-MAINTENANCE.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-ATMOSPHERIC-MAINTENANCE-AI-FRAMEWORK.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-RESOURCE-ALLOCATION-ENGINE.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-RESOURCE-ALLOCATION-ENGINE.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-SERVICE-INTEGRATION.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-SERVICE-INTEGRATION.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-SITE-SELECTION-ALGORITHM.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-SITE-SELECTION-ALGORITHM.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-SYSTEM-DISCOVERY-IMPLEMENTATION.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-SYSTEM-DISCOVERY-IMPLEMENTATION.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-WORMHOLE-INTEGRATION.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-WORMHOLE-INTEGRATION.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  },
  '2026-02-11-HIGH-AI_MANAGER-TASK1-SCSS-LAYOUT.md' => {
    target: '2026-02/2026-02-11-HIGH-FEATURE-TASK1-SCSS-LAYOUT.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/archive/backlog_april_2026/'
  }
}

MIGRATION_MAP_2026_05 = {
  '2026-05-01-MEDIUM-ARCHITECTURE-AI-MANAGER-RESOURCE-SPAWNING-SYSTEM.md' => {
    target: '2026-05/2026-05-01-MEDIUM-ARCHITECTURE-AI-MANAGER-RESOURCE-SPAWNING-SYSTEM.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/on-hold/'
  },
  '2026-05-01-MEDIUM-REFACTOR-LUNAR-PIPELINE-RAKE-MODERNIZE-V2.md' => {
    target: '2026-05/2026-05-01-MEDIUM-REFACTOR-LUNAR-PIPELINE-RAKE-MODERNIZE-V2.md',
    source_path: '/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/on-hold/'
  }
}

BACKLOG_BASE = '/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog'

# Create 2026-02
puts "Restoring 2026-02 tasks..."
MIGRATION_MAP_2026_02.each do |source_file, mapping|
  source = mapping[:source_path] + source_file
  target = File.join(BACKLOG_BASE, mapping[:target])
  
  if File.exist?(source)
    FileUtils.mkdir_p(File.dirname(target))
    FileUtils.cp(source, target)
    puts "✓ #{File.basename(target)}"
  else
    puts "✗ Source not found: #{source}"
  end
end

# Create 2026-05 (on-hold migrations)
puts "\nRestoring 2026-05 tasks from on-hold..."
MIGRATION_MAP_2026_05.each do |source_file, mapping|
  source = mapping[:source_path] + source_file
  target = File.join(BACKLOG_BASE, mapping[:target])
  
  if File.exist?(source)
    FileUtils.mkdir_p(File.dirname(target))
    FileUtils.cp(source, target)
    puts "✓ #{File.basename(target)}"
  else
    puts "✗ Source not found: #{source}"
  end
end

puts "\n✓ Restoration complete"
