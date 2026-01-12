module AIManager
  class ResourceFulfillmentService # Renamed for clarity
    # Main entry point for fulfilling a supply need
    def self.fulfill_supply_need(settlement, material, amount)
      # 1. Check if already fulfilled
      if settlement.inventory.current_storage_of(material) >= amount
        Rails.logger.info "[Fulfillment] Already have enough #{material} at #{settlement.name}"
        return :fulfilled
      end

      # 2. Use MaterialRequestService for market-first procurement
      result = MaterialRequestService.request_materials(
        settlement,
        { material => amount },
        { requester: settlement, purpose: 'ai_procurement' }
      )[material]

      case result[:status]
      when :fulfilled
        :fulfilled
      when :market_order_pending
        :market_order_pending
      when :ai_contract_created
        :contract_created
      when :ai_import_ordered
        :import_ordered
      when :insufficient_funds
        :insufficient_funds
      else
        :failed_to_fulfill
      end
    end
  end
end