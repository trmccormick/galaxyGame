require 'yaml'
require 'json'

module Lookup
  class MaterialLookupService < BaseLookupService
    # Use the GalaxyGame::Paths module for consistent path handling
    def self.base_materials_path
      GalaxyGame::Paths::GAME_DATA.join("resources", "materials")
    end
    
    MATERIAL_PATHS = {
      building: {
        path: -> { base_materials_path.join("building") },
        recursive_scan: true
      },
      byproducts: { 
        path: -> { base_materials_path.join("byproducts") },
        recursive_scan: true
      },
      chemicals: { 
        path: -> { base_materials_path.join("chemicals") },
        recursive_scan: true
      },
      gases: {
        path: -> { base_materials_path.join("gases") },
        recursive_scan: true
      },
      liquids: {
        path: -> { base_materials_path.join("liquids") },
        recursive_scan: true
      },
      processed: {
        path: -> { base_materials_path.join("processed") },
        direct_files: true,
        recursive_scan: true
      },
      raw: {
        path: -> { base_materials_path.join("raw") },
        recursive_scan: true
      }
    }

    def initialize
      super
      debug_material_paths
      @materials = load_materials
      
      # Debug what was loaded
      Rails.logger.debug "Loaded #{@materials.size} materials:"
      @materials.each do |m|
        Rails.logger.debug "- #{m['id']} (#{m['chemical_formula']})"
      end
    end

    def find_material(query)
      query = query.to_s.downcase
      found = @materials.find { |material| match_material?(material, query) }
      Rails.logger.debug "Material lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    rescue => e
      Rails.logger.error "Error finding material: #{e.message}"
      nil
    end

    def debug_paths
      puts "\nDEBUG: Material Lookup Paths"
      MATERIAL_PATHS.each do |type, config|
        if config.is_a?(Hash)
          puts "#{type}: #{config[:path]} (exists: #{Dir.exist?(config[:path])})"
          
          # Check for direct files if configured
          if config[:direct_files]
            direct_files = Dir.glob(File.join(config[:path], "*.json"))
            puts "  - Direct files: #{direct_files.size} found"
          end
          
          # If recursive scan is enabled, indicate it
          if config[:recursive_scan]
            puts "  - Recursive scan enabled for subfolders"
          end
        else
          puts "#{type}: #{config} (exists: #{Dir.exist?(config)})"
          if Dir.exist?(config)
            puts "  Files: #{Dir.glob(File.join(config, '*.json')).size}"
          end
        end
      end
      puts
    end

    # Add this class method
    def self.locate_gases_path
      # Always use the path system from GalaxyGame::Paths - the same one used in production
      primary_path = GalaxyGame::Paths::GAME_DATA.join("resources", "materials", "gases")
      
      if File.directory?(primary_path)
        Rails.logger.debug "Using gases path: #{primary_path}"
        return primary_path
      end
      
      # If path doesn't exist, log a warning but return the path anyway
      Rails.logger.warn "Gases path not found at: #{primary_path}"
      primary_path
    end

    def atmospheric_components(components)
      # Convert chemical formulas to standardized material data
      components.map do |component|
        chemical = component[:chemical]
        percentage = component[:percentage]
        
        material = find_material(chemical)
        
        # Skip components where we can't find the material
        next unless material
        
        # Return the standardized component with material data
        {
          material: material,
          percentage: percentage
        }
      end.compact
    end    

    private
    
    def debug_material_paths
      Rails.logger.debug "Material paths configuration:"
      MATERIAL_PATHS.each do |type, config|
        path = config.is_a?(Hash) ? config[:path].call : config
        exists = File.directory?(path) ? "EXISTS" : "MISSING"
        Rails.logger.debug "  #{type}: #{path} (#{exists})"
        
        if File.directory?(path)
          files = Dir.glob(File.join(path, "**", "*.json"))
          Rails.logger.debug "    Contains #{files.size} JSON files"
          files.each { |f| Rails.logger.debug "    - #{f}" }
        end
      end
    end
    
    def load_materials
      materials = []
      
      MATERIAL_PATHS.each do |type, config|
        if config.is_a?(Hash)
          base_path = config[:path].call
          Rails.logger.debug "Checking base path: #{base_path}"
          
          # Process direct files in this path if configured
          if config[:direct_files] && File.directory?(base_path)
            materials.concat(load_json_files(base_path))
          end
          
          # Process subfolders recursively if configured
          if config[:recursive_scan] && File.directory?(base_path)
            materials.concat(load_json_files_recursively(base_path))
          end
        else
          # Direct path (e.g., byproducts, solids)
          path = config.respond_to?(:call) ? config.call : config
          Rails.logger.debug "Checking direct path: #{path}"
          materials.concat(load_json_files(path))
        end
      end

      Rails.logger.debug "Loaded #{materials.size} materials in total"
      materials
    rescue => e
      Rails.logger.error "Error loading materials: #{e.message}"
      []
    end

    def load_json_files(path)
      return [] unless File.directory?(path)

      files = Dir.glob(File.join(path, "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files in #{path}"
      
      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded material from #{file}"
          data
        rescue JSON::ParserError => e
          Rails.logger.error "Error parsing #{file}: #{e.message}"
          nil
        rescue StandardError => e
          Rails.logger.error "Error loading #{file}: #{e.message}"
          nil
        end
      end.compact
    end

    # New method for recursive loading
    def load_json_files_recursively(base_path)
      return [] unless File.directory?(base_path)

      files = Dir.glob(File.join(base_path, "**", "*.json")) # ** scans all subdirectories
      Rails.logger.debug "Found #{files.size} JSON files recursively in #{base_path}"

      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded material from #{file}"
          data
        rescue JSON::ParserError => e
          Rails.logger.error "Error parsing #{file}: #{e.message}"
          nil
        rescue StandardError => e
          Rails.logger.error "Error loading #{file}: #{e.message}"
          nil
        end
      end.compact
    end

    def match_material?(material, query)
      return false unless material && query
      
      # Normalize query
      query_normalized = query.to_s.downcase
      
      # First check direct case-insensitive formula match
      if material['chemical_formula']&.downcase == query_normalized
        Rails.logger.debug "Matched '#{query}' to formula '#{material['chemical_formula']}'"
        return true
      end
      
      # Try simple case variations for chemical formulas like N2, O2, etc.
      if material['chemical_formula']&.downcase&.gsub(/\d/, '') == query_normalized&.gsub(/\d/, '')
        # Matches like "n2" to "N2" by comparing just the letters
        num = material['chemical_formula'].scan(/\d+/).first || ""
        if query_normalized.include?(num)
          Rails.logger.debug "Matched '#{query}' to formula '#{material['chemical_formula']}' by letter-number pattern"
          return true
        end
      end
      
      # Then check other searchable terms
      searchable_terms = [
        material['id']&.downcase,
        material['name']&.downcase
      ].compact
      
      # Check for matches in any terms
      searchable_terms.any? { |term| term == query_normalized || term.include?(query_normalized) }
    end

    # Add this method to get a property regardless of where it's stored
    def get_material_property(material, property_name)
      # Check top-level property first
      return material[property_name] if material.key?(property_name)
      
      # Then check in properties hash
      material.dig('properties', property_name)
    end

    # Then use this in your access methods, for example:
    def get_molar_mass(material_id)
      material = find_material(material_id)
      return nil unless material
      
      get_material_property(material, 'molar_mass')
    end
  end
end