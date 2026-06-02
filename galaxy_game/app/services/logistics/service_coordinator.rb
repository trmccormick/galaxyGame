# frozen_string_literal: true

module Logistics
  class ServiceCoordinator < BaseService
    
    # Orchestration method matching spec exactly
    def self.detect_and_request_imports(settlement)
      # Step 1: Check Viability via ISRUCapabilityManager (internal to detector usually, but explicit here for clarity)
      unless ISRUCapabilityManager.has_basic_isru?(settlement)
        return { 
          viable: false, 
          requests_created: [], 
          reason: "Lacks basic ISRU capabilities" 
        }
      end
      
      # Step 2: Detect Shortages (Survival & Expansion)
      shortage_report = ShortageDetector.detect_shortages(settlement)
      
      # Step 3: Generate and Save Requests for Survival items only
      requests = ImportRequestGenerator.generate_import_requests(settlement, shortage_report)
      
      { 
        viable: true, 
        requests_created: requests.map(&:id).compact, 
        total_requests: requests.length,
        settlement_id: settlement.id,
        date: Time.now.to_date
      }
    end
  end
end
