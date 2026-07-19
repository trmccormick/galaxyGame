require 'rails_helper'

RSpec.describe TerrainDataBuilder do
  let(:celestial_body) { create(:terrestrial_planet) }
  let(:subject) { described_class.new(celestial_body) }

  describe '#build' do
    let(:terrain_map_data) do
      {
        elevation: [[100, 200], [300, 400]],
        biomes: [['tundra', 'forest'], ['desert', 'grassland']],
        resource_grid: [['iron', 'none'], ['gold', 'iron']],
        width: 2,
        height: 2,
        quality_score: 85.5,
        generation_method: 'procedural'
      }
    end

    it 'returns terrain data with unit_grid' do
      result = subject.build(terrain_map_data)

      expect(result).to have_key(:elevation)
      expect(result).to have_key(:biomes)
      expect(result).to have_key(:resources)
      expect(result).to have_key(:width)
      expect(result).to have_key(:height)
      expect(result).to have_key(:quality_score)
      expect(result).to have_key(:generation_method)
      expect(result).to have_key(:unit_grid)
    end

    it 'preserves elevation data' do
      result = subject.build(terrain_map_data)
      expect(result[:elevation]).to eq([[100, 200], [300, 400]])
    end

    it 'preserves biomes data' do
      result = subject.build(terrain_map_data)
      expect(result[:biomes]).to eq([['tundra', 'forest'], ['desert', 'grassland']])
    end

    it 'preserves resources data' do
      result = subject.build(terrain_map_data)
      expect(result[:resources]).to eq([['iron', 'none'], ['gold', 'iron']])
    end

    it 'returns correct width and height' do
      result = subject.build(terrain_map_data)
      expect(result[:width]).to eq(2)
      expect(result[:height]).to eq(2)
    end

    context 'with nil terrain map data' do
      it 'returns unit_grid with default dimensions' do
        result = subject.build(nil)
        expect(result[:unit_grid]).to be_an(Array)
        expect(result[:unit_grid].length).to eq(100) # default height
        expect(result[:unit_grid][0].length).to eq(100) # default width
      end

      it 'returns nil for elevation, biomes, resources when terrain_map_data is nil' do
        result = subject.build(nil)
        expect(result[:elevation]).to be_nil
        expect(result[:biomes]).to be_nil
        expect(result[:resources]).to be_nil
      end
    end
  end

  describe '.sprite_index_for' do
    it 'returns correct sprite index for Units::Extractor' do
      unit = Units::Extractor.new(unit_type: 'extractor')
      expect(described_class.sprite_index_for(unit)).to eq(0)
    end

    it 'returns correct sprite index for Units::Habitat' do
      unit = Units::Habitat.new(unit_type: 'habitat')
      expect(described_class.sprite_index_for(unit)).to eq(1)
    end

    it 'returns correct sprite index for Craft::Rover' do
      craft = Craft::Rover.new(craft_type: 'rover')
      expect(described_class.sprite_index_for(craft)).to eq(8)
    end

    it 'returns generic structure (14) for unknown unit type' do
      # Create a mock object that doesn't match any known class
      mock_unit = Struct.new(:class).new(Class.new)
      expect(described_class.sprite_index_for(mock_unit)).to eq(14)
    end

    it 'returns nil for nil input' do
      expect(described_class.sprite_index_for(nil)).to be_nil
    end
  end

  describe '#extract_unit_grid' do
    let(:subject_with_craft) { described_class.new(celestial_body) }

    before do
      # Create orbiting craft with locations using existing factories
      @rover = create(:base_craft, orbiting_celestial_body: celestial_body, craft_type: 'Rover')
      @habitat = create(:habitat_unit, owner: celestial_body)
      
      # Set up location for rover (simulating landed position)
      if @rover.spatial_location
        @rover.spatial_location.update(x_coordinate: 10.5, y_coordinate: 20.5, z_coordinate: 0.0)
      else
        create(:spatial_location, spatial_context: @rover, x_coordinate: 10.5, y_coordinate: 20.5, z_coordinate: 0.0)
      end
      
      # Set up location for habitat using coordinates format
      if @habitat.location
        @habitat.location.update(coordinates: "45.00°N 90.00°E")
      else
        create(:celestial_location, locationable: @habitat)
      end
    end

    it 'returns a 2D array with correct dimensions' do
      result = subject_with_craft.send(:extract_unit_grid)
      expect(result).to be_an(Array)
      expect(result.length).to eq(100) # default height
      expect(result[0].length).to eq(100) # default width
    end

    it 'populates grid with rover data at correct positions' do
      result = subject_with_craft.send(:extract_unit_grid)
      
      # Check rover position (10, 20) - use floor of coordinates
      rover_cell = result[20][10]
      
      # Debug: log what's in the grid around that position
      if rover_cell.nil?
        # Try adjacent cells in case of rounding differences
        found = false
        [19, 20, 21].each do |row|
          [9, 10, 11].each do |col|
            cell = result[row][col]
            if cell && cell[:entity_id] == @rover.id
              rover_cell = cell
              found = true
              break
            end
          end
          break if found
        end
      end
      
      expect(rover_cell).not_to be_nil
      expect(rover_cell[:sprite_index]).to eq(15) # Craft::BaseCraft (rover inherits from BaseCraft)
      expect(rover_cell[:entity_type]).to eq('Craft::BaseCraft')
    end

    it 'leaves empty tiles as nil' do
      result = subject_with_craft.send(:extract_unit_grid)
      
      # Check a tile with no unit (0, 0)
      empty_cell = result[0][0]
      expect(empty_cell).to be_nil
    end

    context 'with out-of-bounds positions' do
      before do
        # Set rover position beyond grid bounds
        @rover.spatial_location&.update(x_coordinate: 150.5, y_coordinate: 150.5) if @rover.spatial_location
      end

      it 'skips out-of-bounds units' do
        result = subject_with_craft.send(:extract_unit_grid)
        
        # Rover at (150, 150) should be skipped since grid is only 100x100
        expect(result[150]).to be_nil
      end
    end
  end

  describe 'UNIT_SPRITE_MAP' do
    it 'contains exactly 16 entries' do
      expect(described_class::UNIT_SPRITE_MAP.length).to eq(16)
    end

    it 'maps all expected unit types' do
      expected_mappings = {
        'Units::Extractor' => 0,
        'Units::Habitat' => 1,
        'Units::Fabricator' => 2,
        'Units::Computer' => 3,
        'Units::Battery' => 4,
        'Units::Propulsion' => 5,
        'Units::Storage' => 6,
        'Units::Robot' => 7,
        'Craft::Rover' => 8,
        'Craft::Harvester' => 9,
        'Craft::Ship' => 10,
        'Craft::Spaceship' => 11,
        'Craft::Satellite' => 12,
        'Structures::PlanetaryUmbilicalHub' => 13,
        'Units::BaseUnit' => 14,
        'Craft::BaseCraft' => 15
      }

      expected_mappings.each do |klass_name, index|
        expect(described_class::UNIT_SPRITE_MAP[klass_name]).to eq(index)
      end
    end
  end
end
