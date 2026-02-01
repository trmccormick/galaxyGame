# spec/services/terrain_analysis/hydrosphere_volume_service_spec.rb

require 'rails_helper'

RSpec.describe TerrainAnalysis::HydrosphereVolumeService do
  let(:terrain_map) do
    {
      'width' => 3,
      'height' => 3,
      'elevation' => [
        [0.1, 0.2, 0.3],  # Row 0
        [0.4, 0.5, 0.6],  # Row 1
        [0.7, 0.8, 0.9]   # Row 2
      ],
      'water_volume' => 0.5,  # 50% water coverage
      'grid' => [
        [:deep_sea, :coast, :plains],
        [:grasslands, :forest, :rocky],
        [:mountains, :tundra, :arctic]
      ]
    }
  end

  subject { described_class.new(terrain_map) }

  describe '#calculate_sea_level' do
    context 'with 50% water volume' do
      it 'returns the correct sea level elevation' do
        # With 9 tiles and 50% water volume = 4.5 tiles underwater
        # Sorted elevations: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
        # 4.5 rounded = 5 tiles, so elevation at index 4 = 0.5
        expect(subject.calculate_sea_level(0.5)).to eq(0.5)
      end
    end

    context 'with 0% water volume' do
      it 'returns the minimum elevation' do
        expect(subject.calculate_sea_level(0.0)).to eq(0.1)
      end
    end

    context 'with 100% water volume' do
      it 'returns the maximum elevation' do
        expect(subject.calculate_sea_level(1.0)).to eq(0.9)
      end
    end

    context 'with no water_volume in terrain_map' do
      let(:terrain_map) { super().except('water_volume') }

      it 'defaults to 0.0 water volume' do
        expect(subject.calculate_sea_level).to eq(0.1)
      end
    end
  end

  describe '#update_water_bodies' do
    it 'updates the grid with dynamic water distribution' do
      result = subject.update_water_bodies

      expect(result).to include('grid', 'sea_level', 'water_coverage')
      expect(result['sea_level']).to eq(0.5)
      expect(result['water_coverage']).to be_a(Float)
    end

    it 'marks tiles below sea level as water types' do
      result = subject.update_water_bodies
      grid = result['grid']

      # Check that low elevation tiles become water
      expect([:deep_sea, :coast, :ocean]).to include(grid[0][0])  # elevation 0.1 < 0.5
      expect([:deep_sea, :coast, :ocean]).to include(grid[0][1])  # elevation 0.2 < 0.5
    end

    it 'keeps high elevation tiles as land' do
      result = subject.update_water_bodies
      grid = result['grid']

      # Check that high elevation tiles remain land
      expect(grid[2][2]).to eq(:arctic)  # elevation 0.9 > 0.5
    end
  end

  describe '#add_water_volume' do
    it 'increases water volume and updates distribution' do
      original_volume = terrain_map['water_volume']
      result = subject.add_water_volume(0.2)

      expect(result['water_volume']).to eq(original_volume + 0.2)
      expect(result).to include('sea_level', 'water_coverage')
    end

    it 'caps water volume at 1.0' do
      result = subject.add_water_volume(0.8)  # 0.5 + 0.8 = 1.3, should cap at 1.0

      expect(result['water_volume']).to eq(1.0)
    end
  end

  describe '#remove_water_volume' do
    it 'decreases water volume and updates distribution' do
      original_volume = terrain_map['water_volume']
      result = subject.remove_water_volume(0.2)

      expect(result['water_volume']).to eq(original_volume - 0.2)
      expect(result).to include('sea_level', 'water_coverage')
    end

    it 'floors water volume at 0.0' do
      result = subject.remove_water_volume(0.8)  # 0.5 - 0.8 = -0.3, should floor at 0.0

      expect(result['water_volume']).to eq(0.0)
    end
  end
end