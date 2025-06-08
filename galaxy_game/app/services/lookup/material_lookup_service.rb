require 'yaml'
require 'json' # Ensure JSON is required

module Lookup
  class MaterialLookupService < BaseLookupService
    MATERIAL_PATHS = {
      building: {
        path: Rails.root.join("app", "data", "resources", "materials", "building"),
        recursive_scan: true
      },
      byproducts: { 
        path: Rails.root.join("app", "data", "resources", "materials", "byproducts"),
        recursive_scan: true
      },
      chemicals: { 
        path: Rails.root.join("app", "data", "resources", "materials", "chemicals"),
        recursive_scan: true
      },
      gases: {
        path: Rails.root.join("app", "data", "resources", "materials", "gases"),
        recursive_scan: true
      },
      liquids: {
        path: Rails.root.join("app", "data", "resources", "materials", "liquids"),
        recursive_scan: true
      },
      processed: {
        path: Rails.root.join("app", "data", "resources", "materials", "processed"),
        direct_files: true,
        recursive_scan: true
      },
      raw: {
        path: Rails.root.join("app", "data", "resources", "materials", "raw"),
        recursive_scan: true
      }
      
      #solids: Rails.root.join("app", "data", "resources", "materials", "solids")
    }

    def initialize
      super
      Rails.logger.debug "Material paths: #{MATERIAL_PATHS.inspect}"
      @materials = load_materials
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
      # Check both paths that might exist
      standard_path = Rails.root.join("app", "data", "materials", "gases")
      alt_path = Rails.root.join("app", "data", "gases")
      
      # Return the path that exists, or the standard path if neither exists
      if File.directory?(standard_path)
        standard_path
      elsif File.directory?(alt_path)
        alt_path
      else
        standard_path # Return standard path as a fallback
      end
    end

    private

    def load_materials
      materials = []
      
      MATERIAL_PATHS.each do |type, config|
        if config.is_a?(Hash)
          base_path = config[:path]
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
          Rails.logger.debug "Checking direct path: #{config}"
          materials.concat(load_json_files(config))
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
      query = query.downcase.gsub(/[_\s-]/, ' ') # Normalize spaces, underscores, and hyphens
    
      searchable_terms = [
        material['id']&.downcase&.gsub(/[_\s-]/, ' '),
        material['name']&.downcase&.gsub(/[_\s-]/, ' '),
        material['chemical_formula']&.downcase,
        material['chemical_formula']&.gsub(/[^a-zA-Z0-9]/, '')&.downcase,
        *(material['aliases']&.map { |a| a.downcase.gsub(/[_\s-]/, ' ') } || [])
      ].compact
    
      searchable_terms.any? { |term| term == query }
    end
  end
end