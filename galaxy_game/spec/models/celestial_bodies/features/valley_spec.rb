# spec/models/celestial_bodies/features/valley_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::Valley, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }

  let(:valley) do
    described_class.create!(
      celestial_body: luna,
      feature_id: 'luna_valley_001',
      status: 'natural'
    )
  end

  before do
    allow(valley).to receive(:static_data).and_return({
      'dimensions' => {
        'length_m' => 5000,
        'width_m' => 300,
        'depth_m' => 50,
        'volume_m3' => 75000000
      },
      'formation' => 'tectonic',
      'conversion_suitability' => {
        'habitat' => 'good',
        'estimated_cost_multiplier' => 1.1
      },
      'segments' => [
        { 'name' => 'Segment A', 'length_m' => 2000, 'width_m' => 300 },
        { 'name' => 'Segment B', 'length_m' => 3000, 'width_m' => 300 }
      ]
    })
  end

  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(valley.feature_type).to eq('valley')
    end
  end

  describe 'dimension accessors' do
    it 'reads dimensions from static data' do
      expect(valley.length_m).to eq(5000)
      expect(valley.width_m).to eq(300)
      expect(valley.depth_m).to eq(50)
      expect(valley.volume_m3).to eq(75000000)
    end
  end

  describe '#formation' do
    it 'returns formation type' do
      expect(valley.formation).to eq('tectonic')
    end
  end

  describe '#conversion_suitability' do
    it 'returns suitability data' do
      suitability = valley.conversion_suitability
      expect(suitability).to be_a(Hash)
      expect(suitability['habitat']).to eq('good')
      expect(suitability['estimated_cost_multiplier']).to eq(1.1)
    end
  end

  describe '#calculate_construction_segments' do
    it 'returns predefined segments from static data' do
      segments = valley.calculate_construction_segments
      expect(segments.length).to eq(2)
      expect(segments.first[:name]).to eq('Segment A')
      expect(segments.first[:length_m]).to eq(2000)
      expect(segments.first[:width_m]).to eq(300)
    end
  end
end
