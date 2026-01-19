require 'yaml'
require 'json'
require 'pathname'  # Add this to ensure Pathname is available

module Lookup
  class MaterialLookupService < BaseLookupService
    # Use the GalaxyGame::Paths module for consistent path handling
    def self.base_materials_path
      # Return a Pathname object, not a String
      Pathname.new(Rails.root).join(GalaxyGame::Paths::JSON_DATA, "resources", "materials")
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
      begin
        @materials = load_materials
      rescue StandardError => e
        Rails.logger.error "Fatal error loading materials: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @materials = []  # ✅ FIX: Initialize empty array instead of failing
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
      puts "DEBUG: Material Lookup Paths"
      MATERIAL_PATHS.each do |type, config|
        # ✅ FIX: Call the proc to get the actual path
        path = config[:path].call
        puts "#{type}: #{path} (exists: #{Dir.exist?(path)})"
      end
    end

    # Add this class method
    def self.locate_gases_path
      # Always use the path system from GalaxyGame::Paths - the same one used in production
      primary_path = File.join(GalaxyGame::Paths::JSON_DATA, "resources", "materials", "gases")
      
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
    
    # Add this method to get a property regardless of where it's stored
    def get_material_property(material, property_name)
      # ✅ FIX: Handle nil material gracefully
      return nil if material.nil? || property_name.nil?
      
      # Check top-level properties first
      return material[property_name] if material.key?(property_name)
      
      # Check nested properties
      if material['properties'] && material['properties'].key?(property_name)
        return material['properties'][property_name]
      end
      
      # Special handling for molar_mass - also check molar_mass_g_mol
      if property_name == 'molar_mass' && material['properties'] && material['properties'].key?('molar_mass_g_mol')
        return material['properties']['molar_mass_g_mol']
      end
      
      nil
    end    

    # ✅ MOVE: From private to public section
    def get_molar_mass(material_id)
      material = find_material(material_id)
      return nil unless material
      
      get_material_property(material, 'molar_mass')
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
      
      begin
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
      rescue => e
        Rails.logger.error "Fatal error loading materials: #{e.message}\n#{e.backtrace.join("\n")}"
        # Return an empty array but log the error
        return []
      end

      Rails.logger.debug "Loaded #{materials.size} materials in total"
      materials
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
          Rails.logger.error "Invalid JSON in file: #{file} - #{e.message}"
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
          Rails.logger.error "Invalid JSON in file: #{file} - #{e.message}"
          nil
        rescue StandardError => e
          Rails.logger.error "Error loading #{file}: #{e.message}"
          nil
        end
      end.compact
    end

    def match_material?(material, query)
      return false unless material.is_a?(Hash)

      query_normalized = query.to_s.downcase.strip

      # ✅ PRIORITY 1: Exact chemical formula match (case sensitive for chemistry)
      chemical_formula = get_material_property(material, 'chemical_formula')
      if chemical_formula == query.to_s.strip
        Rails.logger.debug "Matched by exact formula: #{chemical_formula} == #{query}"
        return true
      end

      # ✅ PRIORITY 2: Exact chemical formula match (case insensitive)
      if chemical_formula&.downcase == query_normalized
        Rails.logger.debug "Matched by formula: #{chemical_formula} == #{query}"
        return true
      end

      # ✅ PRIORITY 3: Exact ID match
      if material['id']&.downcase == query_normalized
        Rails.logger.debug "Matched by ID: #{material['id']} == #{query}"
        return true
      end

      # ✅ PRIORITY 4: Exact name match  
      if material['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{material['name']} == #{query}"
        return true
      end

      # ✅ PRIORITY 5: Partial ID match (SAFE - only for long queries)
      if query_normalized.length >= 3 && material['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{material['id']} contains #{query}"
        return true
      end

      # ✅ PRIORITY 6: Partial name match (SAFE - only for long queries) 
      if query_normalized.length >= 3 && material['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{material['name']} contains #{query}"
        return true
      end

      false
    end

    # Keep other methods in private section
  end
end