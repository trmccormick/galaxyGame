# spec/models/celestial_bodies/features/skylight_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::Skylight, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }
  
  let(:lava_tube) do
    CelestialBodies::Features::LavaTube.create!(
      celestial_body: luna,
      feature_id: 'luna_lt_001',
      status: 'natural'
    )
  end
  
  let(:skylight) do
    described_class.create!(
      celestial_body: luna,
      parent_feature: lava_tube,
      feature_id: "#{lava_tube.feature_id}_skylight_1",
      status: 'natural'
    )
  end
  
  describe 'associations' do
    it { should belong_to(:parent_feature).optional }
  end
  
  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(skylight.feature_type).to eq('skylight')
    end
  end
  
  describe '#parent_lava_tube' do
    it 'returns the parent lava tube' do
      expect(skylight.parent_lava_tube).to eq(lava_tube)
    end
  end
  
  describe '#area_m2' do
    it 'calculates area from diameter' do
      allow(skylight).to receive(:diameter_m).and_return(100)
      
      area = skylight.area_m2
      expect(area).to be_within(100).of(7854) # π * 50²
    end
  end
  
  describe '#covered?' do
    it 'returns false when natural' do
      expect(skylight.covered?).to be false
    end
    
    it 'returns true when enclosed' do
      skylight.update!(status: 'enclosed')
      expect(skylight.covered?).to be true
    end
    
    it 'returns true when pressurized' do
      skylight.update!(status: 'pressurized')
      expect(skylight.covered?).to be true
    end
  end
end