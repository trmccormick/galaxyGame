#!/usr/bin/env ruby

require 'fileutils'

# Base path for materials
MATERIALS_PATH = "/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources/materials"

# Mapping from current folder to canonical path
MAPPING = {
  'geological' => 'raw/geological',
  'chemicals' => 'chemicals/industrial',
  'liquids' => 'liquids/reagents',
  'byproducts' => 'byproducts/waste',  # already correct, but ensure
  'gases' => 'gases',  # already correct
  'building' => 'building',  # already correct
  'processed' => 'processed',  # already correct
  'raw' => 'raw',  # already correct
  'synthetic_material' => 'processed/synthetic_material',  # assuming
  'components' => 'processed/components'  # assuming
}

def reorganize_materials
  MAPPING.each do |current_folder, canonical_path|
    current_path = File.join(MATERIALS_PATH, current_folder)
    canonical_full_path = File.join(MATERIALS_PATH, canonical_path)

    next unless Dir.exist?(current_path)

    puts "Moving files from #{current_path} to #{canonical_full_path}"

    # Ensure canonical directory exists
    FileUtils.mkdir_p(canonical_full_path)

    # Move all files and subdirs
    Dir.glob("#{current_path}/**/*").each do |file|
      next unless File.file?(file)

      relative_path = file.sub("#{current_path}/", '')
      target_path = File.join(canonical_full_path, relative_path)
      target_dir = File.dirname(target_path)
      FileUtils.mkdir_p(target_dir)
      FileUtils.mv(file, target_path)
      puts "Moved #{file} to #{target_path}"
    end

    # Remove empty directories
    Dir.glob("#{current_path}/**/*").select { |d| File.directory?(d) }.reverse_each do |dir|
      Dir.rmdir(dir) if Dir.empty?(dir)
    end
    Dir.rmdir(current_path) if Dir.empty?(current_path)
  end
end

# Execute
puts "Reorganizing materials to canonical structure..."
reorganize_materials
puts "Reorganization complete!"