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

    def find_item(item_name, category = nil)
      item_name = item_name.to_s.downcase
      category = category.to_s.downcase if category

      return nil if item_name.empty?

      cache_key = "#{item_name}_#{category}"
      return @cache[cache_key] if @cache[cache_key]

      Rails.logger.debug("Looking for item: #{item_name}")

      if category
        raise ArgumentError, "Invalid category: #{category}" unless CATEGORIES.key?(category)
        path = File.join(BASE_PATH, CATEGORIES[category], "#{item_name}_data.json")
        data = load_json_file(path)
        if data
          data['category'] = category
          @cache[cache_key] = data
          return data
        end
      else
        CATEGORIES.each do |cat, folder|
          path = File.join(BASE_PATH, folder, "#{item_name}_data.json")
          data = load_json_file(path)
          if data
            data['category'] = cat
            @cache[cache_key] = data
            return data
          end
        end
      end

      nil
    end

    private

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