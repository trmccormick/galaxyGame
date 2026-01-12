#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __dir__) rescue nil
require_relative 'check_blueprint_materials' # Load your existing checker

class CargoManifestAligner
  attr_reader :manifest_id, :manifest_data, :manifest_path
  
  def initialize(manifest_id)
    @manifest_id = manifest_id
    @manifest_path = File.join(BASE_DIR, 'starship-cargo-manifest', "#{manifest_id}.json")
    
    unless File.exist?(@manifest_path)
      puts "Error: Manifest #{manifest_id} not found at #{@manifest_path}"
      return
    end
    
    @manifest_data = JSON.parse(File.read(@manifest_path))
    @existing_units = find_all_existing_units
    @existing_materials = find_all_existing_materials
    
    puts "Found #{@existing_units.size} existing units"
    puts "Found #{@existing_materials.size} existing materials"
  end
  
  def align_manifest!
    unless @manifest_data
      puts "No manifest data loaded"
      return
    end
    
    puts "Aligning manifest: #{@manifest_id}"
    
    # Process installed units
    if @manifest_data['craft'] && @manifest_data['craft']['installed_units']
      @manifest_data['craft']['installed_units'].each do |unit|
        align_unit_reference!(unit)
      end
    end
    
    # Process stowed units if they exist
    if @manifest_data['craft'] && @manifest_data['craft']['stowed_units']
      @manifest_data['craft']['stowed_units'].each do |unit|
        align_unit_reference!(unit)
      end
    end
    
    # Process inventory items if they exist
    if @manifest_data['inventory'] && @manifest_data['inventory']['supplies']
      @manifest_data['inventory']['supplies'].each do |item|
        align_item_reference!(item)
      end
    end
    
    # Save the updated manifest
    save_aligned_manifest
    
    puts "Manifest alignment complete"
  end
  
  private
  
  def find_all_existing_units
    units = {}
    
    # Find all unit data files
    Dir.glob(File.join(BASE_DIR, 'units', '**', "*.json")).each do |file_path|
      begin
        data = JSON.parse(File.read(file_path))
        
        # Store with both ID and name for fuzzy matching
        if data['id']
          units[data['id'].downcase] = { 
            path: file_path, 
            id: data['id'],
            name: data['name'] || data['id'].gsub('_', ' ').capitalize
          }
        end
        
        if data['name']
          normalized_name = data['name'].downcase.gsub(/\s+/, '_')
          units[normalized_name] = { 
            path: file_path, 
            id: data['id'] || normalized_name,
            name: data['name']
          }
        end
      rescue => e
        puts "Error reading unit file #{file_path}: #{e.message}"
      end
    end
    
    units
  end
  
  def find_all_existing_materials
    materials = {}
    
    # Find all material files
    Dir.glob(File.join(BASE_DIR, 'materials', '**', "*.json")).each do |file_path|
      begin
        data = JSON.parse(File.read(file_path))
        
        # Store with both ID and name for fuzzy matching
        if data['id']
          materials[data['id'].downcase] = { 
            path: file_path, 
            id: data['id'],
            name: data['name'] || data['id'].gsub('_', ' ').capitalize
          }
        end
        
        if data['name']
          normalized_name = data['name'].downcase.gsub(/\s+/, '_')
          materials[normalized_name] = { 
            path: file_path, 
            id: data['id'] || normalized_name,
            name: data['name']
          }
        end
      rescue => e
        puts "Error reading material file #{file_path}: #{e.message}"
      end
    end
    
    materials
  end
  
  def align_unit_reference!(unit)
    original_name = unit['name']
    original_id = unit['id'] || unit['name']&.downcase&.gsub(/\s+/, '_')
    
    # Skip if no name/id
    return unless original_name || original_id
    
    # Try to find a matching unit
    match = find_best_unit_match(original_name, original_id)
    
    if match
      # Update the unit reference to use consistent ID and name
      unit['id'] = match[:id]
      unit['name'] = match[:name]
      
      if original_id != match[:id] || original_name != match[:name]
        puts "  ✓ Updated: '#{original_name || original_id}' → '#{match[:name]}' (#{match[:id]})"
      end
    else
      puts "  ✗ No match found for unit: #{original_name || original_id}"
    end
  end
  
  def align_item_reference!(item)
    original_name = item['name']
    original_id = item['id'] || item['name']&.downcase&.gsub(/\s+/, '_')
    
    # Skip if no name/id
    return unless original_name || original_id
    
    # Try to find a matching material
    match = find_best_material_match(original_name, original_id)
    
    if match
      # Update the item reference to use consistent ID and name
      item['id'] = match[:id]
      item['name'] = match[:name]
      
      if original_id != match[:id] || original_name != match[:name]
        puts "  ✓ Updated: '#{original_name || original_id}' → '#{match[:name]}' (#{match[:id]})"
      end
    else
      puts "  ✗ No match found for item: #{original_name || original_id}"
    end
  end
  
  def find_best_unit_match(name, id)
    return nil unless name || id
    
    # Try exact matches first
    if id && @existing_units[id.downcase]
      return @existing_units[id.downcase]
    end
    
    if name
      normalized_name = name.downcase.gsub(/\s+/, '_')
      if @existing_units[normalized_name]
        return @existing_units[normalized_name]
      end
    end
    
    # Try without common suffixes
    variations = []
    if id
      variations << id.downcase.gsub(/_unit$/, '')
      variations << id.downcase.gsub(/_module$/, '')
      variations << id.downcase.gsub(/_system$/, '')
      variations << "#{id.downcase}_data"
    end
    
    if name
      normalized_name = name.downcase.gsub(/\s+/, '_')
      variations << normalized_name.gsub(/_unit$/, '')
      variations << normalized_name.gsub(/_module$/, '')
      variations << normalized_name.gsub(/_system$/, '')
      variations << "#{normalized_name}_data"
    end
    
    variations.each do |variant|
      if @existing_units[variant]
        return @existing_units[variant]
      end
    end
    
    # Try fuzzy matching as a last resort
    closest_match = nil
    closest_distance = Float::INFINITY
    
    @existing_units.each do |key, unit_data|
      if name
        # Calculate string distance
        distance = levenshtein_distance(name.downcase, unit_data[:name].downcase)
        if distance < closest_distance && distance < 5  # Maximum 5 character difference
          closest_match = unit_data
          closest_distance = distance
        end
      end
      
      if id
        distance = levenshtein_distance(id.downcase, key.downcase)
        if distance < closest_distance && distance < 5  # Maximum 5 character difference
          closest_match = unit_data
          closest_distance = distance
        end
      end
    end
    
    closest_match
  end
  
  def find_best_material_match(name, id)
    # Similar to find_best_unit_match but for materials
    return nil unless name || id
    
    # Try exact matches first
    if id && @existing_materials[id.downcase]
      return @existing_materials[id.downcase]
    end
    
    if name
      normalized_name = name.downcase.gsub(/\s+/, '_')
      if @existing_materials[normalized_name]
        return @existing_materials[normalized_name]
      end
    end
    
    # Try without common suffixes
    variations = []
    if id
      variations << "#{id.downcase}_ore"
      variations << "#{id.downcase}_alloy"
      variations << "#{id.downcase}_compound"
    end
    
    if name
      normalized_name = name.downcase.gsub(/\s+/, '_')
      variations << "#{normalized_name}_ore"
      variations << "#{normalized_name}_alloy"
      variations << "#{normalized_name}_compound"
    end
    
    variations.each do |variant|
      if @existing_materials[variant]
        return @existing_materials[variant]
      end
    end
    
    # Try fuzzy matching as a last resort
    closest_match = nil
    closest_distance = Float::INFINITY
    
    @existing_materials.each do |key, material_data|
      if name
        distance = levenshtein_distance(name.downcase, material_data[:name].downcase)
        if distance < closest_distance && distance < 5
          closest_match = material_data
          closest_distance = distance
        end
      end
      
      if id
        distance = levenshtein_distance(id.downcase, key.downcase)
        if distance < closest_distance && distance < 5
          closest_match = material_data
          closest_distance = distance
        end
      end
    end
    
    closest_match
  end
  
  def levenshtein_distance(s, t)
    m = s.length
    n = t.length
    return m if n == 0
    return n if m == 0
    
    d = Array.new(m+1) {Array.new(n+1)}
    
    (0..m).each {|i| d[i][0] = i}
    (0..n).each {|j| d[0][j] = j}
    
    (1..n).each do |j|
      (1..m).each do |i|
        d[i][j] = if s[i-1] == t[j-1]
                    d[i-1][j-1]
                  else
                    [d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1]+1].min
                  end
      end
    end
    
    d[m][n]
  end
  
  def save_aligned_manifest
    # Create a backup of the original
    backup_path = "#{@manifest_path}.bak"
    FileUtils.cp(@manifest_path, backup_path) unless File.exist?(backup_path)
    
    # Save the updated manifest
    File.write(@manifest_path, JSON.pretty_generate(@manifest_data))
    puts "Updated manifest saved to #{@manifest_path}"
    puts "Original backed up to #{backup_path}"
  end
end

# Run the aligner if called directly
if __FILE__ == $0
  manifest_id = ARGV[0] || "ssc-000"
  aligner = CargoManifestAligner.new(manifest_id)
  aligner.align_manifest!
  
  # Re-run the check to verify
  puts "\nRe-checking manifest after alignment:"
  check_cargo_manifest(manifest_id)
end

def check_cargo_manifest(manifest_id)
  manifest_path = File.join(BASE_DIR, 'starship-cargo-manifest', "#{manifest_id}.json")
  
  unless File.exist?(manifest_path)
    puts "Manifest file not found: #{manifest_path}"
    return []
  end
  
  begin
    # Read the file content
    file_content = File.read(manifest_path)
    
    # Try to parse it, with error handling
    begin
      manifest = JSON.parse(file_content)
    rescue JSON::ParserError => e
      puts "JSON parsing error: #{e.message}"
      puts "First 100 chars of file: #{file_content[0..100]}"
      puts "Last 100 chars of file: #{file_content[-100..-1]}" if file_content.length > 100
      return []
    end
    
    puts "Checking cargo manifest: #{File.basename(manifest_path)}"
    puts "Description: #{manifest['description']}"
    
    missing_items = []
    found_items = []
    
    # Process installed units
    if manifest['craft'] && manifest['craft']['installed_units']
      # Rest of your existing code...
    end
    
    # Return the results
    missing_items
  rescue => e
    puts "Error reading manifest: #{e.message}"
    puts e.backtrace.join("\n") if ENV['DEBUG']
    []
  end
end