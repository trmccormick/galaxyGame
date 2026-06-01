# frozen_string_literal: true

module Logistics
  class ImportRequestGenerator
    class ImportRequestError < StandardError; end

    # Generate an import request for a shortage
    # shortage_data: { resource, current, target, amount, critical }
    def self.generate_import_request(settlement, shortage_data)
      # Phase 1: Cost analysis
      cost_analysis = Settlements::CostAnalyzer.compare_costs(shortage_data[:resource], settlement)
      # Phase 2: Manifest generation
      manifest = Logistics::ManifestGenerator.create_manifest(
        settlement, # source (assume import from market)
        settlement, # destination
        [{ resource: shortage_data[:resource], quantity: shortage_data[:amount] }]
      )
      # Create ImportRequest
      import_request = Logistics::ImportRequest.create!(
        settlement: settlement,
        resource: shortage_data[:resource],
        quantity_needed: shortage_data[:amount],
        cost_analysis: cost_analysis,
        manifest: manifest,
        status: :created
      )
      # Optionally: create Market::Order and trigger trade execution
      # ...integration code here...
      import_request
    rescue => e
      raise ImportRequestError, e.message
    end
  end
end
