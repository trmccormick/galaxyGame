require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class BlueprintLookupService < BaseLookupService
    # Cache the path to avoid repeated calls
    def self.base_blueprints_path
      @base_blueprints_path ||= begin
        path = Pathname.new(Rails.root).join(GalaxyGame::Paths::JSON_DATA, "blueprints")
        # Remove debug output - it's being called too frequently
        path
      end
    end
    
    # Add missing rigs path
    BLUEPRINT_PATHS = {
      components: {
        path: -> { base_blueprints_path.join("components") },
        recursive_scan: true
      },
      units: {
        path: -> { base_blueprints_path.join("units") },
        recursive_scan: true
      },
      modules: {
        path: -> { base_blueprints_path.join("modules") },
        recursive_scan: true
      },
      rigs: {
        path: -> { base_blueprints_path.join("rigs") },
        recursive_scan: true
      },
      facilities: {
        path: -> { base_blueprints_path.join("facilities") },
        recursive_scan: true
      },
      items: {
        path: -> { base_blueprints_path.join("items") },
        recursive_scan: true
      },
      structures: {
        path: -> { base_blueprints_path.join("structures") },
        recursive_scan: true
      },
      crafts: {
        path: -> { base_blueprints_path.join("crafts") },
        recursive_scan: true
      }
    }

    def initialize
      begin
        @blueprints = load_blueprints
      rescue StandardError => e
        Rails.logger.error "Fatal error loading blueprints: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @blueprints = []  # Initialize empty array instead of failing
      end
    end

    def find_blueprint(query, category = nil)
      query = query.to_s.downcase
      found = @blueprints.find { |blueprint| match_blueprint?(blueprint, query, category) }
      Rails.logger.debug "Blueprint lookup for '#{query}' (category: #{category}): #{found ? 'found' : 'not found'}"
      found
    rescue => e
      Rails.logger.error "Error finding blueprint: #{e.message}"
      nil
    end

    def all_blueprints
      @blueprints
    end

    def blueprints_by_category(category)
      return [] unless category.present?
      @blueprints.select { |blueprint| blueprint['category']&.downcase == category.downcase }
    end

    def debug_paths
      puts "DEBUG: Blueprint Lookup Paths"
      BLUEPRINT_PATHS.each do |type, config|
        path = config[:path].call
        puts "#{type}: #{path} (exists: #{Dir.exist?(path)})"
        
        if Dir.exist?(path)
          files = Dir.glob(File.join(path, "**", "*.json"))
          puts "  Contains #{files.size} JSON files"
          files.first(3).each { |f| puts "    - #{File.basename(f)}" }
          puts "    ... and #{files.size - 3} more" if files.size > 3
        end
      end
    end

    private
    
    def debug_blueprint_paths
      Rails.logger.debug "Blueprint paths configuration:"
      BLUEPRINT_PATHS.each do |type, config|
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
    
    def load_blueprints
      blueprints = []
      
      begin
        BLUEPRINT_PATHS.each do |type, config|
          if config.is_a?(Hash)
            base_path = config[:path].call
            Rails.logger.debug "Checking base path: #{base_path}"
            
            # Process direct files in this path if configured
            if config[:direct_files] && File.directory?(base_path)
              blueprints.concat(load_json_files(base_path))
            end
            
            # Process subfolders recursively if configured
            if config[:recursive_scan] && File.directory?(base_path)
              blueprints.concat(load_json_files_recursively(base_path))
            end
          else
            # Direct path
            path = config.respond_to?(:call) ? config.call : config
            Rails.logger.debug "Checking direct path: #{path}"
            blueprints.concat(load_json_files(path))
          end
        end
      rescue => e
        Rails.logger.error "Fatal error loading blueprints: #{e.message}\n#{e.backtrace.join("\n")}"
        # Return an empty array but log the error
        return []
      end

      Rails.logger.debug "Loaded #{blueprints.size} blueprints in total"
      blueprints
    end

    def load_json_files(path)
      return [] unless File.directory?(path)

      files = Dir.glob(File.join(path, "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files in #{path}"
      
      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          Rails.logger.debug "Loaded blueprint from #{file}"
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
          Rails.logger.debug "Loaded blueprint from #{file}"
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

    def match_blueprint?(blueprint, query, category = nil)
      return false unless blueprint.is_a?(Hash)

      query_normalized = query.to_s.downcase.strip

      # Filter by category if specified
      if category.present?
        blueprint_category = blueprint['category']&.downcase
        return false unless blueprint_category == category.downcase
      end

      # PRIORITY 1: Exact ID or unit_id match
      if (blueprint['id']&.downcase == query_normalized) || (blueprint['unit_id']&.downcase == query_normalized)
        Rails.logger.debug "Matched by ID/unit_id: #{blueprint['id'] || blueprint['unit_id']} == #{query}"
        return true
      end

      # PRIORITY 2: Exact name match  
      if blueprint['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{blueprint['name']} == #{query}"
        return true
      end

      # PRIORITY 3: Alias match
      if blueprint['aliases'].is_a?(Array)
        aliases = blueprint['aliases'].map(&:downcase)
        if aliases.include?(query_normalized)
          Rails.logger.debug "Matched by alias: #{blueprint['aliases']} contains #{query}"
          return true
        end
      end

      # PRIORITY 4: Partial ID match (SAFE - only for long queries)
      if query_normalized.length >= 3 && blueprint['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{blueprint['id']} contains #{query}"
        return true
      end

      # PRIORITY 5: Partial name match (SAFE - only for long queries) 
      if query_normalized.length >= 3 && blueprint['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{blueprint['name']} contains #{query}"
        return true
      end

      false
    end
  end
end