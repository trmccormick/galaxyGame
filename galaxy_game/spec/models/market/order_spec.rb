require 'rails_helper'

RSpec.describe Market::Order, type: :model do
  let(:player) { create(:player) }
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) { create(:celestial_location, name: "Test Location", coordinates: "0.00°N 0.00°E", celestial_body: celestial_body) }
  let(:settlement) { create(:base_settlement, :independent, name: "Test Settlement", settlement_type: :base, current_population: 1, owner: player, location: location) }
  let(:marketplace) { Market::Marketplace.create!(settlement: settlement) }
  let(:market_condition) { create(:market_condition) }

  let(:order) do
    described_class.create!(
      market_condition: market_condition,
      orderable: player,
      order_type: 'buy',
      quantity: 10
    )
  end
  let(:craft) { create(:heavy_lander, owner: player) }

  it 'is valid with valid attributes' do
    order = Market::Order.new(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      quantity: 10,
      order_type: 'buy',
      base_settlement_id: settlement.id
    )
    expect(order).to be_valid
  end

  it 'requires a market_condition' do
    order = Market::Order.new(orderable: player, quantity: 10, order_type: 'buy', base_settlement_id: settlement.id)
    expect(order).not_to be_valid
    expect(order.errors[:market_condition]).to be_present
  end

  it 'requires an orderable' do
    order = Market::Order.new(market_condition: market_condition, quantity: 10, order_type: 'buy', base_settlement_id: settlement.id)
    expect(order).not_to be_valid
    expect(order.errors[:orderable]).to be_present
  end

  it 'belongs to market_condition' do
    order = Market::Order.create!(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      quantity: 5,
      order_type: 'sell',
      base_settlement_id: settlement.id
    )
    expect(order.market_condition).to eq(market_condition)
  end

  it 'supports polymorphic orderable association' do
    order = Market::Order.create!(
      market_condition: market_condition,
      orderable: settlement,
      orderable_type: 'Settlement::BaseSettlement',
      quantity: 20,
      order_type: 'buy',
      base_settlement_id: settlement.id
    )
    expect(order.orderable).to eq(settlement)
  end

  it 'is invalid without quantity' do
    order = Market::Order.new(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      order_type: 'buy',
      base_settlement_id: settlement.id
    )
    expect(order).not_to be_valid
    expect(order.errors[:quantity]).to be_present
  end

  it 'is invalid without order_type' do
    order = Market::Order.new(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      quantity: 10,      
      base_settlement_id: settlement.id
    )
    expect(order).not_to be_valid
    expect(order.errors[:order_type]).to be_present
  end

  it 'can be associated with a base_settlement_id' do
    order = Market::Order.create!(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      quantity: 5,
      order_type: 'sell',
      base_settlement_id: settlement.id
    )
    expect(order.base_settlement_id).to eq(settlement.id)
  end
end