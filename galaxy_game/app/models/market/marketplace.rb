# app/models/market/marketplace.rb
module Market
  class Marketplace < ApplicationRecord
    self.table_name = 'market_marketplaces'
    
    belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
    has_many :market_conditions, 
             class_name: 'Market::Condition',
             foreign_key: 'market_marketplace_id',
             dependent: :destroy
    has_many :prices, through: :market_conditions
    has_many :orders, through: :market_conditions, source: :orders

    # Price lookup used by controller and specs
    def self.get_price(item, seller:, demand: 1)
      # Use NPCPriceCalculator for real market/EAP price logic
      settlement = if seller.respond_to?(:settlement)
        seller.settlement
      elsif seller.respond_to?(:base_settlement)
        seller.base_settlement
      else
        seller
      end

      resource_name = item.respond_to?(:name) ? item.name : item.to_s
      price = NPCPriceCalculator.calculate_ask(settlement, resource_name, demand: demand)
      price || 0.0
    end

    # Places an order in the marketplace and executes matching trades
    # @param params [Hash] Order parameters including orderable, resource, volume, order_type
    # @return [Market::Order, nil] Returns the order if unfilled/partially filled, nil if fully filled
    def place_order(params)
      order_params = prepare_order_params(params)
      
      begin
        transaction do
          order = create_order(order_params)
          match_orders(order)
          finalize_order_return(order)
        end
      rescue StandardError => e
        Rails.logger.error("Error in place_order: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        raise
      end
    end

    # Executes trades between a sell order and matching buy orders
    # Now delegated to Market::TradeExecutionService
    def execute_trades(sell_order, matching_orders)
      npc_buy_order = matching_orders.first
      trade_volume = [sell_order.quantity, npc_buy_order.quantity].min
      trade_price = npc_buy_order.price 

      begin
        transaction do
          # --- DELEGATE ALL EXECUTION TO THE SERVICE ---
          Market::TradeExecutionService.execute!(
            sell_order, 
            trade_volume, 
            trade_price, 
            settlement # Pass the buyer organization (the settlement)
          )
          
          # --- FINAL ORCHESTRATION ---
          finalize_order(sell_order, trade_volume)
        end
      rescue StandardError => e
        Rails.logger.error("Error in execute_trades: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        raise
      end
    end

    # Finds matching orders for a given order
    # @param new_order [Market::Order] The order to find matches for
    # @return [Array<OpenStruct>] Array of matching orders (can be synthetic NPC orders)
    def find_matching_orders(new_order)
      return [] unless new_order.order_type == 'Sell'

      npc_price = settlement.npc_market_bid(new_order.resource)
      npc_capacity = settlement.npc_buy_capacity(new_order.resource)
      trade_volume = [new_order.quantity, npc_capacity].min

      return [] unless trade_volume > 0 && npc_price > 0

      [create_synthetic_npc_order(new_order, trade_volume, npc_price)]
    end

    # Gets the current market condition for a specific resource
    # @param resource [String] The resource name
    # @return [Market::Condition, nil] The market condition or nil if not found
    def current_market_condition(resource)
      market_conditions.find_by(resource: resource)
    end

    private

    def prepare_order_params(params)
      order_params = params.dup
      resource = order_params[:resource]
      condition = current_market_condition(resource)
      
      order_params[:market_condition] = condition
      order_params[:quantity] = order_params.delete(:volume) if order_params.key?(:volume)
      order_params[:base_settlement_id] = settlement_id
      order_params.delete(:order_type_detail)
      order_params.delete(:price)
      
      order_params
    end

    def create_order(order_params)
      condition = order_params[:market_condition]
      condition.market_orders.create!(order_params)
    end

    def finalize_order_return(order)
      order.reload
      order.quantity == 0 ? nil : order
    end

    def match_orders(new_order)
      matching_orders = find_matching_orders(new_order)
      execute_trades(new_order, matching_orders) if matching_orders.any?
    end

    def finalize_order(sell_order, trade_volume)
      remaining_quantity = sell_order.quantity - trade_volume

      if remaining_quantity > 0
        sell_order.update!(quantity: remaining_quantity)
      else
        sell_order.update!(quantity: 0)
      end
    rescue StandardError => e
      raise "Order Finalization Failed: #{e.message}"
    end

    def create_synthetic_npc_order(new_order, trade_volume, npc_price)
      OpenStruct.new(
        id: -1,
        orderable: settlement,
        resource: new_order.resource,
        order_type: 'Buy',
        quantity: trade_volume,
        price: npc_price,
        market_condition: new_order.market_condition
      )
    end

    def load_prices_from_db
      prices = {}
      Market::Condition.all.each do |condition|
        prices[condition.resource] = condition.price
      end
      prices
    end
  end
end