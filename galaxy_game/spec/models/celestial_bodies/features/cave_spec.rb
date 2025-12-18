# spec/models/celestial_bodies/features/cave_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::Cave, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }

  let(:cave) do
    described_class.create!(
      celestial_body: luna,
      feature_id: 'luna_cave_001',
      status: 'natural'
    )
  end

  before do
    allow(cave).to receive(:static_data).and_return({
      'dimensions' => {
        'depth_m' => 120,
        'network_size_m' => 2000,
        'volume_m3' => 5000000
      },
      'cave_type' => 'lava',
      'conversion_suitability' => {
        'habitat' => 'fair',
        'estimated_cost_multiplier' => 1.3
      }
    })
  end

  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(cave.feature_type).to eq('cave')
    end
  end

  describe 'dimension accessors' do
    it 'reads dimensions from static data' do
      expect(cave.depth_m).to eq(120)
      expect(cave.network_size_m).to eq(2000)
      expect(cave.volume_m3).to eq(5000000)
    end
  end

  describe '#cave_type' do
    it 'returns cave type' do
      expect(cave.cave_type).to eq('lava')
    end
  end

  describe '#conversion_suitability' do
    it 'returns suitability data' do
      suitability = cave.conversion_suitability
      expect(suitability).to be_a(Hash)
      expect(suitability['habitat']).to eq('fair')
      expect(suitability['estimated_cost_multiplier']).to eq(1.3)
    end
  end

  describe '#can_pressurize?' do
    it 'returns false when not enclosed or openings not sealed' do
      expect(cave.can_pressurize?).to be false
    end
  end
end
