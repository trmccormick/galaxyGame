module Lookup
  class ItemLookupService < BaseLookupService
    BASE_PATH = Rails.root.join('app', 'data', 'items').freeze

    CATEGORIES = {
      'consumable' => 'consumables',
      'container' => 'containers',
      'equipment' => 'equipment',
      'material' => 'materials'
    }.freeze

    # Use the same directory structure as UnitLookupService
    ITEM_PATHS = {
      'consumable' => Rails.root.join('app', 'data', 'items', 'consumable'),
      'container' => Rails.root.join('app', 'data', 'items', 'container'),
      'equipment' => Rails.root.join('app', 'data', 'items', 'equipment'),
      'material' => Rails.root.join('app', 'data', 'items', 'material')
    }.freeze

    def initialize
      super
      @items = load_items unless Rails.env.test?
      @cache = {}
    end

    def base_path
      @base_path ||= Rails.env.test? ? 
        Rails.root.join('spec/support/test_data/items') :
        Rails.root.join('data/json-data/items')
    end

    def find_item(item_id, category = nil)
      # Check cache first
      cache_key = "#{item_id}_#{category}"
      return @cache[cache_key] if @cache.key?(cache_key)

      Rails.logger.debug("Looking for item: #{item_id} in category: #{category}")
      
      # Find by specific category if provided
      if category
        category = category.to_s.downcase
        raise ArgumentError, "Invalid category: #{category}" unless ITEM_PATHS.key?(category)
        
        file_path = ITEM_PATHS[category].join("#{item_id}.json")
        Rails.logger.debug("Checking path: #{file_path}")
        
        data = load_json_file(file_path)
        if data
          data['category'] = category unless data.key?('category')
          @cache[cache_key] = data
          return data
        end
      else
        # Try all categories if none specified
        ITEM_PATHS.each do |cat, path|
          file_path = path.join("#{item_id}.json")
          Rails.logger.debug("Checking path: #{file_path}")
          
          data = load_json_file(file_path)
          if data
            data['category'] = cat unless data.key?('category')
            key = "#{item_id}_#{cat}"
            @cache[key] = data
            return data
          end
        end
      end
      
      nil
    end

    def items
      @items ||= load_items
    end

    private

    def load_items
      result = {}
      
      ITEM_PATHS.each do |category, path|
        result[category] = []
        Dir.glob(File.join(path, "*.json")).each do |file|
          data = load_json_file(file)
          if data
            data['category'] = category unless data.key?('category')
            result[category] << data
          end
        end
      end
      
      result
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