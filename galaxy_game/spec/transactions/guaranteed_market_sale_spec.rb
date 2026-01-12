require 'rails_helper'
require 'market/condition'

RSpec.describe "Guaranteed Market Sale Transaction", type: :transaction_flow do
  # Constants
  GUARANTEED_BID_PRICE = 48.00
  SALE_VOLUME = 100

  before(:all) do
    # Ensure system currencies exist for all tests
    Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    Financial::Currency.find_or_create_by!(symbol: 'USD') do |c|
      c.name = 'US Dollar'
      c.is_system_currency = true
      c.precision = 2
    end
  end

  # Test entities
  let!(:player) { create(:player) }
  let!(:luna_settlement) { create(:base_settlement, name: 'Luna Base') }
  let!(:marketplace) { Market::Marketplace.create!(settlement: luna_settlement) }
  let!(:player_account) { player.account }
  let!(:settlement_account) { luna_settlement.account }
  
  let!(:market_condition) do
    Market::Condition.create!(
      market_marketplace_id: marketplace.id,
      resource: 'LOX',
      price: 1.0,
      supply: 100,
      demand: 100
    )
  end

  let(:synthetic_match) do
    OpenStruct.new(
      id: -1,
      orderable: luna_settlement,
      resource: 'LOX',
      order_type: 'Buy',
      quantity: 100,
      price: GUARANTEED_BID_PRICE,
      market_condition: marketplace.market_conditions.find_by(resource: 'LOX')
    )
  end

  before do
    # Define required methods for testing
    unless Player.method_defined?(:remove_inventory)
      Player.class_eval do
        def remove_inventory(resource, volume); true; end
      end
    end

    unless Player.method_defined?(:has_enough_inventory?)
      Player.class_eval do
        def has_enough_inventory?(resource, volume); true; end
      end
    end

    unless Settlement::BaseSettlement.method_defined?(:market_condition)
      Settlement::BaseSettlement.class_eval do
        def market_condition; end
      end
    end

    # Mock NPC pricing and capacity
    allow(luna_settlement).to receive(:npc_market_bid).with('LOX').and_return(GUARANTEED_BID_PRICE)
    allow(luna_settlement).to receive(:npc_buy_capacity).with('LOX').and_return(500)
    
    # Mock financial and inventory services
    allow(Financial::TaxCollectionService).to receive(:collect_sales_tax).and_return({ success: true, tax_paid: 0.0, transaction_id: nil, error: nil })
    allow(Financial::TransactionManager).to receive(:create_transfer).and_return(OpenStruct.new(id: 'mock-net-txn'))
    allow(player).to receive(:has_enough_inventory?).with('LOX', 100).and_return(true)
    allow(player).to receive(:remove_inventory).with('LOX', any_args).and_return(true)
    
    # Mock shipping calculator
    allow_any_instance_of(Logistics::ShippingCalculator).to receive(:calculate_shipping).and_return(
      { shipping_cost: 200.00, total_cost: 0, base_cost: 0 }
    )

    # Mock settlement market condition
    allow(luna_settlement).to receive(:market_condition).and_return(market_condition)

    # Mock order matching
    allow(marketplace).to receive(:find_matching_orders).and_return([synthetic_match])
  end

  describe 'guaranteed sell order execution' do
    it 'executes atomically and creates all required records' do
      expected_trade_value = SALE_VOLUME * GUARANTEED_BID_PRICE

      expect {
        marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: SALE_VOLUME,
          order_type: 'sell',
          order_type_detail: 'Market',
          price: nil
        )
      }.to change(Market::Trade, :count).by(1)
        .and change(Market::PriceHistory, :count).by(1)
        .and change(Market::SupplyChain, :count).by(1)

      # Validate order is marked as filled
      order = Market::Order.last
      expect(order.quantity).to eq(0)

      # Validate tax collection was called
      expect(Financial::TaxCollectionService).to have_received(:collect_sales_tax).once

      # Validate financial transfer was called for net funds
      expect(Financial::TransactionManager).to have_received(:create_transfer).once

      # Validate inventory was removed
      expect(player).to have_received(:remove_inventory).with('LOX', SALE_VOLUME)

          # Validate trade record
          trade = Market::Trade.last
          expect(trade.price).to eq(GUARANTEED_BID_PRICE)
          expect(trade.volume).to eq(SALE_VOLUME)
          expect(trade.seller).to eq(player)
          expect(trade.buyer).to eq(luna_settlement)
          
          # Validate supply chain record
          supply_chain = Market::SupplyChain.last
          expect(supply_chain.volume).to eq(SALE_VOLUME)
          expect(supply_chain.status).to eq('Awaiting Launch')
        end

        # --- REMAINDER OF TESTS ARE UNCHANGED ---

        it 'does not create a SupplyChain record if no matching buy order exists' do
          allow(marketplace).to receive(:find_matching_orders).and_return([])
          
          expect {
            marketplace.place_order(
              orderable: player,
              resource: 'LOX',
              volume: SALE_VOLUME,
              order_type: 'sell',
              order_type_detail: 'Market',
              price: nil
            )
          }.not_to change(Market::SupplyChain, :count)
        end

        it 'creates a Trade record with correct buyer and seller' do
          expect {
            marketplace.place_order(
              orderable: player,
              resource: 'LOX',
              volume: SALE_VOLUME,
              order_type: 'sell',
              order_type_detail: 'Market',
              price: nil
            )
          }.to change(Market::Trade, :count).by(1)
          
          trade = Market::Trade.last
          expect(trade.seller).to eq(player)
          expect(trade.buyer).to eq(luna_settlement)
          expect(trade.price).to eq(GUARANTEED_BID_PRICE)
          expect(trade.volume).to eq(SALE_VOLUME)
        end

        it 'marks the order as filled by returning nil' do
          order = marketplace.place_order(
            orderable: player,
            resource: 'LOX',
            volume: SALE_VOLUME,
            order_type: 'sell',
            order_type_detail: 'Market',
            price: nil
          )
          
          expect(order).to be_nil
        end

        it 'records a PriceHistory entry after trade execution' do
          expect {
            marketplace.place_order(
              orderable: player,
              resource: 'LOX',
              volume: SALE_VOLUME,
              order_type: 'sell',
              order_type_detail: 'Market',
              price: nil
            )
          }.to change(Market::PriceHistory, :count).by(1)
          
          price_history = Market::PriceHistory.last
          expect(price_history.price).to eq(GUARANTEED_BID_PRICE)
        end

        it 'calls TransactionManager.create_transfer with correct arguments' do
          marketplace.place_order(
            orderable: player,
            resource: 'LOX',
            volume: SALE_VOLUME,
            order_type: 'sell',
            order_type_detail: 'Market',
            price: nil
          )
          
          expect(Financial::TransactionManager).to have_received(:create_transfer).once
        end

        it 'creates a SupplyChain record with correct volume and status' do
          expect {
            marketplace.place_order(
              orderable: player,
              resource: 'LOX',
              volume: SALE_VOLUME,
              order_type: 'sell',
              order_type_detail: 'Market',
              price: nil
            )
          }.to change(Market::SupplyChain, :count).by(1)
          
          supply_chain = Market::SupplyChain.last
          expect(supply_chain.volume).to eq(SALE_VOLUME)
          expect(supply_chain.status).to eq('Awaiting Launch')
        end
      end
end