require 'rails_helper'

RSpec.describe CelestialBodies::MinorBodies::Protoplanet, type: :model do
  let(:solar_system) { create(:solar_system) }

  let(:protoplanet) do
    create(:protoplanet, solar_system: solar_system)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(protoplanet).to be_valid
    end

    it 'requires mass greater than 1e19 kg' do
      protoplanet.mass = 1e18
      expect(protoplanet).not_to be_valid
    end

    it 'allows mass up to 1e24 kg' do
      protoplanet.mass = 1e24
      expect(protoplanet).to be_valid
    end
  end

  describe '#is_spherical?' do
    it 'returns true for protoplanets' do
      expect(protoplanet.is_spherical?).to eq(true)
    end
  end

  describe '#calculate_geological_activity' do
    it 'calculates geological activity based on mass' do
      expect(protoplanet.calculate_geological_activity).to be_a(Numeric)
    end
  end

  describe '#composition_type' do
    it 'returns a valid composition type' do
      expect([:differentiated_metal_core, :differentiated_stony]).to include(protoplanet.composition_type)
    end
  end

  describe '#estimated_mineral_value' do
    it 'calculates mineral value based on mass and composition' do
      expect(protoplanet.estimated_mineral_value).to be_a(Integer)
      expect(protoplanet.estimated_mineral_value).to be >= 0
    end
  end
end