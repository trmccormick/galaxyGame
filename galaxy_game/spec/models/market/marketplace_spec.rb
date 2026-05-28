require 'rails_helper'

RSpec.describe Market::Marketplace, type: :model do
  # Stub Market::NpcPriceCalculator at the correct namespace so specs that
  # exercise find_matching_orders don't require the full calculator to be loaded.
  # Individual describe blocks that need specific return values override this via allow().
  before do
    allow(Market::NpcPriceCalculator).to receive(:calculate_bid).and_return(48.0)
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).and_return(48.0)
  end

  describe 'associations' do
    it { should belong_to(:settlement).class_name('Settlement::BaseSettlement') }
    it { should have_many(:market_conditions).class_name('Market::Condition').dependent(:destroy) }
  end

  describe 'table configuration' do
    it 'uses the correct table name' do
      expect(described_class.table_name).to eq('market_marketplaces')
    end
  end

  describe '#current_market_condition' do
    let(:settlement) { create(:base_settlement) }
    let(:marketplace) { described_class.create!(settlement: settlement) }
    
    let!(:lox_condition) do
      Market::Condition.create!(
        market_marketplace_id: marketplace.id,
        resource: 'LOX',
        price: 10.0,
        supply: 100,
        demand: 50
      )
    end

    it 'returns the market condition for a given resource' do
      expect(marketplace.current_market_condition('LOX')).to eq(lox_condition)
    end

    it 'creates and returns a new condition for a resource that does not exist' do
      # current_market_condition uses find_or_create_by! -- it never returns nil.
      # A missing resource gets a new Market::Condition record on first access.
      expect {
        marketplace.current_market_condition('UNKNOWN')
      }.to change(Market::Condition, :count).by(1)

      result = marketplace.current_market_condition('UNKNOWN')
      expect(result).to be_a(Market::Condition)
      expect(result.resource).to eq('UNKNOWN')
    end
  end

  describe '#find_matching_orders' do
    let(:settlement) { create(:base_settlement) }
    let(:marketplace) { described_class.create!(settlement: settlement) }
    let(:player) { create(:player) }
    
    let(:market_condition) do
      Market::Condition.create!(
        market_marketplace_id: marketplace.id,
        resource: 'LOX',
        price: 10.0,
        supply: 100,
        demand: 50
      )
    end

    let(:sell_order) do
      Market::Order.create!(
        market_condition: market_condition,
        orderable: player,
        base_settlement_id: settlement.id,
        resource: 'LOX',
        quantity: 100,
        order_type: 'sell'
      )
    end

    context 'when order is a sell order' do
      before do
        # find_matching_orders delegates price lookup to Market::NpcPriceCalculator.calculate_bid.
        # The top-level before block stubs this to 48.0; override here for explicit clarity.
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid)
          .with(settlement, 'LOX', demand: 100)
          .and_return(48.0)
      end

      it 'returns a single synthetic NPC buy order' do
        result = marketplace.find_matching_orders(sell_order)
        expect(result.length).to eq(1)
      end

      it 'returns an OpenStruct with order_type Buy' do
        result = marketplace.find_matching_orders(sell_order)
        expect(result.first.order_type).to eq('Buy')
      end

      it 'returns the NPC bid price on the synthetic order' do
        result = marketplace.find_matching_orders(sell_order)
        expect(result.first.price).to eq(48.0)
      end

      it 'returns the correct resource on the synthetic order' do
        result = marketplace.find_matching_orders(sell_order)
        expect(result.first.resource).to eq('LOX')
      end

      it 'sets the synthetic order id to -1' do
        result = marketplace.find_matching_orders(sell_order)
        expect(result.first.id).to eq(-1)
      end

      it 'caps trade volume at the NPC capacity ceiling of 1000' do
        large_order = Market::Order.create!(
          market_condition: market_condition,
          orderable: player,
          base_settlement_id: settlement.id,
          resource: 'LOX',
          quantity: 5000,
          order_type: 'sell'
        )
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid)
          .with(settlement, 'LOX', demand: 5000)
          .and_return(48.0)

        result = marketplace.find_matching_orders(large_order)
        expect(result.first.quantity).to eq(1000)
      end

      it 'returns empty array when NpcPriceCalculator returns zero' do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid)
          .with(settlement, 'LOX', demand: 100)
          .and_return(0)

        expect(marketplace.find_matching_orders(sell_order)).to be_empty
      end

      it 'returns empty array when NpcPriceCalculator returns nil' do
        allow(Market::NpcPriceCalculator).to receive(:calculate_bid)
          .with(settlement, 'LOX', demand: 100)
          .and_return(nil)

        expect(marketplace.find_matching_orders(sell_order)).to be_empty
      end

      # Regression guard against reintroducing the original string comparison bug
      it 'matches via sell? predicate, not string equality against order_type' do
        # If the guard were `order_type == 'Sell'` this would return []
        # because the enum stores integers and returns lowercase strings.
        result = marketplace.find_matching_orders(sell_order)
        expect(result).not_to be_empty,
          'find_matching_orders returned [] for a sell order -- ensure the guard uses sell? not string equality'
      end
    end

    context 'when order is not a Sell order' do
      let(:buy_order) do
        Market::Order.create!(
          market_condition: market_condition,
          orderable: player,
          base_settlement_id: settlement.id,
          resource: 'LOX',
          quantity: 100,
          order_type: 'buy'
        )
      end

      it 'returns an empty array' do
        expect(marketplace.find_matching_orders(buy_order)).to be_empty
      end
    end
  end

  describe '#place_order' do
    let(:settlement) { create(:base_settlement) }
    let(:marketplace) { described_class.create!(settlement: settlement) }
    let(:player) { create(:player) }
    
    let!(:market_condition) do
      Market::Condition.create!(
        market_marketplace_id: marketplace.id,
        resource: 'LOX',
        price: 10.0,
        supply: 100,
        demand: 50
      )
    end

    before do
      unless Player.method_defined?(:remove_inventory)
        Player.class_eval { def remove_inventory(resource, volume); true; end }
      end

      unless Settlement::BaseSettlement.method_defined?(:market_condition)
        Settlement::BaseSettlement.class_eval { def market_condition; end }
      end

      allow(settlement).to receive(:npc_market_bid).and_return(48.0)
      allow(settlement).to receive(:npc_buy_capacity).and_return(500)
      allow(settlement).to receive(:market_condition).and_return(market_condition)
      allow(player).to receive(:remove_inventory).and_return(true)
      allow_any_instance_of(Logistics::ShippingCalculator).to receive(:calculate_shipping).and_return(
        { shipping_cost: 200.00, total_cost: 0, base_cost: 0 }
      )
    end

    it 'creates an order' do
      expect {
        marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell'
        )
      }.to change(Market::Order, :count).by(1)
    end

    it 'converts volume parameter to quantity' do
      # Prevent order matching for this test
      allow(marketplace).to receive(:find_matching_orders).and_return([])
      
      marketplace.place_order(
        orderable: player,
        resource: 'LOX',
        volume: 100,
        order_type: 'sell'
      )
      
      order = Market::Order.last
      expect(order.quantity).to eq(100)
    end

    it 'sets the base_settlement_id' do
      marketplace.place_order(
        orderable: player,
        resource: 'LOX',
        volume: 100,
        order_type: 'sell'
      )
      
      order = Market::Order.last
      expect(order.base_settlement_id).to eq(settlement.id)
    end

    it 'removes unused parameters' do
      expect {
        marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell',
          order_type_detail: 'Market',
          price: 50.0
        )
      }.not_to raise_error
    end

    context 'when order is fully filled' do
      it 'returns nil' do
        # Stub to ensure matching orders are found so trade executes
        allow(marketplace).to receive(:find_matching_orders).and_return([
          OpenStruct.new(
            id: -1,
            orderable: settlement,
            resource: 'LOX',
            order_type: 'buy',
            quantity: 100,
            price: 48.0,
            market_condition: market_condition
          )
        ])
        
        result = marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell'
        )
        
        expect(result).to be_nil
      end

      it 'sets order quantity to zero' do
        # Stub to ensure matching orders are found so trade executes
        allow(marketplace).to receive(:find_matching_orders).and_return([
          OpenStruct.new(
            id: -1,
            orderable: settlement,
            resource: 'LOX',
            order_type: 'buy',
            quantity: 100,
            price: 48.0,
            market_condition: market_condition
          )
        ])
        
        marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell'
        )
        
        order = Market::Order.last
        expect(order.quantity).to eq(0)
      end
    end

    context 'when order is partially filled' do
      before do
        # Stub to return partial match
        allow(marketplace).to receive(:find_matching_orders).and_return([
          OpenStruct.new(
            id: -1,
            orderable: settlement,
            resource: 'LOX',
            order_type: 'buy',
            quantity: 50,
            price: 48.0,
            market_condition: market_condition
          )
        ])
      end

      it 'returns the order' do
        result = marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell'
        )
        
        expect(result).to be_a(Market::Order)
        expect(result.quantity).to eq(50)
      end
    end

    context 'when no matching orders exist' do
      before do
        allow(marketplace).to receive(:find_matching_orders).and_return([])
      end

      it 'returns the unfilled order' do
        result = marketplace.place_order(
          orderable: player,
          resource: 'LOX',
          volume: 100,
          order_type: 'sell'
        )
        
        expect(result).to be_a(Market::Order)
        expect(result.quantity).to eq(100)
      end
    end
  end

  describe '#execute_trades' do
    let(:settlement) { create(:base_settlement) }
    let(:marketplace) { described_class.create!(settlement: settlement) }
      
      # Use a real model (like Corporation) that can respond to tax_rate and has an account.
      let(:seller_organization) { Organizations::Corporation.create!(
        name: 'Seller Corp', 
        identifier: 'SC-01',
        operational_data: { 'tax_rate' => 0.10 }
      ) }
      
      let(:market_condition) do
        Market::Condition.create!(
          market_marketplace_id: marketplace.id,
          resource: 'LOX',
          price: 10.0,
          supply: 100,
          demand: 50
        )
      end

      let(:sell_order) do
        Market::Order.create!(
          market_condition: market_condition,
          orderable: seller_organization,
          base_settlement_id: settlement.id,
          resource: 'LOX',
          quantity: 100,
          order_type: 'sell'
        )
      end

      let(:trade_volume) { 100 }
      let(:unit_price) { 48.0 }
      
      let(:matching_orders) do
        [
          OpenStruct.new(
            id: -1,
            orderable: settlement,
            resource: 'LOX',
            order_type: 'buy',
            quantity: trade_volume,
            price: unit_price,
            market_condition: market_condition
          )
        ]
      end

      # Mocks for core dependencies
      before do
        # Mock the service to verify orchestration
        allow(Market::TradeExecutionService).to receive(:execute!).and_return(true)
        
        # Ensure necessary methods are stubbed/defined for order finalization
        unless Organizations::Corporation.method_defined?(:remove_inventory)
          Organizations::Corporation.class_eval { def remove_inventory(resource, volume); true; end }
        end
        unless Settlement::BaseSettlement.method_defined?(:market_condition)
          Settlement::BaseSettlement.class_eval { def market_condition; end }
        end
        allow(settlement).to receive(:market_condition).and_return(market_condition)
        # We no longer need to mock FinancialManager or TaxCollectionService here!
      end

      it 'delegates the entire trade execution to Market::TradeExecutionService' do
        marketplace.execute_trades(sell_order, matching_orders)
        
        expect(Market::TradeExecutionService).to have_received(:execute!).with(
          sell_order,           # The sell order
          trade_volume,         # The quantity (100)
          unit_price,           # The price (48.0)
          settlement            # The buyer organization
        )
      end
      
      # Only two functional checks remain in Marketplace: order finalization and error handling
      
      it 'updates the order quantity to zero when fully filled' do
        marketplace.execute_trades(sell_order, matching_orders)
        
        sell_order.reload
        expect(sell_order.quantity).to eq(0)
        
        # Note: This checks the final action, finalize_order, which remains here.
      end

      context 'when partially filled' do
        let(:partial_matching_orders) do
          [
            OpenStruct.new(
              id: -1,
              orderable: settlement,
              resource: 'LOX',
              order_type: 'buy',
              quantity: 50,
              price: 48.0,
              market_condition: market_condition
            )
          ]
        end

        it 'updates the order quantity to remaining amount' do
          marketplace.execute_trades(sell_order, partial_matching_orders)
          
          sell_order.reload
          expect(sell_order.quantity).to eq(50)
        end
      end

      it 'wraps the execution in a transaction' do
        # A simple check to ensure the transaction block is called
        expect(ActiveRecord::Base).to receive(:transaction).and_call_original
        marketplace.execute_trades(sell_order, matching_orders)
      end
    end
  end
