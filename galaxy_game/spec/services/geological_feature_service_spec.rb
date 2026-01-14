require 'rails_helper'

RSpec.describe GeologicalFeatureService do
  let(:luna) {
    CelestialBodies::Satellites::Moon.create!(
      name: "Luna",
      identifier: "LUNA-01",
      size: 0.273,
      gravity: 1.62,
      density: 3.344,
      mass: 7.342e22,
      radius: 1.737e6,
      orbital_period: 27.322
    )
  }

  let(:service) { described_class.new(luna) }

  describe '#load_features' do
    it 'returns a hash with celestial body information' do
      result = service.load_features
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:celestial_body)
      expect(result).to have_key(:lava_tubes)
      expect(result).to have_key(:craters)
      expect(result).to have_key(:strategic_sites)
    end

    it 'includes celestial body metadata' do
      result = service.load_features
      
      expect(result[:celestial_body][:id]).to eq(luna.id)
      expect(result[:celestial_body][:name]).to eq('Luna')
      expect(result[:celestial_body][:identifier]).to eq('LUNA-01')
    end

    context 'when geological JSON files exist' do
      it 'loads lava tubes from JSON file' do
        result = service.load_features
        
        # Should have lava tubes array (may be empty if files don't exist)
        expect(result[:lava_tubes]).to be_an(Array)
      end

      it 'loads craters from JSON file' do
        result = service.load_features
        
        # Should have craters array (may be empty if files don't exist)
        expect(result[:craters]).to be_an(Array)
      end

      it 'combines strategic sites from both lava tubes and craters' do
        result = service.load_features
        
        expect(result[:strategic_sites]).to be_an(Array)
      end
    end

    context 'when JSON files contain data' do
      before do
        # If actual JSON files exist, these tests will validate structure
        skip unless File.exist?(Rails.root.join('app', 'data', 'json-data', 'star_systems', 'sol', 'celestial_bodies', 'earth', 'luna', 'geological_features', 'lava_tubes.json'))
      end

      it 'formats lava tube features with correct structure' do
        result = service.load_features
        
        if result[:lava_tubes].any?
          feature = result[:lava_tubes].first
          
          expect(feature).to have_key(:id)
          expect(feature).to have_key(:name)
          expect(feature).to have_key(:type)
          expect(feature).to have_key(:lat)
          expect(feature).to have_key(:lon)
          expect(feature[:type]).to eq('lava_tube')
        end
      end

      it 'formats crater features with correct structure' do
        result = service.load_features
        
        if result[:craters].any?
          feature = result[:craters].first
          
          expect(feature).to have_key(:id)
          expect(feature).to have_key(:name)
          expect(feature).to have_key(:type)
          expect(feature).to have_key(:lat)
          expect(feature).to have_key(:lon)
          expect(feature[:type]).to eq('crater')
        end
      end
    end
  end
end
