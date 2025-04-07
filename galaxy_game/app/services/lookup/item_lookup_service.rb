module Lookup
  class ItemLookupService < BaseLookupService
    BASE_PATH = Rails.root.join('app', 'data', 'items').freeze

    CATEGORIES = {
      'consumable' => 'consumables',
      'container' => 'containers',
      'equipment' => 'equipment',
      'material' => 'materials'
    }.freeze

    ITEM_PATHS = {
      'consumable' => BASE_PATH.join('consumables'),
      'container' => BASE_PATH.join('containers'),
      'equipment' => BASE_PATH.join('equipment'),
      'material' => BASE_PATH.join('materials')
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

    def find_item(item_name, category = nil)
      item_name = normalize_name(item_name)
      return nil if item_name.empty?

      cache_key = "#{item_name}_#{category}"
      return @cache[cache_key] if @cache[cache_key]

      if category
        find_in_category(item_name, category)
      else
        find_across_categories(item_name)
      end
    end

    private

    def normalize_name(name)
      name.to_s.downcase.gsub(/\s+/, '_')
    end

    def find_in_category(name, category)
      category = category.to_s.downcase
      raise ArgumentError, "Invalid category: #{category}" unless CATEGORIES.key?(category)
      
      path = base_path.join(CATEGORIES[category], "#{name}_data.json")
      load_and_cache(path, category)
    end

    def find_across_categories(name)
      CATEGORIES.each do |category, folder|
        path = base_path.join(folder, "#{name}_data.json")
        data = load_and_cache(path, category)
        return data if data
      end
      nil
    end

    def load_and_cache(path, category)
      data = load_json_file(path)
      return nil unless data

      data['category'] = category
      cache_key = "#{data['name'].downcase}_#{category}"
      @cache[cache_key] = data
      data
    end

    def load_items
      ITEM_PATHS.flat_map do |category, path|
        Dir.glob(File.join(path, "*.json")).map do |file|
          data = load_json_file(file)
          data['category'] = category if data
          data
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