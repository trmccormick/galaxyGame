require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class UnitLookupService < BaseLookupService
    # ✅ FIX: Use GalaxyGame::Paths like MaterialLookupService
    def self.base_units_path
      Pathname.new(GalaxyGame::Paths::UNITS_PATH)
    end
    
    # ✅ FIX: Use UNIT_PATHS configuration like MATERIAL_PATHS
    UNIT_PATHS = {
      computer: {
        path: -> { Pathname.new(GalaxyGame::Paths::COMPUTER_UNITS_PATH) },
        recursive_scan: true
      },
      droid: {
        path: -> { Pathname.new(GalaxyGame::Paths::DROID_UNITS_PATH) },
        recursive_scan: true
      },
      energy: {
        path: -> { Pathname.new(GalaxyGame::Paths::ENERGY_UNITS_PATH) },
        recursive_scan: true
      },
      habitat: {
        path: -> { base_units_path.join("habitat") },
        recursive_scan: true
      },
      life_support: {
        path: -> { base_units_path.join("life_support") },
        recursive_scan: true
      },
      processing: {
        path: -> { base_units_path.join("processing") },
        recursive_scan: true
      },
      production: {
        path: -> { base_units_path.join("production") },
        recursive_scan: true
      },
      propulsion: {
        path: -> { base_units_path.join("propulsion") },
        recursive_scan: true
      },
      storage: {
        path: -> { base_units_path.join("storage") },
        recursive_scan: true
      },
      structure: {
        path: -> { base_units_path.join("structure") },
        recursive_scan: true
      },
      various: {
        path: -> { base_units_path.join("various") },
        recursive_scan: true
      }
    }

    def initialize
      begin
        @units = load_units
      rescue StandardError => e
        Rails.logger.error "Fatal error loading units: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @units = []  # ✅ FIX: Initialize empty array instead of failing
      end
    end

    def find_unit(unit_type)
      Rails.logger.debug("Finding unit: #{unit_type}")
      return nil unless unit_type.present?
      
      query = unit_type.to_s.downcase
      found = @units.find { |unit| match_unit?(unit, query) }
      Rails.logger.debug "Unit lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    rescue => e
      Rails.logger.error "Error finding unit: #{e.message}"
      nil
    end

    def debug_paths
      puts "DEBUG: Unit Lookup Paths"
      UNIT_PATHS.each do |type, config|
        path = config[:path].call
        puts "#{type}: #{path} (exists: #{Dir.exist?(path)})"
      end
    end

    private

    def load_units
      units = []
      
      begin
        UNIT_PATHS.each do |type, config|
          if config.is_a?(Hash)
            base_path = config[:path].call
            Rails.logger.debug "Checking base path: #{base_path}"
            
            # Process direct files in this path if configured
            if config[:direct_files] && File.directory?(base_path)
              units.concat(load_json_files(base_path))
            end
            
            # Process subfolders recursively if configured
            if config[:recursive_scan] && File.directory?(base_path)
              units.concat(load_json_files_recursively(base_path))
            end
          else
            # Direct path
            path = config.respond_to?(:call) ? config.call : config
            Rails.logger.debug "Checking direct path: #{path}"
            units.concat(load_json_files(path))
          end
        end
      rescue => e
        Rails.logger.error "Fatal error loading units: #{e.message}\n#{e.backtrace.join("\n")}"
        return []
      end

      Rails.logger.debug "Loaded #{units.size} units in total"
      units
    end

    def load_json_files(path)
      return [] unless File.directory?(path)

      files = Dir.glob(File.join(path, "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files in #{path}"
      
      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded unit from #{file}"
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

    def load_json_files_recursively(base_path)
      return [] unless File.directory?(base_path)

      files = Dir.glob(File.join(base_path, "**", "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files recursively in #{base_path}"

      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded unit from #{file}"
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

    def match_unit?(unit_data, query)
      return false unless unit_data.is_a?(Hash)

      query_normalized = query.to_s.downcase.strip

      # ✅ PRIORITY 1: Exact unit_type match
      if unit_data['unit_type']&.downcase == query_normalized
        Rails.logger.debug "Matched by unit_type: #{unit_data['unit_type']} == #{query}"
        return true
      end

      # ✅ PRIORITY 2: Exact ID match
      if unit_data['id']&.downcase == query_normalized
        Rails.logger.debug "Matched by ID: #{unit_data['id']} == #{query}"
        return true
      end

      # ✅ PRIORITY 3: Exact name match  
      if unit_data['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{unit_data['name']} == #{query}"
        return true
      end

      # ✅ PRIORITY 4: Alias match
      if unit_data['aliases'].is_a?(Array)
        aliases = unit_data['aliases'].map(&:downcase)
        if aliases.include?(query_normalized)
          Rails.logger.debug "Matched by alias: #{unit_data['aliases']} contains #{query}"
          return true
        end
      end

      # ✅ PRIORITY 5: Partial ID match (SAFE - only for long queries)
      if query_normalized.length >= 3 && unit_data['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{unit_data['id']} contains #{query}"
        return true
      end

      # ✅ PRIORITY 6: Partial name match (SAFE - only for long queries) 
      if query_normalized.length >= 3 && unit_data['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{unit_data['name']} contains #{query}"
        return true
      end

      false
    end
  end
end