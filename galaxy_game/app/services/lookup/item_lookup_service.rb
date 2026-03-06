module Lookup
  class ItemLookupService < BaseLookupService
    # Provide class method for spec compatibility
    def self.base_items_path
      GalaxyGame::Paths::ITEMS_PATH
    end
    # BASE_PATH removed; use GalaxyGame::Paths constants instead

    CATEGORIES = {
      'consumable' => 'consumables',
      'container' => 'containers',
      'equipment' => 'equipment',
      'material' => 'materials'
    }.freeze

    # Use the same directory structure as UnitLookupService
    ITEM_PATHS = {
      'consumable' => GalaxyGame::Paths::CONSUMABLE_ITEMS_PATH,
      'container' => GalaxyGame::Paths::CONTAINER_ITEMS_PATH,
      'equipment' => GalaxyGame::Paths::EQUIPMENT_ITEMS_PATH,
      'material' => GalaxyGame::Paths::MATERIALS_PATH
    }.freeze

    def initialize
      super
      @items = load_items
      @cache = {}
    end

    def base_path
      @base_path ||= GalaxyGame::Paths::ITEMS_PATH
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
      
      # Dynamic item creation for scrap, processed, and used items
      normalized_id = item_id.to_s.strip.downcase.gsub(' ', '_')
      normalized_name = item_id.to_s.strip

      if normalized_name.match?(/scrap/i)
        base = normalized_name.sub(/ scrap/i, '')
        return {
          'id' => normalized_id,
          'name' => normalized_name,
          'type' => 'scrap_material',
          'category' => 'recyclable'
        }
      elsif normalized_name.match?(/processed/i)
        base = normalized_name.sub(/processed /i, '')
        return {
          'id' => normalized_id,
          'name' => normalized_name,
          'type' => 'processed_material',
          'category' => 'processed'
        }
      elsif normalized_name.match?(/used/i)
        base = normalized_name.sub(/used /i, '')
        return {
          'id' => normalized_id,
          'name' => normalized_name,
          'type' => 'used_component',
          'category' => 'used'
        }
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