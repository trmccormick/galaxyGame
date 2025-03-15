module Lookup
  class ItemLookupService < BaseLookupService
    ITEM_PATHS = {
      consumables: Rails.root.join("app", "data", "items", "consumables"),
      containers: Rails.root.join("app", "data", "items", "containers"),
      equipment: Rails.root.join("app", "data", "items", "equipment")
    }

    def initialize
      super
      @items = load_items
    end

    def items
      @items
    end

    def find_item(query)
      query = query.to_s.downcase
      @items.find { |item| match_item?(item, query) }
    end

    private

    def load_items
      ITEM_PATHS.values.flat_map do |path|
        load_json_files(path)
      end
    end

    def match_item?(item, query)
      return false unless item && query && !query.empty?

      searchable_terms = [
        item['id']&.downcase,
        item['name']&.downcase
      ].compact

      searchable_terms.any? do |term| 
        term.include?(query.tr('-', '_')) || 
        query.include?(term)
      end
    end
  end
end