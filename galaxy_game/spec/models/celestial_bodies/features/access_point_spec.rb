# spec/models/celestial_bodies/features/access_point_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::AccessPoint, type: :model do
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
  
  let(:access_point) do
    described_class.create!(
      celestial_body: luna,
      parent_feature: lava_tube,
      feature_id: "#{lava_tube.feature_id}_access_1",
      status: 'natural'
    )
  end
  
  describe 'associations' do
    it { should belong_to(:parent_feature).optional }
  end
  
  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(access_point.feature_type).to eq('access_point')
    end
  end
  
  describe '#sealed?' do
    it 'returns false when natural' do
      expect(access_point.sealed?).to be false
    end
    
    it 'returns true when enclosed' do
      access_point.update!(status: 'enclosed')
      expect(access_point.sealed?).to be true
    end
  end
  
  describe '#area_m2' do
    it 'calculates area from length and width' do
      allow(access_point).to receive(:length_m).and_return(10)
      allow(access_point).to receive(:width_m).and_return(5)
      
      expect(access_point.area_m2).to eq(50)
    end
    
    it 'calculates area from diameter if no length/width' do
      allow(access_point).to receive(:length_m).and_return(nil)
      allow(access_point).to receive(:width_m).and_return(nil)
      allow(access_point).to receive(:diameter_m).and_return(10)
      
      area = access_point.area_m2
      expect(area).to be_within(1).of(78.5) # π * 5²
    end
  end
end