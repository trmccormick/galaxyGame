module Lookup
  class BaseLookupService
    attr_reader :cache, :data_path

    def initialize
      @cache = {}
      @data_path = Rails.root.join('app', 'data')
      
      # Skip validation in test env or if we're the base class
      return if Rails.env.test? || self.class == BaseLookupService
      
      begin
        validate_directory_structure
      rescue => e
        Rails.logger.error("Directory validation error: #{e.message}")
        # Don't raise here to allow graceful fallback
      end
    end

    protected

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
      # Only try to get constants if they're defined
      return unless self.class.const_defined?('BASE_PATH') && self.class.const_defined?('CATEGORIES')
      
      base_path = self.class.const_get('BASE_PATH')
      categories = self.class.const_get('CATEGORIES')
      
      Rails.logger.debug("Validating directory structure in: #{base_path}")
      
      if categories.is_a?(Hash)
        categories.each do |category, types|
          # Ensure path exists first
          category_path = File.join(base_path, category.to_s)
          Rails.logger.debug("Checking category path: #{category_path}")
          
          unless Dir.exist?(category_path)
            Rails.logger.warn("Missing category directory: #{category_path}")
            next # Skip this category instead of failing
          end
          
          # Only process types if it's an array/enumerable
          if types.respond_to?(:each)
            types.each do |type|
              path = File.join(base_path, category.to_s, type.to_s)
              Rails.logger.debug("Checking path: #{path}")
              
              unless Dir.exist?(path)
                Rails.logger.warn("Missing directory: #{path}")
                # Don't raise here, just log the warning
              end
            end
          end
        end
      elsif categories.respond_to?(:each)
        categories.each do |category|
          path = File.join(base_path, category.to_s)
          Rails.logger.debug("Checking path: #{path}")
          
          unless Dir.exist?(path)
            Rails.logger.warn("Missing directory: #{path}")
            # Don't raise here, just log the warning
          end
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