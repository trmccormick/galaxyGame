# app/services/market/trade_execution_service.rb
module Market
  class TradeExecutionService
    
    # Executes the trade mechanics, including tax collection, fund transfer, 
    # inventory update, and record creation.
    # @param sell_order [Market::Order] The order being fulfilled (the seller's order)
    # @param trade_volume [Numeric] The quantity traded
    # @param trade_price [Numeric] The price per unit
    # @param settlement_organization [Settlement::BaseSettlement] The buyer/market settlement
    def self.execute!(sell_order, trade_volume, trade_price, settlement_organization)
      gross_revenue = trade_volume * trade_price
      seller_organization = sell_order.orderable
      currency = Financial::Currency.find_by!(symbol: 'GCC')

      # 1. Tax Collection
      tax_result = Financial::TaxCollectionService.collect_sales_tax(
        seller_organization, 
        gross_revenue, 
        currency
      )
      tax_amount = tax_result[:tax_paid] 
      net_revenue = gross_revenue - tax_amount


      # Integration: GuaranteedMarketSale for NPC buyers
      is_npc_buyer = settlement_organization.owner.is_a?(Organizations::BaseOrganization) && settlement_organization.owner&.is_npc? == true
      if is_npc_buyer
        # Route through top-level ::Marketplace::GuaranteedMarketSale for NPC buyers
        ::Marketplace::GuaranteedMarketSale.execute(
          player_settlement: seller_organization,
          resource: sell_order.resource,
          volume: trade_volume,
          bid_price: trade_price,
          ldc_settlement: settlement_organization
        )
      else
        # Player-to-player trades use normal transfer_net_funds
        transfer_net_funds(seller_organization, settlement_organization, net_revenue, currency)
      end

      # 3. Update Inventory
      seller_organization.remove_inventory(sell_order.resource, trade_volume)

      # 4. Create Records
      create_trade_record(sell_order, trade_volume, trade_price, settlement_organization)
      create_price_history(settlement_organization, trade_price, sell_order.resource)
      create_supply_chain_record(sell_order, trade_volume, settlement_organization)
      
      return true
    end

    private

    def self.transfer_net_funds(seller_organization, settlement_organization, net_amount, currency)
      # Ensure accounts exist for both parties using the financial helper
      settlement_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: settlement_organization, 
        currency: currency
      )
      
      seller_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: seller_organization, 
        currency: currency
      )

      # Transfer funds using virtual ledger when available (NPC overdraft)
      settlement_account.transfer_funds(net_amount, seller_account, "Net proceeds from market sale.")
    end

    def self.create_trade_record(sell_order, trade_volume, trade_price, settlement_organization)
      Market::Trade.create!(
        buyer: settlement_organization,
        seller: sell_order.orderable,
        resource: sell_order.resource,
        quantity: trade_volume,
        price: trade_price,
        buyer_settlement: settlement_organization,
        seller_settlement: settlement_organization
      )
    end

    def self.create_price_history(settlement_organization, trade_price, resource)
      # Use the correct market condition lookup for the resource
      market_condition = settlement_organization.marketplace.current_market_condition(resource)
      Market::PriceHistory.create!(
        market_condition_id: market_condition&.id,
        price: trade_price
      )
    end

    def self.create_supply_chain_record(sell_order, trade_volume, settlement_organization)
      Market::SupplyChain.create!(
        market_order_id: sell_order.id,
        sourceable_id: sell_order.orderable.id,
        sourceable_type: sell_order.orderable.class.name,
        destinationable_id: settlement_organization.id,
        destinationable_type: settlement_organization.class.name,
        resource_name: sell_order.resource,
        volume: trade_volume,
        status: 'Awaiting Launch'
      )
    end
  end
end