require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class UnitLookupService < BaseLookupService
    # ✅ REMOVED: base_units_path is no longer needed as UNIT_PATHS will directly reference specific GalaxyGame::Paths.
    # This removes a layer of indirection and makes paths explicit.
    # (Confirm this method is physically removed from your file)
    # def self.base_units_path
    #   Pathname.new(GalaxyGame::Paths::UNITS_PATH)
    # end
    
    UNIT_PATHS = {
      # All paths now directly reference the specific GalaxyGame::Paths constants.
      # Removed redundant Pathname.new() wrapper as GalaxyGame::Paths constants are already Pathname objects.
      computer: {
        path: -> { GalaxyGame::Paths::COMPUTER_UNITS_PATH },
        recursive_scan: true
      },
      droid: {
        path: -> { GalaxyGame::Paths::DROID_UNITS_PATH },
        recursive_scan: true
      },
      energy: {
        path: -> { GalaxyGame::Paths::ENERGY_UNITS_PATH },
        recursive_scan: true
      },
      # ✅ FIX: Changed key from 'habitat' to 'habitats' to match folder name and path constant.
      habitats: { # Key matches the folder and the constant
        path: -> { GalaxyGame::Paths::HABITATS_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      life_support: {
        path: -> { GalaxyGame::Paths::LIFE_SUPPORT_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      processing: {
        path: -> { GalaxyGame::Paths::PROCESSING_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      production: {
        path: -> { GalaxyGame::Paths::PRODUCTION_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      propulsion: {
        path: -> { GalaxyGame::Paths::PROPULSION_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      storage: {
        path: -> { GalaxyGame::Paths::STORAGE_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      structure: {
        path: -> { GalaxyGame::Paths::STRUCTURE_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      specialized: {
        path: -> { GalaxyGame::Paths::SPECIALIZED_UNITS_PATH }, # Direct constant usage
        recursive_scan: true
      },
      # Robot units categories - already correctly using direct constants.
      robots_deployment: {
        path: -> { GalaxyGame::Paths::ROBOTS_DEPLOYMENT_UNITS_PATH },
        recursive_scan: true
      },
      robots_construction: {
        path: -> { GalaxyGame::Paths::ROBOTS_CONSTRUCTION_UNITS_PATH },
        recursive_scan: true
      },
      robots_maintenance: {
        path: -> { GalaxyGame::Paths::ROBOTS_MAINTENANCE_UNITS_PATH },
        recursive_scan: true
      },
      robots_exploration: {
        path: -> { GalaxyGame::Paths::ROBOTS_EXPLORATION_UNITS_PATH },
        recursive_scan: true
      },
      robots_life_support: {
        path: -> { GalaxyGame::Paths::ROBOTS_LIFE_SUPPORT_UNITS_PATH },
        recursive_scan: true
      },
      robots_logistics: {
        path: -> { GalaxyGame::Paths::ROBOTS_LOGISTICS_UNITS_PATH },
        recursive_scan: true
      },
      robots_resource: {
        path: -> { GalaxyGame::Paths::ROBOTS_RESOURCE_UNITS_PATH },
        recursive_scan: true
      }
    }

    # Add class method to clear cached instances
    def self.reset!
      @instance = nil if instance_variable_defined?(:@instance)
    end

    def self.instance
      @instance ||= new
    end
    
    def initialize(force_reload: false)
      return if @instance && !force_reload # Prevent multiple instances
      
      begin
        @units = load_units
      rescue StandardError => e
        Rails.logger.error "Fatal error loading units: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @units = []
      end
      
      @instance = self
    end
    
    # Add method to reload units if needed
    def reload_units!
      @units = load_units
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
          base_path = config[:path].call
          Rails.logger.debug "Checking base path: #{base_path}"
          
          if config[:direct_files] && File.directory?(base_path)
            units.concat(load_json_files(base_path))
          end
          
          if config[:recursive_scan] && File.directory?(base_path)
            units.concat(load_json_files_recursively(base_path))
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

      files = Dir.glob(path.join("*.json")) # Using Pathname#join
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

      files = Dir.glob(base_path.join("**", "*.json")) # Using Pathname#join
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

      # PRIORITY 1: Exact unit_type match
      if unit_data['unit_type']&.downcase == query_normalized
        Rails.logger.debug "Matched by unit_type: #{unit_data['unit_type']} == #{query}"
        return true
      end

      # PRIORITY 2: Exact ID match
      if unit_data['id']&.downcase == query_normalized
        Rails.logger.debug "Matched by ID: #{unit_data['id']} == #{query}"
        return true
      end

      # PRIORITY 3: Exact name match  
      if unit_data['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{unit_data['name']} == #{query}"
        return true
      end

      # PRIORITY 4: Alias match
      if unit_data['aliases'].is_a?(Array)
        aliases = unit_data['aliases'].map(&:downcase)
        if aliases.include?(query_normalized)
          Rails.logger.debug "Matched by alias: #{unit_data['aliases']} contains #{query}"
          return true
        end
      end

      # PRIORITY 5: Partial ID match (SAFE - only for long queries)
      if query_normalized.length >= 3 && unit_data['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{unit_data['id']} contains #{query}"
        return true
      end

      # PRIORITY 6: Partial name match (SAFE - only for long queries) 
      if query_normalized.length >= 3 && unit_data['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{unit_data['name']} contains #{query}"
        return true
      end

      false
    end
  end
end