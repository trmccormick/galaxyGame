require 'rails_helper'

RSpec.describe Structures::PlanetaryUmbilicalHub, type: :model do
  let(:blueprint_path) { Rails.root.join('data/json-data/blueprints/structures/planetary_umbilical_hub_bp.json') }
  let(:operational_data_path) { Rails.root.join('data/json-data/operational_data/structures/planetary_umbilical_hub_data.json') }
  let(:blueprint) { JSON.parse(File.read(blueprint_path)) }
  let(:operational_data) { JSON.parse(File.read(operational_data_path)) }

  subject(:hub) do
    described_class.new(
      name: 'Test Hub',
      structure_name: blueprint['name'],
      structure_type: 'facility',
      operational_data: operational_data
    )
  end

  it 'is valid with valid attributes and operational data' do
    expect(hub).to be_valid
  end

  it 'loads correct blueprint data' do
    expect(blueprint['id']).to eq('planetary_umbilical_hub')
    expect(blueprint['name']).to eq('Planetary Umbilical Hub')
  end

  it 'loads correct operational data' do
    expect(hub.operational_data['structure_type']).to eq('facility')
    expect(hub.operational_data['category']).to eq('infrastructure')
    expect(hub.operational_data['container_capacity']['module_slots'].first['type']).to eq('industrial_refinery_module')
  end

  describe '#connected_craft?' do
    let(:craft) { double('Craft', id: 42) }

    before do
      hub.operational_data['umbilical_connections'] = {
        '42' => { 'status' => 'active' }
      }
    end

    it 'returns true if craft is actively connected' do
      expect(hub.connected_craft?(craft)).to be true
    end

    it 'returns false if craft is not connected' do
      hub.operational_data['umbilical_connections']['42']['status'] = 'disconnected'
      expect(hub.connected_craft?(craft)).to be false
    end
  end

  describe '#disconnect_craft' do
    let(:craft) { double('Craft', id: 99) }

    before do
      hub.operational_data['umbilical_connections'] = {
        '99' => { 'status' => 'active' }
      }
      allow(hub).to receive(:update!).and_call_original
    end

    it 'sets the connection status to disconnected' do
      expect {
        hub.disconnect_craft(craft)
      }.to change { hub.operational_data['umbilical_connections']['99']['status'] }.from('active').to('disconnected')
    end
  end
end
