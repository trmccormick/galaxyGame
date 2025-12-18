# spec/models/celestial_bodies/features/adapted_feature_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::AdaptedFeature, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }

  let(:adapted_feature) do
    described_class.create!(
      celestial_body: luna,
      feature_id: 'luna_lt_001',
      feature_type: 'lava_tube',
      status: 'natural',
      type: 'CelestialBodies::Features::AdaptedFeature'
    )
  end

  before do
    allow(adapted_feature).to receive(:static_data).and_return({
      'name' => 'Marius Hills Lava Tube',
      'coordinates' => [100.0, 200.0],
      'other_data' => 'example'
    })
  end

  describe 'validations' do
    it { should validate_presence_of(:feature_id) }
    it { should validate_presence_of(:feature_type) }
    it { should belong_to(:celestial_body) }
  end

  describe 'attributes' do
    it 'has a default status of natural' do
      expect(adapted_feature.status).to eq('natural')
    end
    it 'can set and get adapted_at' do
      time = Time.current
      adapted_feature.update!(adapted_at: time)
      expect(adapted_feature.adapted_at).to eq(time)
    end
    it 'can set and get settlement_id' do
      adapted_feature.update!(settlement_id: 42)
      expect(adapted_feature.settlement_id).to eq(42)
    end
    it 'can set and get discovered_by' do
      adapted_feature.update!(discovered_by: 7)
      expect(adapted_feature.discovered_by).to eq(7)
    end
  end

  describe '#static_data' do
    it 'returns static data hash' do
      expect(adapted_feature.static_data).to include('name', 'coordinates')
    end
  end

  describe '#name' do
    it 'returns the name from static data' do
      expect(adapted_feature.name).to eq('Marius Hills Lava Tube')
    end
  end

  describe '#coordinates' do
    it 'returns coordinates from static data' do
      expect(adapted_feature.coordinates).to eq([100.0, 200.0])
    end
  end

  describe '#feature_specific_data' do
    it 'returns the full static data hash' do
      expect(adapted_feature.feature_specific_data).to eq(adapted_feature.static_data)
    end
  end
end
