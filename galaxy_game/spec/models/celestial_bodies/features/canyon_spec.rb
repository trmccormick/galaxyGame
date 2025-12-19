# spec/models/celestial_bodies/features/canyon_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Features::Canyon, type: :model do
  let(:moon) { create(:moon) }
  let(:static_data) do
    {
      'dimensions' => {
        'length_m' => 12000,
        'width_m' => 500,
        'depth_m' => 200,
        'volume_m3' => 1200000000
      },
      'formation' => 'tectonic_rifting',
      'conversion_suitability' => { 'habitat' => true },
      'segments' => ['north', 'central', 'south']
    }
  end
  subject(:canyon) do
    build(:canyon_feature, celestial_body: moon, static_data: static_data)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(canyon).to be_valid
    end
    it 'sets feature_type to canyon before validation' do
      canyon.valid?
      expect(canyon.feature_type).to eq('canyon')
    end
  end

  describe 'dimensions' do
    it 'returns correct length_m' do
      expect(canyon.length_m).to eq(12000)
    end
    it 'returns correct width_m' do
      expect(canyon.width_m).to eq(500)
    end
    it 'returns correct depth_m' do
      expect(canyon.depth_m).to eq(200)
    end
    it 'returns correct volume_m3' do
      expect(canyon.volume_m3).to eq(1200000000)
    end
  end

  describe '#formation' do
    it 'returns the formation type' do
      expect(canyon.formation).to eq('tectonic_rifting')
    end
  end

  describe '#conversion_suitability' do
    it 'returns the conversion suitability hash' do
      expect(canyon.conversion_suitability).to eq({ 'habitat' => true })
    end
  end

  describe '#segments' do
    it 'returns the segments array' do
      expect(canyon.segments).to eq(['north', 'central', 'south'])
    end
  end

  describe '#can_pressurize_section?' do
    it 'returns false if not enclosed or openings not sealed' do
      allow(canyon).to receive(:enclosed?).and_return(false)
      allow(canyon).to receive(:all_openings_sealed?).and_return(false)
      expect(canyon.can_pressurize_section?).to be_falsey
    end
    it 'returns true if enclosed and all openings sealed' do
      allow(canyon).to receive(:enclosed?).and_return(true)
      allow(canyon).to receive(:all_openings_sealed?).and_return(true)
      expect(canyon.can_pressurize_section?).to be_truthy
    end
  end
end
