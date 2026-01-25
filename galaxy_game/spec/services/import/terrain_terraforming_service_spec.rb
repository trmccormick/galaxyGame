require 'rails_helper'

RSpec.describe Import::TerrainTerraformingService do
  let(:terraformed_data) do
    {
      grid: [
        [:ocean, :deep_sea, :arctic],
        [:tundra, :rocky, :arctic],
        [:deep_sea, :ocean, :tundra]
      ]
    }
  end

  describe '#determine_planet_type' do
    context 'with arid planet characteristics (Mars-like)' do
      let(:planet_characteristics) do
        {
          atmosphere: { composition: { co2: 95 } },
          hydrosphere: { water_bodies: [] },
          surface_temperature: 280
        }
      end

      it 'returns :arid' do
        service = described_class.new(terraformed_data, planet_characteristics)
        expect(service.determine_planet_type).to eq(:arid)
      end
    end

    context 'with oceanic planet characteristics' do
      let(:planet_characteristics) do
        {
          atmosphere: { composition: { water_vapor: 1, n2: 78, o2: 21 } },
          hydrosphere: { water_bodies: [:ocean] },
          surface_temperature: 288
        }
      end

      it 'returns :oceanic' do
        service = described_class.new(terraformed_data, planet_characteristics)
        expect(service.determine_planet_type).to eq(:oceanic)
      end
    end

    context 'with ice world characteristics' do
      let(:planet_characteristics) do
        {
          body_category: 'ice_world',
          surface_temperature: 200
        }
      end

      it 'returns :ice_world' do
        service = described_class.new(terraformed_data, planet_characteristics)
        expect(service.determine_planet_type).to eq(:ice_world)
      end
    end

    context 'with temperate planet characteristics' do
      let(:planet_characteristics) do
        {
          atmosphere: { composition: { n2: 78, o2: 21 } },
          hydrosphere: { water_bodies: [:lakes] },
          surface_temperature: 280
        }
      end

      it 'returns :temperate' do
        service = described_class.new(terraformed_data, planet_characteristics)
        expect(service.determine_planet_type).to eq(:temperate)
      end
    end

    context 'with very cold planet (below freezing)' do
      let(:planet_characteristics) do
        {
          atmosphere: { composition: { co2: 95 } },
          hydrosphere: { water_bodies: [] },
          surface_temperature: 200  # Below 273K
        }
      end

      it 'returns :ice_world' do
        service = described_class.new(terraformed_data, planet_characteristics)
        expect(service.determine_planet_type).to eq(:ice_world)
      end
    end
  end

  describe 'RESOURCE_NODE_SOURCES' do
    it 'has correct sources for ice_world' do
      expect(described_class::RESOURCE_NODE_SOURCES[:ice_world]).to eq([:arctic, :tundra])
    end

    it 'has correct sources for arid' do
      expect(described_class::RESOURCE_NODE_SOURCES[:arid]).to eq([:arctic, :rocky])
    end

    it 'has correct sources for oceanic' do
      expect(described_class::RESOURCE_NODE_SOURCES[:oceanic]).to eq([:rocky])
    end

    it 'has correct sources for temperate' do
      expect(described_class::RESOURCE_NODE_SOURCES[:temperate]).to eq([:tundra, :rocky])
    end

    it 'falls back to default for unknown planet type' do
      service = described_class.new(terraformed_data, {})
      planet_type = :unknown
      sources = described_class::RESOURCE_NODE_SOURCES[planet_type] || described_class::RESOURCE_NODE_SOURCES[:default]
      expect(sources).to eq([:arctic, :tundra, :deep_sea])
    end
  end

  describe '#generate_barren_terrain' do
    let(:planet_characteristics) do
      {
        atmosphere: { composition: { co2: 95 } },
        hydrosphere: { water_bodies: [] },
        surface_temperature: 280
      }
    end

    it 'generates barren terrain with strategic markers' do
      service = described_class.new(terraformed_data, planet_characteristics)
      result = service.generate_barren_terrain

      expect(result).to be_a(Hash)
      expect(result).to have_key(:grid)
      expect(result).to have_key(:strategic_markers)
      expect(result[:strategic_markers]).to have_key(:resource_nodes)
      expect(result[:strategic_markers]).to have_key(:water_collection_zones)
    end

    it 'identifies resource nodes for arid planet' do
      service = described_class.new(terraformed_data, planet_characteristics)
      result = service.generate_barren_terrain

      # Should find arctic and rocky as resource nodes
      resource_positions = result[:strategic_markers][:resource_nodes]
      expect(resource_positions).to include([0, 2]) # arctic
      expect(resource_positions).to include([1, 1]) # rocky
    end

    it 'does not mark water collection zones for arid planet' do
      service = described_class.new(terraformed_data, planet_characteristics)
      result = service.generate_barren_terrain

      water_zones = result[:strategic_markers][:water_collection_zones]
      expect(water_zones).to be_empty
    end

    context 'with oceanic planet' do
      let(:oceanic_characteristics) do
        {
          atmosphere: { composition: { water_vapor: 1, n2: 78, o2: 21 } },
          hydrosphere: { water_bodies: [:ocean] },
          surface_temperature: 288
        }
      end

      it 'marks water collection zones' do
        service = described_class.new(terraformed_data, oceanic_characteristics)
        result = service.generate_barren_terrain

        water_zones = result[:strategic_markers][:water_collection_zones]
      expect(water_zones).to include([0, 0]) # ocean at [0,0]
      expect(water_zones).to include([1, 0]) # deep_sea at [1,0]
      expect(water_zones).to include([0, 2]) # deep_sea at [0,2]? Wait, [2,0] is deep_sea at row 2, column 0
      expect(water_zones).to include([0, 2]) # wait, [0,2] is arctic, no
      # Actually, water zones are [0,0], [1,0], [0,2]? No
      # [2,0] is [0,2] in [x,y]? No, [x,y] = [0,2] is column 0, row 2: deep_sea
      expect(water_zones).to include([0, 2]) # deep_sea at [0,2] (x=0, y=2)
      expect(water_zones).to include([1, 2]) # ocean at [1,2] (x=1, y=2)

        resource_positions = result[:strategic_markers][:resource_nodes]
      expect(resource_positions).to include([1, 0]) # deep_sea position [1,0] becomes rocky
      expect(resource_positions).to include([0, 2]) # deep_sea position [0,2] becomes rocky
      expect(resource_positions).to include([1, 1]) # rocky position [1,1] remains rocky
      end
    end
  end
end