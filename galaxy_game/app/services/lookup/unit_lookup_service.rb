module Lookup
  class UnitLookupService < BaseLookupService
    UNIT_PATHS = {
      'computer' => Rails.root.join('app', 'data', 'units', 'computer'),
      'droid' => Rails.root.join('app', 'data', 'units', 'droid'),
      'energy' => Rails.root.join('app', 'data', 'units', 'energy'),
      'housing' => Rails.root.join('app', 'data', 'units', 'housing'),
      'life_support' => Rails.root.join('app', 'data', 'units', 'life_support'),
      'production' => Rails.root.join('app', 'data', 'units', 'production'),
      'propulsion' => Rails.root.join('app', 'data', 'units', 'propulsion'),
      'storage' => Rails.root.join('app', 'data', 'units', 'storage'),
      'structure' => Rails.root.join('app', 'data', 'units', 'structure'), # New folder
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
          @cache[unit_id] = data
          return data
        end
      end

      # Then try finding by alias if direct lookup failed
      UNIT_PATHS.each do |category, path|
        Dir.glob(path.join("*_data.json")).each do |file_path|
          data = load_json_file(file_path)
          if data && data['aliases']&.include?(unit_id)
            @cache[unit_id] = data
            return data
          end
        end
      end

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