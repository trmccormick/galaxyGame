module AIManager
  class ResourceAcquisitionService
    # This method serves as the low-level execution layer for acquiring resources
    # that are not available internally. It decides the source (local vs. external)
    # and handles the financial gatekeeping.
    def self.order_acquisition(settlement, material, amount)
      # 1. Determine Acquisition Type (Local GCC vs. External USD)
      if is_local_resource?(material)
        # Resources that can be mined, grown, or produced on the moon/in space.
        process_local_acquisition(settlement, material, amount)
      else
        # Resources that must be imported from Earth (USD debt check applies).
        process_external_import(settlement, material, amount)
      end
    end
    
    # Check for expired buy orders and trigger escalation
    def self.check_expired_orders
      expired_orders = Market::Order.where(order_type: :buy)
                                    .where('created_at < ?', 24.hours.ago)
                                    .where(status: :active)

      EscalationService.handle_expired_buy_orders(expired_orders) if expired_orders.any?
    end
    
    # Utility method for the ResourcePlanner to decide the acquisition type.
    # Returns :local_trade or :external_import
    def self.acquisition_method_for(material)
      is_local_resource?(material) ? :local_trade : :external_import
    end

    # Determine if a material can be sourced locally (mined/harvested) vs. imported from Earth
    def self.is_local_resource?(material)
      local_resources = [
        'Lunar Regolith', 'Iron', 'Aluminum', 'Silicon', 'Iron Ore', 'Aluminum Ore',
        'Silicon Ore', 'Copper', 'Titanium', 'Water', 'Oxygen', 'Carbon Dioxide',
        'Methane', 'Ammonia', 'Hydrogen', 'Helium', 'Argon', 'Neon', 'Krypton', 'Xenon'
      ]
      
      local_resources.any? { |r| r.casecmp?(material) }
    end

    private

    # --- LOCAL ACQUISITION (GCC Contracts for Players) ---

    def self.process_local_acquisition(settlement, material, amount)
      # CHECK EAP CEILING AGAINST PLAYER SELL ORDERS
      # If any player sell orders exceed EAP, NPC chooses Earth import instead
      if player_sell_orders_exceed_eap?(settlement, material)
        Rails.logger.info "[Acquisition] Player sell orders for #{material} exceed EAP ceiling. Choosing Earth import instead."
        return process_external_import(settlement, material, amount)
      end

      # 1. Calculate GCC Price (based on LDC Anchor Price, current market, and transport)
      final_price_per_unit = calculate_gcc_contract_price(settlement, material)
      total_cost = final_price_per_unit * amount
      
      # 2. Financial Check (Uses the primary GCC account)
      unless settlement.can_afford?(total_cost)
        Rails.logger.warn "[Acquisition] Cannot afford GCC contract for #{material}. Cost: #{total_cost.round(2)} GCC."
        # This triggers a potential ProductionManager reassessment.
        return :insufficient_funds_gcc 
      end

      # 3. Create Contract (The player mission/contract)
      ContractCreationService.create_player_contract(
        settlement, 
        material: material, 
        amount: amount, 
        payout_gcc: total_cost
      )
      
      Rails.logger.info "[Acquisition] Created GCC contract for #{amount} #{material}. Price: #{total_cost.round(2)} GCC."
      :contract_created_gcc
    end

    def self.calculate_gcc_contract_price(settlement, material)
      # Use NPC calculator to get market price
      Market::NpcPriceCalculator.calculate_ask(settlement, material)
    end

    def self.get_anchor_price(material, currency = 'USD')
      lookup_service = Lookup::MaterialLookupService.new
      material_data = lookup_service.find_material(material)
      
      return nil unless material_data
      
      pricing = material_data.dig('pricing', 'earth_usd')
      return nil unless pricing
      
      pricing['base_price_per_kg']
    end


    # --- EXTERNAL ACQUISITION (USD Imports from Earth) ---

    def self.process_external_import(settlement, material, amount, delivery_method = nil)
      # Nitrogen Lock: Mars cannot import Nitrogen from Earth
      if material == 'Nitrogen' && settlement.celestial_body&.identifier == 'MARS-01'
        Rails.logger.warn "[Acquisition] BLOCKED: Mars cannot import Nitrogen from Earth. Must use AstroLift pipeline."
        return :nitrogen_import_blocked_for_mars
      end

      # 1. Calculate USD Cost
      usd_cost_per_unit = get_anchor_price(material, 'USD')
      total_cost_usd = usd_cost_per_unit * amount

      # Tax Shield: Waive $1,000 USD fee if delivered by AstroLift Heavy Lift Transport
      import_fee = delivery_method == :astrolift_heavy_lift ? 0 : 1000
      total_cost_usd += import_fee

      # 2. Financial Gate Check (Uses the HasExternalFinanceManagement logic)
      unless settlement.financials.can_afford_fiat_import?(total_cost_usd, 'USD')
        # This is the gate that enforces the $4.05B debt rule
        Rails.logger.warn "[Acquisition] BLOCKED by Fiat Gatekeeper. Debt too high for import of #{material}. Cost: #{total_cost_usd.round(2)} USD."
        return :import_blocked_by_debt
      end

      # 3. Create Contract (The Earth import order)
      ContractCreationService.create_import_order(
        settlement, 
        material: material, 
        amount: amount, 
        cost_usd: total_cost_usd
      )

      # 4. Record Debt/Expense
      usd_currency = Currency.find_by(symbol: 'USD')
      usd_account = Account.find_by(accountable: settlement, currency: usd_currency)
      usd_account.withdraw(total_cost_usd, "External Import: #{amount} #{material}#{delivery_method == :astrolift_heavy_lift ? ' (AstroLift Heavy Lift)' : ''}")

      Rails.logger.info "[Acquisition] Ordered external import for #{amount} #{material}. Cost: #{total_cost_usd.round(2)} USD#{delivery_method == :astrolift_heavy_lift ? ' (Fee waived - AstroLift delivery)' : ''}."
      :import_ordered_usd
    end

    # --- UTILITY ---
    
    def self.player_sell_orders_exceed_eap?(settlement, material)
      eap_ceiling = Market::NpcPriceCalculator.send(:calculate_eap_ceiling, settlement, material)
      return false unless eap_ceiling

      # Check if any active player sell orders exceed EAP
      # This would need to be implemented based on your market order system
      # For now, return false - this logic would check Market::Order.where(resource: material, order_type: :sell, price: > eap_ceiling)
      false # Placeholder - implement based on your market order model
    end
  end
end