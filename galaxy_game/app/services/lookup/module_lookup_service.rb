require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class ModuleLookupService < BaseLookupService
    # ✅ REMOVE: CATEGORIES constant - not needed
    
    # ✅ ADD: Use GalaxyGame::Paths like MaterialLookupService
    def self.base_modules_path
      Pathname.new(Rails.root).join(GalaxyGame::Paths::JSON_DATA, "operational_data", "modules")
    end
    
    # ✅ KEEP: Module paths configuration like MATERIAL_PATHS
    MODULE_PATHS = {
      computer: {
        path: -> { base_modules_path.join("computer") },
        recursive_scan: true
      },
      defense: {
        path: -> { base_modules_path.join("defense") },
        recursive_scan: true
      },
      energy: {
        path: -> { base_modules_path.join("energy") },
        recursive_scan: true
      },
      infrastructure: {
        path: -> { base_modules_path.join("infrastructure") },
        recursive_scan: true
      },
      life_support: {
        path: -> { base_modules_path.join("life_support") },
        recursive_scan: true
      },
      power: {
        path: -> { base_modules_path.join("power") },
        recursive_scan: true
      },
      production: {
        path: -> { base_modules_path.join("production") },
        recursive_scan: true
      },
      propulsion: {
        path: -> { base_modules_path.join("propulsion") },
        recursive_scan: true
      },
      science: {
        path: -> { base_modules_path.join("science") },
        recursive_scan: true
      },
      storage: {
        path: -> { base_modules_path.join("storage") },
        recursive_scan: true
      },
      utility: {
        path: -> { base_modules_path.join("utility") },
        recursive_scan: true
      }
    }

    def initialize
      begin
        @modules = load_modules
      rescue StandardError => e
        Rails.logger.error "Fatal error loading modules: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @modules = []  # ✅ FIX: Initialize empty array instead of failing
      end
    end

    def find_module(module_type)
      Rails.logger.debug("Finding module: #{module_type}")
      return nil unless module_type.present?
      
      query = module_type.to_s.downcase
      found = @modules.find { |mod| match_module?(mod, query) }
      Rails.logger.debug "Module lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    rescue => e
      Rails.logger.error "Error finding module: #{e.message}"
      nil
    end

    def debug_paths
      puts "DEBUG: Module Lookup Paths"
      MODULE_PATHS.each do |type, config|
        # ✅ FIX: Call the proc to get the actual path
        path = config[:path].call
        puts "#{type}: #{path} (exists: #{Dir.exist?(path)})"
      end
    end

    private

    def load_modules
      modules = []
      
      begin
        MODULE_PATHS.each do |type, config|
          if config.is_a?(Hash)
            base_path = config[:path].call
            Rails.logger.debug "Checking base path: #{base_path}"
            
            # Process direct files in this path if configured
            if config[:direct_files] && File.directory?(base_path)
              modules.concat(load_json_files(base_path))
            end
            
            # Process subfolders recursively if configured
            if config[:recursive_scan] && File.directory?(base_path)
              modules.concat(load_json_files_recursively(base_path))
            end
          else
            # Direct path
            path = config.respond_to?(:call) ? config.call : config
            Rails.logger.debug "Checking direct path: #{path}"
            modules.concat(load_json_files(path))
          end
        end
      rescue => e
        Rails.logger.error "Fatal error loading modules: #{e.message}\n#{e.backtrace.join("\n")}"
        # Return an empty array but log the error
        return []
      end

      Rails.logger.debug "Loaded #{modules.size} modules in total"
      modules
    end

    def load_json_files(path)
      return [] unless File.directory?(path)

      files = Dir.glob(File.join(path, "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files in #{path}"
      
      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded module from #{file}"
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
          Rails.logger.debug "Loaded module from #{file}"
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

    def match_module?(module_data, query)
      return false unless module_data.is_a?(Hash)

      query_normalized = query.to_s.downcase.strip

      # ✅ PRIORITY 1: Exact module_type match
      if module_data['module_type']&.downcase == query_normalized
        Rails.logger.debug "Matched by module_type: #{module_data['module_type']} == #{query}"
        return true
      end

      # ✅ PRIORITY 2: Exact ID match
      if module_data['id']&.downcase == query_normalized
        Rails.logger.debug "Matched by ID: #{module_data['id']} == #{query}"
        return true
      end

      # ✅ PRIORITY 3: Exact name match  
      if module_data['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{module_data['name']} == #{query}"
        return true
      end

      # ✅ PRIORITY 4: Alias match
      if module_data['aliases'].is_a?(Array)
        aliases = module_data['aliases'].map(&:downcase)
        if aliases.include?(query_normalized)
          Rails.logger.debug "Matched by alias: #{module_data['aliases']} contains #{query}"
          return true
        end
      end

      # ✅ PRIORITY 5: Partial ID match (SAFE - only for long queries)
      if query_normalized.length >= 3 && module_data['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{module_data['id']} contains #{query}"
        return true
      end

      # ✅ PRIORITY 6: Partial name match (SAFE - only for long queries) 
      if query_normalized.length >= 3 && module_data['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{module_data['name']} contains #{query}"
        return true
      end

      false
    end

    def debug_module_paths
      Rails.logger.debug "Module paths configuration:"
      MODULE_PATHS.each do |type, config|
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
  end
end