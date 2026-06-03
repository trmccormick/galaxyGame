# frozen_string_literal: true

module Logistics
  class ImportRequestGenerator < BaseService
    class ImportRequestError < StandardError; end
    
    def self.generate_import_requests(settlement, shortage_report)
      return [] unless shortage_report[:viable]
      return [] if shortage_report[:survival_shortages].empty?
      
      requests = []
      
      shortage_report[:survival_shortages].each do |shortage|
        # Phase 1: Calculate Cost for this specific shortage item
        # Use the public CostAnalyzer API: compare_costs(resource_name, settlement)
        cost_data = Settlements::CostAnalyzer.compare_costs(
          shortage[:material],
          settlement
        )
        
        # Phase 2: Generate Manifest for this batch/cost
        manifest_result = Logistics::ManifestGenerator.generate_manifest(cost_data)
        manifest_id = manifest_result[:id] || manifest_result.id
        
        # Phase 3: Create and Persist ImportRequest
        import_req = Logistics::ImportRequest.create!(
          settlement_id: settlement.id,
          manifest_id: manifest_id,
          resource: shortage[:material],
          quantity_needed: shortage[:need],
          cost_analysis: cost_data,
          tier: "survival", # Explicitly set as survival tier
          priority: 1,      # Critical priority for survival items
          category: "critical",
          status: "pending"
        )
        
        requests << import_req if import_req
      end
      
      requests
    end
    
    # Helper to handle single request generation (alias for ease of use)
    def self.generate_request(settlement, shortage_report)
      all_requests = generate_import_requests(settlement, shortage_report)
      return [] if all_requests.empty?
      all_requests.first
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create ImportRequest: #{e.message}"
      []
    end

    # Single-request API expected by specs: generates one import request for a shortage
    def self.generate_import_request(settlement, shortage)
      # Compare costs to decide details (spec stubs `compare_costs`)
      cost_data = Settlements::CostAnalyzer.compare_costs(shortage[:resource], settlement)

      # Build manifest; propagate failures as ImportRequestError
      begin
        items = [{ resource: shortage[:resource] || shortage[:material], quantity: shortage[:amount] || shortage[:need] || shortage[:quantity_needed] }]
        manifest = Logistics::ManifestGenerator.create_manifest(settlement, settlement, items)
      rescue StandardError => e
        Rails.logger.error "Manifest generation failed: #{e.message}"
        raise ImportRequestError, "Manifest generation failed: #{e.message}"
      end

        import_req = Logistics::ImportRequest.create!(
        settlement_id: settlement.id,
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
