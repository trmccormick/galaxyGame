# frozen_string_literal: true

module Logistics
  class ImportRequestGenerator < BaseService
    class ImportRequestError < StandardError; end

    # Single-request API expected by specs: generates one import request for a shortage
    def self.generate_import_request(source:, destination:, shortage:)
      # Compare costs to decide details (spec stubs `compare_costs`)
      cost_data = Settlements::CostAnalyzer.compare_costs(shortage[:resource], destination)

      # Build manifest; propagate failures as ImportRequestError
      begin
        items = [{ resource: shortage[:resource] || shortage[:material], quantity: shortage[:amount] || shortage[:need] || shortage[:quantity_needed] }]
        manifest = Logistics::ManifestGenerator.create_manifest(source, destination, items)  # Fixed: source != destination
      rescue StandardError => e
        Rails.logger.error "Manifest generation failed: #{e.message}"
        raise ImportRequestError, "Manifest generation failed: #{e.message}"
      end

      import_req = Logistics::ImportRequest.create!(
        settlement_id: destination.id,
        manifest_id: manifest.id,
        resource: shortage[:resource] || shortage[:material],
        quantity_needed: shortage[:amount] || shortage[:need] || shortage[:quantity_needed],
        cost_analysis: cost_data,
        tier: (shortage[:critical] ? 'survival' : 'expansion'),
        priority: (shortage[:critical] ? 1 : 2),
        category: (shortage[:critical] ? 'consumable' : 'other'),
        status: 'created'
      )

      import_req
    end
  end
end
