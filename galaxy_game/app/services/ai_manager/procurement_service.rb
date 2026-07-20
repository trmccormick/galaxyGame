module AIManager
  class ProcurementService
    def self.procure_resource(settlement, resource, amount)
      Rails.logger.info "[ProcurementService] Procuring #{amount} #{resource} for settlement #{settlement.id}"

      # Check local production first (ISRU)
      if can_produce_locally?(settlement, resource, amount)
        produce_locally(settlement, resource, amount)
        return { status: :success, method: :local_production }
      end

      # Check market availability
      market_price = check_market_price(resource, amount)
      if market_price && settlement_can_afford?(settlement, market_price)
        purchase_from_market(settlement, resource, amount, market_price)
        return { status: :success, method: :market_purchase, cost: market_price }
      end

      # If normal procurement fails, this might trigger emergency mission
      Rails.logger.warn "[ProcurementService] Failed to procure #{resource} - may need emergency mission"
      { status: :failed, reason: :no_suppliers }
    end

    private

    def self.can_produce_locally?(settlement, resource, amount)
      # Check if settlement location can produce this resource via ISRU
      return false unless settlement
      
      resource_name = resource.is_a?(Symbol) ? resource.to_s : resource
      celestial_body = settlement.location&.celestial_body
      return false unless celestial_body
      
      # Delegate to PrecursorCapabilityService which queries celestial body data
      PrecursorCapabilityService.new(celestial_body).can_produce_locally?(resource_name)
    end

    def self.produce_locally(settlement, resource, amount)
      # Trigger local production
      Rails.logger.info "[ProcurementService] Starting local production of #{amount} #{resource}"
      # This would queue production jobs
    end

    def self.check_market_price(resource, amount)
      # Check wormhole market prices
      # Placeholder pricing logic
      base_prices = {
        oxygen: 500,
        water: 300,
        food: 800,
        structural_carbon: 2000
      }

      base_prices[resource]&.*(amount) if base_prices[resource]
    end

    def self.settlement_can_afford?(settlement, cost)
      settlement_funds = settlement_funds(settlement)
      
      # Check corporate debt level - NPCs with high debt are more conservative
      if settlement.owner&.is_a?(Organizations::BaseOrganization) && settlement.owner.is_npc?
        corporate_debt = corporate_debt_level(settlement.owner)
        total_assets = settlement.owner.accounts.sum { |account| [account.balance, 0].max }
        
        # If corporate debt exceeds 30% of assets, be more conservative with purchases
        if corporate_debt > total_assets * 0.3
          Rails.logger.info "[ProcurementService] High corporate debt detected (#{corporate_debt}), being conservative with purchases"
          return false
        end
      end
      
      settlement_funds >= cost
    end

    def self.purchase_from_market(settlement, resource, amount, cost)
      # Execute market purchase
      Rails.logger.info "[ProcurementService] Purchasing #{amount} #{resource} for #{cost} GCC"
      # This would interact with market/trading system
    end

    def self.settlement_funds(settlement)
      [settlement.gcc_account&.balance || 0, 0].max
    end

    def self.corporate_debt_level(corporation)
      # Calculate total debt across all corporation accounts
      corporation.accounts.sum do |account|
        account.balance.negative? ? account.balance.abs : 0
      end
    end
  end
end