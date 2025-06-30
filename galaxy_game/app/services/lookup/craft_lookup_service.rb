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
      query = craft_type.to_s.downcase
      found = @crafts.find { |craft| match_craft?(craft, query) }
      Rails.logger.debug "Craft lookup for '#{query}': #{found ? 'found' : 'not found'}"
      found
    rescue JSON::ParserError, IOError => e
      Rails.logger.error "Error finding craft: #{e.message}"
      nil
    end

    def debug_paths
      puts "DEBUG: Craft Lookup Paths"
      puts "Base crafts path: #{base_crafts_path} (exists: #{Dir.exist?(base_crafts_path)})"
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

      query_normalized = query.to_s.downcase.strip

      # Same priority matching as UnitLookupService
      if craft_data['craft_type']&.downcase == query_normalized
        Rails.logger.debug "Matched by craft_type: #{craft_data['craft_type']} == #{query}"
        return true
      end

      if craft_data['id']&.downcase == query_normalized
        Rails.logger.debug "Matched by ID: #{craft_data['id']} == #{query}"
        return true
      end

      if craft_data['name']&.downcase == query_normalized
        Rails.logger.debug "Matched by name: #{craft_data['name']} == #{query}"
        return true
      end

      if craft_data['aliases'].is_a?(Array)
        aliases = craft_data['aliases'].map(&:downcase)
        if aliases.include?(query_normalized)
          Rails.logger.debug "Matched by alias: #{craft_data['aliases']} contains #{query}"
          return true
        end
      end

      if query_normalized.length >= 3 && craft_data['id']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial ID: #{craft_data['id']} contains #{query}"
        return true
      end

      if query_normalized.length >= 3 && craft_data['name']&.downcase&.include?(query_normalized)
        Rails.logger.debug "Matched by partial name: #{craft_data['name']} contains #{query}"
        return true
      end

      false
    end
  end
end