module Lookup
  class BaseLookupService
    BASE_PATH = Rails.root.join('app', 'data')
    attr_reader :cache

    def initialize
      @cache = {}
      validate_directory_structure if self.class.const_defined?('CATEGORIES')
    end

    protected

    def data_path
      BASE_PATH
    end

    def search_in_path(path, search_term)
      Rails.logger.debug("Searching in path: #{path}")
      
      Dir.glob(File.join(path, "*.json")).each do |file|
        Rails.logger.debug("Checking file: #{file}")
        data = load_json_file(file)
        
        if data && match_data?(data, search_term)
          cache_result(search_term, data)
          return data
        end
      end
      
      nil
    end

    def load_json_file(file_path)
      return @cache[file_path] if @cache.key?(file_path)
      
      Rails.logger.debug("Loading file: #{file_path}")
      data = JSON.parse(File.read(file_path))
      @cache[file_path] = data
      data
    rescue JSON::ParserError => e
      Rails.logger.error("Invalid JSON in file: #{file_path} - #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("Error reading file: #{file_path} - #{e.message}")
      nil
    end

    def match_data?(data, search_term)
      raise NotImplementedError, "#{self.class} must implement match_data?"
    end

    def cache_result(key, data)
      @cache[key.to_s.downcase] = data
    end

    def validate_directory_structure
      base_path = self.class.const_get('BASE_PATH')
      categories = self.class.const_get('CATEGORIES')
      
      Rails.logger.debug("Validating directory structure in: #{base_path}")
      
      if categories.is_a?(Hash)
        categories.each do |category, types|
          types.each do |type|
            path = File.join(base_path, category, type)
            Rails.logger.debug("Checking path: #{path}")
            raise "Missing directory: #{path}" unless Dir.exist?(path)
          end
        end
      else
        categories.each do |category|
          path = File.join(base_path, category)
          Rails.logger.debug("Checking path: #{path}")
          raise "Missing directory: #{path}" unless Dir.exist?(path)
        end
      end
    end

    def normalize_term(term)
      term = term[:type] if term.is_a?(Hash)
      term.to_s.downcase
    end

    def load_json_files(directory)
      Dir.glob(File.join(directory, "**/*.json")).map do |file|
        load_json_file(file)
      end.compact
    end

    def match_by_properties(data, search_term, fields = ['name', 'id', 'unit_type'])
      return false unless data && search_term

      search_term = search_term.to_s.downcase
      searchable_terms = fields.map { |field| data[field]&.downcase }.compact
      aliases = data['aliases']&.map(&:downcase) || []
      
      (searchable_terms + aliases).any? do |term|
        term == search_term || 
        term.include?(search_term) || 
        search_term.include?(term)
      end
    end

    def find_in_categories(base_path, categories, search_term)
      categories.each do |category|
        path = base_path.join(category)
        next unless Dir.exist?(path)

        # Try exact match first
        exact_file = path.join("#{search_term}_data.json")
        if File.exist?(exact_file)
          data = load_json_file(exact_file)
          return data if data
        end

        # Search all files in category
        Dir.glob(path.join('*_data.json')).each do |file_path|
          data = load_json_file(file_path)
          next unless data
          return data if match_by_properties(data, search_term)
        end
      end
      nil
    end
  end
end