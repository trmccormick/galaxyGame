# spec/services/terrain_analysis/terrain_decomposition_service_spec.rb

require 'rails_helper'

RSpec.describe TerrainAnalysis::TerrainDecompositionService do
  let(:terrain_data) do
    {
      'width' => 3,
      'height' => 3,
      'grid' => [
        [:deep_sea, :coast, :plains],
        [:grasslands, :forest, :rocky],
        [:mountains, :tundra, :arctic]
      ],
      'biome_counts' => { 'desert' => 2, 'ocean' => 1 }
    }
  end

  subject { described_class.new(terrain_data) }

  describe '#decompose' do
    it 'returns decomposed terrain map with layers and elevation' do
      result = subject.decompose

      expect(result).to include('width', 'height', 'elevation', 'water_volume', 'layers', 'biome_counts')
      expect(result['width']).to eq(3)
      expect(result['height']).to eq(3)
      expect(result['elevation']).to be_an(Array)
      expect(result['layers']).to include('geological', 'hydrological', 'biological')
    end

    it 'generates elevation map from terrain types' do
      result = subject.decompose

      elevation = result['elevation']
      expect(elevation).to be_an(Array)
      expect(elevation.size).to eq(3)
      expect(elevation.first.size).to eq(3)

      # Check that elevations are within expected ranges
      elevation.flatten.compact.each do |elev|
        expect(elev).to be_between(0.0, 1.0)
      end
    end

    it 'separates terrain into correct layers' do
      result = subject.decompose
      layers = result['layers']

      # Check geological layer
      geological = layers['geological']
      expect(geological[0][2]).to eq(:plains)  # plains is geological
      expect(geological[2][0]).to eq(:mountains)  # mountains is geological

      # Check hydrological layer
      hydrological = layers['hydrological']
      expect(hydrological[0][0]).to eq(:deep_sea)  # deep_sea is hydrological
      expect(hydrological[0][1]).to eq(:coast)  # coast is hydrological

      # Check biological layer
      biological = layers['biological']
      expect(biological[1][0]).to eq(:grasslands)  # grasslands is biological
      expect(biological[1][1]).to eq(:forest)  # forest is biological
    end

    it 'calculates initial water volume from hydrological terrain' do
      result = subject.decompose

      # With deep_sea and coast (2 water tiles out of 9), expect ~0.22 water volume
      expect(result['water_volume']).to be_between(0.2, 0.25)
    end

    it 'includes biome_counts in result' do
      result = subject.decompose

      expect(result['biome_counts']).to eq({ 'desert' => 2, 'ocean' => 1 })
    end

    it 'applies dynamic water distribution' do
      result = subject.decompose

      expect(result).to include('sea_level', 'water_coverage', 'grid')
      expect(result['sea_level']).to be_a(Float)
      expect(result['water_coverage']).to be_a(Float)
    end

    context 'with empty terrain data' do
      let(:terrain_data) { {} }

      it 'returns empty hash' do
        result = subject.decompose
        expect(result).to eq({})
      end
    end

    context 'with nil grid' do
      let(:terrain_data) { { 'width' => 3, 'height' => 3 } }

      it 'returns empty hash' do
        result = subject.decompose
        expect(result).to eq({})
      end
    end
  end
end