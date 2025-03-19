# app/services/craft_lookup_service.rb
require 'json'
module Lookup
  class CraftLookupService < BaseLookupService
    CRAFT_PATHS = {
      'deployable' => Rails.root.join('app', 'data', 'crafts', 'deployable'),
      'surface' => Rails.root.join('app', 'data', 'crafts', 'surface'),
      'transport' => Rails.root.join('app', 'data', 'crafts', 'transport')
    }.freeze

    CATEGORIES = {
      'deployable' => ['drones', 'probes', 'satellites'],
      'surface' => ['landers', 'rovers'],
      'transport' => ['shuttles', 'spaceships']
    }.freeze

    def initialize
      super
      @crafts = load_crafts unless Rails.env.test?
      @cache = {}
    end

    def find_craft(craft_name, craft_type)
      craft_name = craft_name.to_s.downcase
      craft_type = normalize_type(craft_type)

      raise ArgumentError, "Invalid craft name" if craft_name.empty?
      raise ArgumentError, "Invalid craft type: #{craft_type}" unless valid_type?(craft_type)

      return find_test_craft(craft_name, craft_type) if Rails.env.test?
      @crafts.find { |craft| match_craft?(craft, craft_name, craft_type) }
    end

    private

    def load_crafts
      CRAFT_PATHS.flat_map do |category, path|
        CATEGORIES[category].flat_map do |type|
          craft_path = path.join(type)
          load_json_files(craft_path)
        end
      end
    end

    def match_craft?(craft, name, type)
      return false unless craft.is_a?(Hash) && craft['name'] && craft['type']
      
      craft['name'].to_s.downcase == name &&
        craft['type'].to_s.downcase == type
    end

    def find_test_craft(name, type)
      cache_key = "#{type}/#{name}"
      return @cache[cache_key] if @cache[cache_key]

      CATEGORIES.each do |category, types|
        next unless types.include?(type)
        
        path = CRAFT_PATHS[category].join(type)
        unless Dir.exist?(path)
          Rails.logger.error("Directory not found: #{path}")
          raise "Invalid craft directory structure: #{path}"
        end

        Dir.glob(File.join(path, "*.json")).each do |file|
          data = load_json_file(file)
          if data && match_craft?(data, name, type)
            @cache[cache_key] = data
            return data
          end
        end
      end
      nil
    end

    def normalize_type(type)
      type.to_s.downcase
    end

    def valid_type?(type)
      CATEGORIES.values.flatten.include?(type)
    end

    def load_json_files(path)
      Dir.glob(File.join(path, "*.json")).map do |file|
        data = load_json_file(file)
        data if data
      end.compact
    end

    def load_json_file(file_path)
      return @cache[file_path] if @cache[file_path]
      
      return nil unless File.exist?(file_path)
      data = JSON.parse(File.read(file_path))
      @cache[file_path] = data if data
      data
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid JSON in file: #{file_path} - #{e.message}")
      nil
    rescue => e
      Rails.logger.error("Error reading file: #{file_path} - #{e.message}")
      nil
    end
  end
end