# spec/services/trade_service_spec.rb

require 'rails_helper'

RSpec.describe TradeService do
  let(:colony) { create(:colony, name: 'Colony A') }
  let(:buyer_colony) { create(:colony, name: 'Colony B') }
  let(:inventory) { create(:inventory, name: 'Iron', quantity: 500, material_type: 'raw_material', colony: colony) }

  describe '#dynamic_price' do
    it 'calculates the dynamic price based on scarcity, transportation, and market conditions' do
      trade_service = TradeService.new(inventory, buyer_colony)

      allow(trade_service).to receive(:market_conditions).and_return(0)
      allow(trade_service).to receive(:distance_to_buyer).and_return(100)
      allow(trade_service).to receive(:fuel_cost_per_unit).and_return(0.1)

      # Scarcity factor: (1000 / (quantity + 1)) => (1000 / 501) = ~1.996
      # Base price: 5.0 for raw material
      # Fuel cost: distance_to_buyer * fuel_cost_per_unit = 100 * 0.1 = 10
      expected_price = (5.0 * 1.996) + 10 + 0
      expect(trade_service.dynamic_price).to be_within(0.01).of(expected_price)
    end
  end

  describe '#base_price_for_type' do
    it 'returns the correct base price for raw materials' do
      trade_service = TradeService.new(inventory, buyer_colony)
      expect(trade_service.base_price_for_type).to eq(5.0)
    end

    it 'returns the correct base price for processed goods' do
      inventory.material_type = 'processed_good'
      trade_service = TradeService.new(inventory, buyer_colony)
      expect(trade_service.base_price_for_type).to eq(20.0)
    end
  end

  describe '#fuel_cost_per_unit' do
    it 'returns the correct fuel cost per unit' do
      trade_service = TradeService.new(inventory, buyer_colony)
      expect(trade_service.fuel_cost_per_unit).to eq(0.1)
    end
  end

  describe '#distance_to_buyer' do
    it 'calculates the distance between colonies' do
      planet_a = create(:planet, distance_from: 10000)
      planet_b = create(:planet, distance_from: 5000)
      colony.update(planet: planet_a)
      buyer_colony.update(planet: planet_b)

      trade_service = TradeService.new(inventory, buyer_colony)
      expect(trade_service.distance_to_buyer).to eq(5.0) # (10000 - 5000) / 1000
    end
  end

  describe '#market_conditions' do
    it 'returns a random market condition modifier' do
      trade_service = TradeService.new(inventory, buyer_colony)
      expect(trade_service.market_conditions).to be_between(-5.0, 5.0)
    end
  end
end
