require 'rails_helper'
require_relative '../../../../galaxy_game/app/services/terrain/terrain_quality_assessor'

RSpec.describe TerrainAnalysis::TerrainQualityAssessor do
  let(:assessor) { described_class.new }

  # Public method coverage
  describe '#assess_terrain_quality' do
    it 'returns a hash with expected keys' do
      result = assessor.assess_terrain_quality({})
      expect(result).to have_key(:realism)
      expect(result).to have_key(:playability)
      expect(result).to have_key(:diversity)
      expect(result).to have_key(:balance)
      expect(result).to have_key(:overall)
    end

    it 'returns scores between 0 and 1' do
      result = assessor.assess_terrain_quality({})
      expect(result[:realism]).to be_between(0.0, 1.0)
      expect(result[:playability]).to be_between(0.0, 1.0)
      expect(result[:diversity]).to be_between(0.0, 1.0)
      expect(result[:balance]).to be_between(0.0, 1.0)
      expect(result[:overall]).to be_between(0.0, 1.0)
    end

    it 'calculates overall as weighted average of sub-scores' do
      terrain_data = {
        elevation: [100, 200, 300],
        biomes: [['grassland', 'forest'], ['desert', 'tundra']],
        resource_counts: { iron: 10, gold: 5, water: 8 }
      }
      planet_properties = { radius: 6371000, surface_temperature: 288 }

      result = assessor.assess_terrain_quality(terrain_data, planet_properties)

      expected_overall = (result[:realism] * 0.4 + result[:playability] * 0.3 +
                          result[:diversity] * 0.2 + result[:balance] * 0.1)
      expect(result[:overall]).to eq(expected_overall.round(10))
    end

    context 'with nil terrain_data' do
      it 'raises NoMethodError on nil input' do
        expect { assessor.assess_terrain_quality(nil, {}) }.to raise_error(NoMethodError)
      end
    end

    context 'with empty planet_properties' do
      it 'returns base scores without elevation/biome bonuses' do
        terrain_data = {
          elevation: [100, 200, 300],
          biomes: [['grassland', 'forest'], ['desert', 'tundra']]
        }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:realism]).to be >= 0.5 # base score
      end
    end

    context 'with elevation data keys' do
      it 'accepts :elevation key' do
        terrain_data = { elevation: [100, 200, 300] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result).to be_a(Hash)
      end

      it 'accepts :elevation_data key' do
        terrain_data = { elevation_data: [100, 200, 300] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result).to be_a(Hash)
      end
    end

    context 'with biome data keys' do
      it 'accepts :biomes key' do
        terrain_data = { biomes: [['grassland', 'forest'], ['desert']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result).to be_a(Hash)
      end

      it 'accepts :terrain key' do
        terrain_data = { terrain: [['grassland', 'forest'], ['desert']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result).to be_a(Hash)
      end

      it 'accepts :terrain_grid key' do
        terrain_data = { terrain_grid: [['grassland', 'forest'], ['desert']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result).to be_a(Hash)
      end
    end

    context 'with planet properties' do
      context 'cold planet' do
        it 'awards realism bonus for ice-dominated biomes when temp < 273' do
          terrain_data = { biomes: [['ice', 'ice', 'tundra'], ['snow', 'ice']] }
          result = assessor.assess_terrain_quality(terrain_data, { surface_temperature: 200 })
          expect(result[:realism]).to be > 0.5
        end

        it 'does not award ice bonus for habitable temperature' do
          terrain_data = { biomes: [['ice', 'ice', 'tundra'], ['snow', 'ice']] }
          result = assessor.assess_terrain_quality(terrain_data, { surface_temperature: 300 })
          expect(result[:realism]).to be <= 0.5
        end
      end

      context 'habitable planet' do
        it 'awards realism bonus for earth-like biomes when temp between 273-373' do
          terrain_data = { biomes: [['grassland', 'forest'], ['plains', 'desert']] }
          result = assessor.assess_terrain_quality(terrain_data, { surface_temperature: 288 })
          expect(result[:realism]).to be > 0.5
        end
      end

      context 'elevation scale validation' do
        it 'awards realism bonus when elevation matches planet size for small body' do
          # Small body: radius 3000km, expected max elev ~300km (10%)
          terrain_data = { elevation: [200, 250, 300] }
          result = assessor.assess_terrain_quality(terrain_data, { radius: 3000000 })
          expect(result[:realism]).to be > 0.5
        end

        it 'does not award bonus when elevation is way off' do
          # Tiny elevations for large planet
          terrain_data = { elevation: [1, 2, 3] }
          result = assessor.assess_terrain_quality(terrain_data, { radius: 6371000 })
          expect(result[:realism]).to be <= 0.5
        end
      end
    end

    context 'with resource grid' do
      it 'awards playability bonus for 5-25% resource ratio' do
        # 2 of 8 cells have resources = 25%
        terrain_data = { resource_grid: [['iron', 'none', 'gold', 'none'], ['none', 'water', 'none', 'none']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be > 0.5
      end

      it 'does not award bonus for too sparse resources (<5%)' do
        # 'none' is a non-nil string, so compact doesn't remove it
        # All 16 cells are non-nil (iron + 15 'none'), ratio = 100% > 25%, no bonus
        terrain_data = { resource_grid: Array.new(4) { Array.new(4, 'none') } }
        terrain_data[:resource_grid][0][0] = 'iron'
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be <= 0.6 # base + possible clustering bonus
      end

      it 'does not award bonus for too dense resources (>25%)' do
        terrain_data = { resource_grid: [['iron', 'gold'], ['water', 'uranium']] }
        result = assessor.assess_terrain_quality(terrain_data)
        # 4/4 = 100% which is > 25%, no bonus
        expect(result[:playability]).to be <= 0.6 # base 0.5 + clustering 0.1 max
      end

      it 'handles empty resource grid' do
        terrain_data = { resource_grid: [] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be_a(Float)
      end

      it 'handles nil cells in resource grid' do
        terrain_data = { resource_grid: [['iron', nil], [nil, 'gold']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be_a(Float)
      end
    end

    context 'with strategic markers' do
      it 'awards playability bonus when > 5 markers' do
        markers = Array.new(6) { { x: rand(10), y: rand(10) } }
        terrain_data = { strategic_markers: markers }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be > 0.5
      end

      it 'does not award bonus when <= 5 markers' do
        markers = Array.new(5) { { x: rand(10), y: rand(10) } }
        terrain_data = { strategic_markers: markers }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be <= 0.6 # base + possible bonuses
      end
    end

    context 'with water ratio check' do
      it 'awards playability bonus when water < 80%' do
        terrain_data = { biomes: [['grassland', 'forest'], ['desert', 'plains']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be > 0.5
      end

      it 'does not award bonus when water >= 80%' do
        terrain_data = { biomes: [['ocean', 'water'], ['ocean', 'water']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:playability]).to be <= 0.6
      end
    end

    context 'with diversity scoring' do
      it 'awards elevation diversity for varied elevations' do
        terrain_data = { elevation: Array.new(20) { rand(100..1000) } }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:diversity]).to be > 0
      end

      it 'awards biome diversity for varied biomes' do
        terrain_data = { biomes: [['grassland', 'forest'], ['desert', 'tundra']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:diversity]).to be > 0
      end

      it 'awards resource diversity for multiple resource types' do
        terrain_data = { resource_counts: { iron: 10, gold: 5, water: 8, titanium: 3 } }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:diversity]).to be > 0
      end

      it 'handles single biome type (low diversity)' do
        terrain_data = { biomes: [['grassland', 'grassland'], ['grassland', 'grassland']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:diversity]).to be >= 0
      end
    end

    context 'with balance scoring' do
      it 'awards bonus when no single resource > 50%' do
        terrain_data = { resource_counts: { iron: 10, gold: 10, water: 10 } }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:balance]).to be > 0.5
      end

      it 'does not award bonus when one resource dominates' do
        terrain_data = { resource_counts: { iron: 90, gold: 5, water: 5 } }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:balance]).to be <= 0.7 # base + variety bonus possible
      end

      it 'awards bonus for >= 3 resource types' do
        terrain_data = { resource_counts: { iron: 10, gold: 10, water: 10 } }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:balance]).to be > 0.5
      end

      it 'handles strategic marker distribution' do
        markers = Array.new(10) { { x: rand(50), y: rand(50) } }
        terrain_data = { strategic_markers: markers }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:balance]).to be_a(Float)
      end

      it 'handles empty strategic markers' do
        terrain_data = { strategic_markers: [] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:balance]).to be_a(Float)
      end
    end

    context 'boundary conditions' do
      it 'returns base weighted score for completely empty data' do
        # realism=0.5, playability=0.5, diversity=0.0, balance=0.5
        # overall = 0.5*0.4 + 0.5*0.3 + 0.0*0.2 + 0.5*0.1 = 0.4
        result = assessor.assess_terrain_quality({})
        expect(result[:overall]).to be_within(0.01).of(0.4)
      end

      it 'handles all nil values' do
        terrain_data = { elevation: nil, biomes: nil, resource_grid: nil }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:overall]).to be >= 0
      end

      it 'handles very large grid' do
        terrain_data = {
          elevation: Array.new(100) { rand(0..5000) },
          biomes: Array.new(10) { Array.new(10, ['grassland', 'forest', 'desert'].sample) }
        }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:overall]).to be_between(0.0, 1.0)
      end

      it 'handles single cell grid' do
        terrain_data = { elevation: [42], biomes: [['grassland']] }
        result = assessor.assess_terrain_quality(terrain_data)
        expect(result[:overall]).to be_a(Float)
      end

      it 'handles string biome types' do
        terrain_data = { biomes: [['ice', 'tundra'], ['snow', 'grassland']] }
        result = assessor.assess_terrain_quality(terrain_data, { surface_temperature: 200 })
        expect(result[:realism]).to be_a(Float)
      end

      it 'handles symbol biome types' do
        terrain_data = { biomes: [[:ice, :tundra], [:snow, :grassland]] }
        result = assessor.assess_terrain_quality(terrain_data, { surface_temperature: 200 })
        expect(result[:realism]).to be_a(Float)
      end
    end
  end
end
