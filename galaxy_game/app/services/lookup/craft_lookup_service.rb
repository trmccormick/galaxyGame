require 'yaml'
require 'json'
require 'pathname'

module Lookup
  class CraftLookupService < BaseLookupService
    # ✅ Use the actual path from GalaxyGame::Paths
    def self.base_crafts_path
      Pathname.new(GalaxyGame::Paths::CRAFTS_PATH)
    end
    
    # ✅ Match the paths that actually exist based on game_data_paths.rb
    CRAFT_PATHS = {
      atmospheric: {
        path: -> { Pathname.new(GalaxyGame::Paths::ATMOSPHERIC_CRAFTS_PATH) },
        recursive_scan: true
      },
      ground: {
        path: -> { Pathname.new(GalaxyGame::Paths::GROUND_CRAFTS_PATH) },
        recursive_scan: true        
      },
      space: {
        path: -> { Pathname.new(GalaxyGame::Paths::SPACE_CRAFTS_PATH) },
        recursive_scan: true
      }
    }

    def initialize
      begin
        @crafts = load_crafts
      rescue StandardError => e
        Rails.logger.error "Fatal error loading crafts: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @crafts = []
      end
    end

    def find_craft(craft_type)
      raise ArgumentError, 'Invalid craft name' if craft_type.blank?
      Rails.logger.debug("Finding craft: #{craft_type}")
      
      query = craft_type.to_s.downcase.strip
      
      # First attempt exact ID match for most specificity
      exact_match = @crafts.find { |craft| craft['id']&.downcase == query }
      return exact_match if exact_match
      
      # Then try exact name match
      exact_name_match = @crafts.find { |craft| craft['name']&.downcase == query }
      return exact_name_match if exact_name_match
      
      # Finally fall back to general matching
      found = @crafts.find { |craft| match_craft?(craft, query) }
      
      Rails.logger.debug "Craft lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    rescue JSON::ParserError, IOError => e
      Rails.logger.error "Error finding craft: #{e.message}"
      nil
    end

    def debug_paths
      puts "DEBUG: Craft Lookup Paths"
      puts "Base crafts path: #{self.class.base_crafts_path} (exists: #{Dir.exist?(self.class.base_crafts_path)})"
      CRAFT_PATHS.each do |type, config|
        path = config[:path].call
        puts "#{type}: #{path} (exists: #{Dir.exist?(path)})"
      end
    end

    private

    def load_crafts
      crafts = []
      
      begin
        CRAFT_PATHS.each do |type, config|
          base_path = config[:path].call
          Rails.logger.debug "Checking base path: #{base_path}"
          
          if config[:recursive_scan] && File.directory?(base_path)
            crafts.concat(load_json_files_recursively(base_path))
          end
        end
      rescue => e
        Rails.logger.error "Fatal error loading crafts: #{e.message}\n#{e.backtrace.join("\n")}"
        return []
      end

      Rails.logger.debug "Loaded #{crafts.size} crafts in total"
      crafts
    end

    def load_json_files_recursively(base_path)
      return [] unless File.directory?(base_path)

      files = Dir.glob(File.join(base_path, "**", "*.json"))
      Rails.logger.debug "Found #{files.size} JSON files recursively in #{base_path}"

      files.map do |file|
        begin
          data = JSON.parse(File.read(file))
          # Add the source path for folder structure matching
          data['_source_path'] = file
          Rails.logger.debug "Loaded craft from #{file}"
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

    def match_craft?(craft_data, query)
      return false unless craft_data.is_a?(Hash)
      
      query = query.to_s.downcase.strip
      
      # Skip very short queries to avoid too many false positives
      return false if query.length < 3
      
      # First priority: Exact ID match (most specific)
      if craft_data['id']&.downcase == query
        return true
      end
      
      # Second priority: Exact name match
      if craft_data['name']&.downcase == query
        return true
      end
      
      # Third priority: Exact category match
      if craft_data['category']&.downcase == query
        return true
      end
      
      # Fourth priority: Exact subcategory match
      if craft_data['subcategory']&.downcase == query
        return true
      end
      
      # Fifth priority: Exact craft_type match
      if craft_data['craft_type']&.downcase == query
        return true
      end
      
      # Check if the file path contains the query as a folder name
      # Example: '.../spacecraft/...' should match query 'spacecraft'
      if craft_data['_source_path'].is_a?(String)
        path_parts = craft_data['_source_path'].downcase.split('/')
        return true if path_parts.any? { |part| part == query }
      end
      
      # Lower priority: Partial ID matching (for queries of sufficient length)
      if query.length >= 3 && craft_data['id']&.downcase&.include?(query)
        return true
      end
      
      # Lowest priority: Partial name matching
      if query.length >= 3 && craft_data['name']&.downcase&.include?(query)
        return true
      end
      
      false
    end
  end
end