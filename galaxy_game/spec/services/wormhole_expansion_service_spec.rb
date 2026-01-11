require 'rails_helper'

RSpec.describe WormholeExpansionService, type: :service do
  let(:service) { described_class.new }

  describe '#initialize' do
    it 'initializes with default values' do
      expect(service).to be_a(WormholeExpansionService)
    end
  end

  describe '#find_expansion_opportunities' do
    let!(:solar_system) { create(:solar_system, wormhole_capacity: 5) }
    let!(:wormhole) { create(:wormhole, solar_system_a: solar_system, artificial_station_built: false) }
    let!(:player) { create(:player) }

    it 'finds systems with available wormhole capacity' do
      opportunities = service.find_expansion_opportunities

      expect(opportunities).to include(solar_system)
    end

    it 'excludes systems at maximum capacity' do
      # Create wormholes to fill capacity
      5.times { create(:wormhole, solar_system_a: solar_system, artificial_station_built: true) }

      opportunities = service.find_expansion_opportunities

      expect(opportunities).not_to include(solar_system)
    end
  end

  describe '#create_gate_construction_contract' do
    let!(:solar_system) { create(:solar_system, wormhole_capacity: 5) }
    let!(:player) { create(:player) }
    let!(:from_settlement) { create(:base_settlement, name: 'From Settlement') }
    let!(:to_settlement) { create(:base_settlement, name: 'To Settlement') }

    it 'creates a contract for gate construction' do
      contract = service.create_gate_construction_contract(solar_system, player)

      expect(contract).to be_persisted
      expect(contract.material).to eq('wormhole_gate')
      expect(contract.provider).to be_a(Logistics::Provider)
    end
  end

  describe '#create_rescue_contract' do
    let!(:solar_system) { create(:solar_system) }
    let!(:disconnected_player) { create(:player) }
    let!(:from_settlement) { create(:base_settlement, name: 'From Settlement') }
    let!(:to_settlement) { create(:base_settlement, name: 'To Settlement') }

    it 'creates a rescue contract for disconnected players' do
      contract = service.create_rescue_contract(disconnected_player)

      expect(contract).to be_persisted
      expect(contract.material).to eq('player_rescue')
      expect(contract.provider).to be_a(Logistics::Provider)
    end
  end
end