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

      # 2. Net Funds Transfer (from Settlement to Seller)
      transfer_net_funds(seller_organization, settlement_organization, net_revenue, currency)

      # 3. Update Inventory
      seller_organization.remove_inventory(sell_order.resource, trade_volume)

      # 4. Create Records
      create_trade_record(sell_order, trade_volume, trade_price, settlement_organization)
      create_price_history(settlement_organization, trade_price)
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

      Financial::TransactionManager.create_transfer(
        from: settlement_account,
        to: seller_account,
        amount: net_amount,
        currency: currency,
        description: "Net proceeds from market sale."
      )
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

    def self.create_price_history(settlement_organization, trade_price)
      # This logic assumes the settlement has a method/association called market_condition
      Market::PriceHistory.create!(
        market_condition_id: settlement_organization.market_condition.id,
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