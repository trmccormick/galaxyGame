# frozen_string_literal: true

require 'securerandom'

module Logistics
  class ManifestGenerator
    class ManifestError < StandardError; end

    # items: [{ resource: "Steel", quantity: 100 }, ...]
    def self.create_manifest(source_settlement, destination_settlement, items)
      raise ManifestError, 'Items list cannot be empty' if items.nil? || items.empty?

      # Validate inventory (assume source_settlement.inventory responds to #has_item?)
      items.each do |item|
        unless source_settlement.inventory&.has_item?(item[:resource], item[:quantity])
          raise ManifestError, "Source does not have enough #{item[:resource]}"
        end
      end

      # Assign categories and unit costs
      manifest_items = items.map do |item|
        category = category_for(item[:resource])
        unit_cost = Settlements::CostAnalyzer.current_import_price(item[:resource], destination_settlement) || 0.0
        {
          resource: item[:resource],
          quantity: item[:quantity],
          category: category,
          unit_cost: unit_cost
        }
      end

      manifest = Logistics::Manifest.create!(
        manifest_id: SecureRandom.uuid,
        source_settlement: source_settlement,
        destination_settlement: destination_settlement,
        created_at: Time.now,
        items: manifest_items,
        total_items: manifest_items.sum { |i| i[:quantity].to_i },
        total_cost: manifest_items.sum { |i| i[:quantity].to_f * i[:unit_cost].to_f },
        status: :pending
      )
      manifest
    end

    # Simple category assignment (stub, should use blueprint system)
    def self.category_for(resource_name)
      # TODO: Integrate with blueprint system for real categories
      case resource_name.downcase
      when /water|oxygen|hydrogen|methane|argon|neon|carbon dioxide|ammonia/
        :raw_material
      when /component|circuit|board|panel/
        :component
      when /food|ration|consumable/
        :consumable
      when /steel|iron|coal|regolith/
        :raw_material
      else
        :critical_resource
      end
    end
  end
end
