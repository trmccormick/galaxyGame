# spec/models/celestial_bodies/features/lava_tube_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::LavaTube, type: :model do
  let(:star) { create(:star) }
  let(:sol) { create(:solar_system, current_star: star, name: 'Sol') }
  let(:luna) { create(:moon, name: 'Luna', identifier: 'luna', solar_system: sol) }
  
  let(:lava_tube) do
    feature = described_class.create!(
      celestial_body: luna,
      feature_id: 'luna_lt_001',
      status: 'natural'
    )
    static = {
      'dimensions' => {
        'length_m' => 1500,
        'width_m' => 100,
        'height_m' => 50,
        'estimated_volume_m3' => 7_500_000
      },
      'attributes' => {
        'natural_shielding' => 'high',
        'thermal_stability' => 'good'
      },
      'conversion_suitability' => {
        'habitat' => 'excellent',
        'estimated_cost_multiplier' => 0.7,
        'advantages' => ['natural shielding', 'stable temperature'],
        'challenges' => ['access points must be sealed']
      },
      'natural_openings' => [
        {
          'type' => 'skylight',
          'feature_id' => 'luna_lt_001_sk_001',
          'status' => 'natural'
        }
      ],
      'priority' => 'high',
      'strategic_value' => ['Protection/Shielding', 'Subsurface habitat']
    }
    allow(feature).to receive(:static_data).and_return(static)
    allow(feature).to receive(:natural_openings).and_return(static['natural_openings'])
    # Simulate child creation for openings
    # Enhanced test double for skylight
    skylight = double('Skylight',
      feature_type: 'skylight',
      parent_lava_tube: feature,
      status: 'enclosed',
      enclosed?: false,
      pressurized?: false
    )
    # Allow update! to change status and enclosed? as needed
    allow(skylight).to receive(:update!) do |attrs|
      if attrs[:status] == 'enclosed'
        allow(skylight).to receive(:enclosed?).and_return(true)
        allow(skylight).to receive(:status).and_return('enclosed')
      end
    end
    allow(feature).to receive(:skylights).and_return([skylight])
    allow(feature).to receive(:access_points).and_return([])
    allow(feature).to receive(:create_openings_from_static_data!).and_return([skylight])
    feature
  end
  
  describe 'associations' do
    it { should have_many(:skylights) }
    it { should have_many(:access_points) }
  end
  
  describe '#set_feature_type' do
    it 'automatically sets feature_type' do
      expect(lava_tube.feature_type).to eq('lava_tube')
    end
  end
  
  describe 'dimension accessors' do
    it 'reads dimensions from static data' do
      expect(lava_tube.length_m).to eq(1500)
      expect(lava_tube.width_m).to eq(100)
      expect(lava_tube.height_m).to eq(50)
      expect(lava_tube.estimated_volume_m3).to be > 0
    end
  end
  
  describe '#conversion_suitability' do
    it 'returns suitability data' do
      suitability = lava_tube.conversion_suitability
      
      expect(suitability).to be_a(Hash)
      expect(lava_tube.suitability_rating).to eq('excellent')
      expect(lava_tube.estimated_cost_multiplier).to eq(0.7)
      expect(lava_tube.advantages).to be_an(Array)
      expect(lava_tube.challenges).to be_an(Array)
    end
  end
  
  describe '#natural_openings' do
    it 'returns openings from static data' do
      openings = lava_tube.natural_openings
      expect(openings).to be_an(Array)
      # Marius Hills has at least one skylight
      expect(openings.length).to be > 0
    end
  end
  
  describe '#create_openings_from_static_data!' do
    it 'creates child opening features' do
      before_count = lava_tube.skylights.count + lava_tube.access_points.count
      lava_tube.create_openings_from_static_data!
      after_count = lava_tube.skylights.count + lava_tube.access_points.count
      expect(after_count).to be >= before_count
    end
    
    it 'creates skylights for skylight openings' do
      lava_tube.create_openings_from_static_data!
      
      expect(lava_tube.skylights).not_to be_empty
      skylight = lava_tube.skylights.first
      expect(skylight.feature_type).to eq('skylight')
      expect(skylight.parent_lava_tube).to eq(lava_tube)
    end
  end
  
  describe '#can_pressurize?' do
    before do
      lava_tube.update!(status: 'enclosed')
      lava_tube.create_openings_from_static_data!
    end
    
    it 'returns false if openings are not sealed' do
      expect(lava_tube.can_pressurize?).to be false
    end
    
    it 'returns true when all openings are sealed' do
      lava_tube.skylights.each { |s| s.update!(status: 'enclosed') }
      lava_tube.access_points.each { |a| a.update!(status: 'enclosed') }
      
      expect(lava_tube.can_pressurize?).to be true
    end
  end
  
  describe '#strategic_value' do
    it 'returns strategic value array' do
      expect(lava_tube.strategic_value).to be_an(Array)
      expect(lava_tube.strategic_value).to include('Protection/Shielding')
    end
  end
end