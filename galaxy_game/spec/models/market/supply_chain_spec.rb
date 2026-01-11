require 'rails_helper'

RSpec.describe Market::SupplyChain, type: :model do
  let(:player) { create(:player) }
  let(:settlement_a) { create(:base_settlement, name: "Alpha Base", owner: player) }
  let(:settlement_b) { create(:base_settlement, name: "Beta Base", owner: player) }
  let(:marketplace) { create(:marketplace) }
  let(:market_condition) { create(:market_condition, marketplace: marketplace, resource: 'Battery Pack') }
  let(:market_order) do
    Market::Order.create!(
      market_condition: market_condition,
      orderable: player,
      orderable_type: 'Player',
      quantity: 10,
      order_type: 'buy',
      base_settlement_id: settlement_a.id
    )
  end
  let(:sourceable) { create(:market_condition, marketplace: marketplace) }
  let(:destinationable) { create(:market_condition, marketplace: marketplace) }

  it 'is valid with valid attributes' do
    supply_chain = Market::SupplyChain.new(
      market_order: market_order,
      resource_name: 'LOX',
      volume: 100.0,
      status: 'pending'
    )
    expect(supply_chain).to be_valid
  end

  it 'requires a market_order' do
    supply_chain = Market::SupplyChain.new(resource_name: 'LOX', volume: 100.0, status: 'pending')
    expect(supply_chain).not_to be_valid
    expect(supply_chain.errors[:market_order]).to be_present
  end

  it 'can track status changes' do
    supply_chain = Market::SupplyChain.create!(
      market_order: market_order,
      resource_name: 'LOX',
      volume: 100.0,
      status: 'pending',
      sourceable_type: sourceable.class.name,
      sourceable_id: sourceable.id,
      destinationable_type: destinationable.class.name,
      destinationable_id: destinationable.id
    )
    supply_chain.update(status: 'in_transit')
    expect(supply_chain.status).to eq('in_transit')
    supply_chain.update(status: 'delivered')
    expect(supply_chain.status).to eq('delivered')
  end

  it 'scopes active supply chains' do
    active_chain = Market::SupplyChain.create!(
      market_order: market_order,
      resource_name: 'LOX',
      volume: 100.0,
      status: 'pending',
      sourceable_type: sourceable.class.name,
      sourceable_id: sourceable.id,
      destinationable_type: destinationable.class.name,
      destinationable_id: destinationable.id
    )
    delivered_chain = Market::SupplyChain.create!(
      market_order: market_order,
      resource_name: 'LOX',
      volume: 50.0,
      status: 'delivered',
      sourceable_type: sourceable.class.name,
      sourceable_id: sourceable.id,
      destinationable_type: destinationable.class.name,
      destinationable_id: destinationable.id
    )
    expect(Market::SupplyChain.active).to include(active_chain)
    expect(Market::SupplyChain.active).not_to include(delivered_chain)
  end
end