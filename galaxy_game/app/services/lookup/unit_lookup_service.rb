module Lookup
  class UnitLookupService < BaseLookupService
    UNIT_PATHS = {
      'energy' => Rails.root.join('app', 'data', 'units', 'energy'),
      'housing' => Rails.root.join('app', 'data', 'units', 'housing'),
      'life_support' => Rails.root.join('app', 'data', 'units', 'life_support'),
      'production' => Rails.root.join('app', 'data', 'units', 'production'),
      'propulsion' => Rails.root.join('app', 'data', 'units', 'propulsion'),
      'storage' => Rails.root.join('app', 'data', 'units', 'storage'),
      'various' => Rails.root.join('app', 'data', 'units', 'various')
    }.freeze

    def initialize
      super
      @units = load_units unless Rails.env.test?
      @cache = {}
    end

    def find_unit(unit_id)
      return @cache[unit_id] if @cache[unit_id]

      Rails.logger.debug("Looking for unit: #{unit_id}")
      
      # First try direct lookup
      UNIT_PATHS.each do |category, path|
        file_path = path.join("#{unit_id}_data.json")
        Rails.logger.debug("Checking path: #{file_path}")
        data = load_json_file(file_path)
        if data
          Rails.logger.debug("Found unit data: #{data.inspect}")
          @cache[unit_id] = data
          return data
        end
      end

      # If not found, search through all files checking aliases
      UNIT_PATHS.each do |category, path|
        Dir.glob(File.join(path, "*.json")).each do |file_path|
          data = load_json_file(file_path)
          next unless data
          
          if data['aliases']&.include?(unit_id)
            Rails.logger.debug("Found unit data via alias: #{data.inspect}")
            @cache[unit_id] = data
            return data
          end
        end
      end

      Rails.logger.debug("Unit not found: #{unit_id}")
      nil
    end

    def units
      return @units if @units

      @units = {}
      UNIT_PATHS.each do |category, path|
        next unless Dir.exist?(path)

        @units[category] = load_json_files(path)
      end
      @units
    end

    private

    def validate_directory_structure
      Rails.logger.debug("Validating directory structure")
      UNIT_PATHS.each do |category, path|
        Rails.logger.debug("Checking path: #{path}")
        raise "Missing directory: #{path}" unless Dir.exist?(path)
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

    def load_json_files(path)
      Dir.glob(File.join(path, "*.json")).map do |file|
        load_json_file(file)
      end.compact
    end

    def load_units
      UNIT_PATHS.flat_map do |category, path|
        load_json_files(path)
      end
    end
  end
end