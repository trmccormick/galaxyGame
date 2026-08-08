module Lookup
  class StructureLookupService < BaseLookupService
    # Class-level cache: structures loaded once per process lifetime.
    def self.structures_cache
      @structures_cache ||= begin
        raw = load_structures_class
        raw.each_with_object({}) do |struct, h|
          next unless struct.is_a?(Hash) && struct['id']
          key = struct['id'].to_s.downcase.strip
          h[key] = struct
          h[struct['name'].to_s.downcase.strip] = struct if struct['name']
        end
      end
    end

    # Class-level loading (bypasses instance private methods).
    def self.load_structures_class
      structures = []
      
      self.class.structure_paths.each do |category, path|
        next unless File.directory?(path)
        structures.concat(load_json_files_class(path))
      end
      
      Rails.logger.debug "Loaded #{structures.size} structures in total"
      structures
    end

    def self.load_json_files_class(path)
      return [] unless File.directory?(path)
      Dir.glob(File.join(path, "*.json")).map do |file|
        JSON.parse(File.read(file))
      rescue JSON::ParserError, StandardError => e
        Rails.logger.error "Error loading #{file}: #{e.message}"
        nil
      end.compact
    end

    def self.reset_cache!
      @structures_cache = nil
    end

    def self.structure_paths
      {
        'habitation' => GalaxyGame::Paths::STRUCTURES_PATH.join('habitation'),
        'landing_infrastructure' => GalaxyGame::Paths::STRUCTURES_PATH.join('landing_infrastructure'),
        'life_support' => GalaxyGame::Paths::STRUCTURES_PATH.join('life_support'),
        'manufacturing' => GalaxyGame::Paths::STRUCTURES_PATH.join('manufacturing'),
        'power_generation' => GalaxyGame::Paths::STRUCTURES_PATH.join('power_generation'),
        'resource_extraction' => GalaxyGame::Paths::STRUCTURES_PATH.join('resource_extraction'),
        'resource_processing' => GalaxyGame::Paths::STRUCTURES_PATH.join('resource_processing'),
        'science_research' => GalaxyGame::Paths::STRUCTURES_PATH.join('science_research'),
        'storage' => GalaxyGame::Paths::STRUCTURES_PATH.join('storage'),
        'transportation' => GalaxyGame::Paths::STRUCTURES_PATH.join('transportation'),
        'space_stations' => GalaxyGame::Paths::STRUCTURES_PATH.join('space_stations')
      }
    end

    def initialize
      super
      @structures = Rails.env.test? ? {} : self.class.structures_cache
      @cache = {}
    end

    # Streamlined signature, removing the now-redundant 'type' argument
    def find_structure(structure_id)
      cache_key = structure_id.to_s 
      return @cache[cache_key] if @cache[cache_key]

      Rails.logger.debug("Looking for structure: #{structure_id} via exhaustive search.")
      
      # Search all directories exhaustively
      self.class.structure_paths.each do |category, path|
        file_path = path.join("#{structure_id}.json")
        Rails.logger.debug("Checking path: #{file_path}")
        data = load_json_file(file_path)
        
        if data
          @cache[cache_key] = data
          return data
        end
      end

      nil
    end

    def structures(type = nil)
      return @structures if @structures && type.nil?
      return @structures[type] if @structures && type

      if type.nil?
        @structures = {}
        self.class.structure_paths.each do |category, path|
          next unless Dir.exist?(path)
          @structures[category] = load_json_files(path)
        end
        return @structures
      else
        path = self.class.structure_paths[type]
        return [] unless path && Dir.exist?(path)
        load_json_files(path)
      end
    end

    private

    def validate_directory_structure
      Rails.logger.debug("Validating directory structure")
      self.class.structure_paths.each do |category, path|
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

    def load_structures
      result = {}
      self.class.structure_paths.each do |category, path|
        next unless Dir.exist?(path)
        result[category] = load_json_files(path)
      end
      result
    end

    def match_structure?(structure_data, query)
      return false unless structure_data && query
      
      # Normalize the query and the structure name/id for comparison
      query = query.to_s.downcase.gsub(/[_\s-]/, ' ')
      
      # Get all possible names to match against
      searchable_terms = [
        structure_data['id']&.to_s&.downcase&.gsub(/[_\s-]/, ' '),
        structure_data['name']&.to_s&.downcase&.gsub(/[_\s-]/, ' ')
      ]
      
      # Add aliases if they exist
      if structure_data['aliases'].is_a?(Array)
        searchable_terms.concat(structure_data['aliases'].map { |a| a.to_s.downcase.gsub(/[_\s-]/, ' ') })
      end
      
      # Return true if any of the terms match the query
      searchable_terms.compact.any? { |term| term == query }
    end
  end
end