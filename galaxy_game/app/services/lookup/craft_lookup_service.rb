require 'json'
module Lookup
  class CraftLookupService < BaseLookupService
    BASE_PATH = Rails.root.join('app', 'data', 'crafts').freeze

    CRAFT_PATHS = {
      'deployable' => BASE_PATH.join('deployable'),
      'surface' => BASE_PATH.join('surface'),
      'transport' => BASE_PATH.join('transport')
    }.freeze

    def initialize
      super
      @crafts = load_crafts unless Rails.env.test?
      @cache = {}
    end   

    def find_craft(craft_name, craft_type, craft_sub_type = nil)
      craft_name = craft_name.to_s.downcase
      craft_type = craft_type.to_s.downcase
      craft_sub_type = craft_sub_type.to_s.downcase if craft_sub_type

      # Add validation checks
      raise ArgumentError, "Invalid craft name" if craft_name.empty?
      raise ArgumentError, "Invalid craft type: #{craft_type}" unless CRAFT_PATHS.key?(craft_type)

      cache_key = "#{craft_name}_#{craft_type}_#{craft_sub_type}"
      return @cache[cache_key] if @cache[cache_key]

      Rails.logger.debug("Looking for craft: #{craft_name}")
      
      path = CRAFT_PATHS[craft_type]

      # Check if directory structure exists
      unless self.class.craft_path_exists?(craft_type, craft_sub_type)
        raise StandardError, "Invalid craft directory structure"
      end
      
      # If sub_type is provided, only look in that directory
      if craft_sub_type
        pluralized_sub_type = craft_sub_type.pluralize
        file_path = path.join(pluralized_sub_type, "#{craft_name}_data.json")
        Rails.logger.debug("Checking path: #{file_path}")
        data = load_json_file(file_path)
        if data
          data['type'] = craft_type
          data['sub_type'] = pluralized_sub_type
          @cache[cache_key] = data
          return data
        end
      else
        # Only search all sub_types if no specific sub_type was requested
        Dir.glob(path.join('*', "#{craft_name}_data.json")).each do |file_path|
          data = load_json_file(file_path)
          if data
            sub_type = File.basename(File.dirname(file_path))
            data['sub_type'] = sub_type
            data['type'] = craft_type
            @cache[cache_key] = data
            return data
          end
        end
      end

      nil
    end

    def self.craft_path_exists?(craft_type, craft_sub_type = nil)
      return false unless CRAFT_PATHS.key?(craft_type)
      
      path = CRAFT_PATHS[craft_type]
      return File.directory?(path) unless craft_sub_type
      
      # Convert singular to plural for directory lookup
      pluralized_sub_type = craft_sub_type.to_s.pluralize
      File.directory?(path.join(pluralized_sub_type))
    rescue StandardError => e
      Rails.logger.error("Error checking craft path: #{e.message}")
      false
    end

    private

    def load_crafts
      CRAFT_PATHS.flat_map do |type, path|
        Dir.glob(File.join(path, "*/*.json")).map do |file|
          load_json_file(file)
        end.compact
      end
    end

    def load_json_file(file_path)
      return nil unless File.exist?(file_path)
      Rails.logger.debug("Loading JSON from: #{file_path}")
      data = JSON.parse(File.read(file_path))
      Rails.logger.debug("Loaded data: #{data.inspect}")
      data
    rescue JSON::ParserError => e
      Rails.logger.error("Error parsing JSON from #{file_path}: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("Error loading file #{file_path}: #{e.message}")
      nil
    end
  end
end