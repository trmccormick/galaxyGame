# spec/models/celestial_bodies/features/crater_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::Crater, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }
  
  let(:shackleton) do
    feature = described_class.create!(
      celestial_body: luna,
      feature_id: 'luna_cr_001', # Shackleton Crater
      status: 'natural'
    )
    allow(feature).to receive(:static_data).and_return({
      'dimensions' => {
        'diameter_m' => 21000,
        'depth_m' => 4200,
        'rim_height_m' => 200,
        'floor_area_m2' => 346360000
      },
      'crater_type' => 'impact',
      'composition' => {
        'ice_present' => true,
        'ice_concentration' => 'high'
      },
      'attributes' => {
        'permanently_shadowed' => true,
        'solar_exposure_percent' => 89,
        'temperature_floor_k' => 40
      },
      'conversion_suitability' => {
        'crater_dome' => 'excellent',
        'estimated_cost_multiplier' => 1.2,
        'advantages' => ['permanent ice deposits'],
        'challenges' => ['extremely large dome required']
      },
      'resources' => {
        'water_ice_tons' => 600_000_000,
        'accessible_ice_tons' => 150_000_000,
        'minerals' => ['ilmenite']
      },
      'priority' => 'high',
      'strategic_value' => ['water_ice', 'location']
    })
    feature
  end
  
  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(shackleton.feature_type).to eq('crater')
    end
  end
  
  describe 'dimension accessors' do
    it 'reads dimensions from static data' do
      expect(shackleton.diameter_m).to eq(21000)
      expect(shackleton.depth_m).to eq(4200)
      expect(shackleton.rim_height_m).to eq(200)
      expect(shackleton.floor_area_m2).to eq(346360000)
    end
  end
  
  describe 'ice detection' do
    it 'detects ice presence' do
      expect(shackleton.has_ice?).to be true
      expect(shackleton.ice_concentration).to eq('high')
    end
    
    it 'returns ice quantities' do
      expect(shackleton.water_ice_tons).to eq(600000000)
      expect(shackleton.accessible_ice_tons).to eq(150000000)
    end
  end
  
  describe '#permanently_shadowed?' do
    it 'returns true for Shackleton' do
      expect(shackleton.permanently_shadowed?).to be true
    end
  end
  
  describe '#solar_exposure_percent' do
    it 'returns solar exposure data' do
      expect(shackleton.solar_exposure_percent).to eq(89)
    end
  end
  
  describe '#conversion_suitability' do
    it 'returns dome suitability' do
      expect(shackleton.dome_suitability).to eq('excellent')
      expect(shackleton.estimated_cost_multiplier).to eq(1.2)
    end
    
    it 'returns advantages and challenges' do
      expect(shackleton.advantages).to include('permanent ice deposits')
      expect(shackleton.challenges).to include('extremely large dome required')
    end
  end
  
  describe '#size_category' do
    it 'categorizes crater size' do
      expect(shackleton.size_category).to eq('medium') # 21km diameter
    end
  end
  
  describe '#strategic_value' do
    it 'includes water_ice for Shackleton' do
      expect(shackleton.strategic_value).to include('water_ice')
    end
  end
end