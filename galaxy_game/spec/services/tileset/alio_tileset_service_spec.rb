# spec/services/tileset/alio_tileset_service_spec.rb
require 'rails_helper'

RSpec.describe Tileset::AlioTilesetService do
  subject(:service) { described_class.new }

  describe '#load' do
    context 'when tileset files exist' do
      it 'loads successfully' do
        expect(service.load).to be true
      end

      it 'populates tiles hash' do
        service.load
        expect(service.tiles).not_to be_empty
      end

      it 'has no errors' do
        service.load
        expect(service.errors).to be_empty
      end
    end
  end

  describe '#get_tile' do
    before { service.load }

    it 'returns tile data for valid tag' do
      tile = service.get_tile('ts.thermal_vent:0')
      expect(tile).to be_present
      expect(tile[:image]).to eq('terrain.png')
      expect(tile[:x]).to be_a(Integer)
      expect(tile[:y]).to be_a(Integer)
      expect(tile[:width]).to eq(126)
      expect(tile[:height]).to eq(64)
    end

    it 'returns nil for invalid tag' do
      expect(service.get_tile('nonexistent.tile')).to be_nil
    end
  end

  describe '#get_burrow_tube_tile' do
    before { service.load }

    it 'returns isolated tube (no connections)' do
      tile = service.get_burrow_tube_tile({})
      expect(tile).to be_present
      expect(tile[:image]).to eq('burrowtubes.png')
    end

    it 'returns connected tube (north + south)' do
      tile = service.get_burrow_tube_tile(n: true, s: true)
      expect(tile).to be_present
      expect(tile[:image]).to eq('burrowtubes.png')
    end

    it 'returns fully connected tube' do
      tile = service.get_burrow_tube_tile(n: true, e: true, se: true, s: true, w: true, nw: true)
      expect(tile).to be_present
    end
  end

  describe '#get_hill_tile' do
    before { service.load }

    it 'returns hill tile for adjacency pattern' do
      tile = service.get_hill_tile(n: true, e: true)
      expect(tile).to be_present
      expect(tile[:image]).to eq('hills.png')
    end
  end

  describe '#get_feature_tile' do
    before { service.load }

    it 'returns thermal_vent tile' do
      tile = service.get_feature_tile(:thermal_vent)
      expect(tile).to be_present
      expect(tile[:image]).to eq('terrain.png')
    end

    it 'returns glowing_rocks tile' do
      tile = service.get_feature_tile(:glowing_rocks)
      expect(tile).to be_present
    end

    it 'returns huge_plant tile' do
      tile = service.get_feature_tile(:huge_plant)
      expect(tile).to be_present
    end

    it 'returns nil for unknown feature' do
      expect(service.get_feature_tile(:unknown_feature)).to be_nil
    end
  end

  describe '#available_tiles' do
    before { service.load }

    it 'returns array of tile tags' do
      tiles = service.available_tiles
      expect(tiles).to be_an(Array)
      expect(tiles).not_to be_empty
    end

    it 'includes expected tile types' do
      tiles = service.available_tiles
      expect(tiles).to include('ts.thermal_vent:0')
      expect(tiles.any? { |t| t.include?('burrow_tube') }).to be true
      expect(tiles.any? { |t| t.include?('hills') }).to be true
    end
  end

  describe '#tiles_by_category' do
    before { service.load }

    it 'groups tiles by category' do
      categories = service.tiles_by_category
      expect(categories).to have_key(:terrain)
      expect(categories).to have_key(:burrow_tubes)
      expect(categories).to have_key(:hills)
      expect(categories).to have_key(:features)
    end

    it 'has burrow tube tiles' do
      categories = service.tiles_by_category
      expect(categories[:burrow_tubes]).not_to be_empty
    end
  end

  describe '#tiles_for_body' do
    it 'returns Luna/Moon configuration' do
      config = service.tiles_for_body('Luna')
      expect(config[:base]).to eq('radiating_rocks')
      expect(config[:underground]).to eq('burrow_tube')
    end

    it 'returns Mars configuration' do
      config = service.tiles_for_body('Mars')
      expect(config[:base]).to eq('radiating_rocks')
      expect(config[:features]).to include('thermal_vent')
    end

    it 'returns Titan configuration' do
      config = service.tiles_for_body('Titan')
      expect(config[:base]).to eq('alien_forest')
      expect(config[:features]).to include('huge_plant')
    end
  end

  describe '#tile_css' do
    before { service.load }

    it 'generates valid CSS for tile' do
      css = service.tile_css('ts.thermal_vent:0')
      expect(css).to include("background-image: url('/tilesets/alio/terrain.png')")
      expect(css).to include('background-position:')
      expect(css).to include('width: 126px')
      expect(css).to include('height: 64px')
    end

    it 'returns nil for invalid tile' do
      expect(service.tile_css('invalid')).to be_nil
    end
  end

  describe '#tile_data' do
    before { service.load }

    it 'generates data attributes for JavaScript' do
      data = service.tile_data('ts.thermal_vent:0')
      expect(data['tile-image']).to eq('/tilesets/alio/terrain.png')
      expect(data['tile-x']).to be_a(Integer)
      expect(data['tile-y']).to be_a(Integer)
      expect(data['tile-width']).to eq(126)
      expect(data['tile-height']).to eq(64)
    end
  end

  describe 'adjacency encoding' do
    before { service.load }

    it 'encodes empty adjacency correctly' do
      tile = service.get_burrow_tube_tile({})
      # Should get the n0e0se0s0w0nw0 variant (row 0, col 0)
      expect(tile[:row]).to eq(0)
      expect(tile[:col]).to eq(0)
    end

    it 'encodes north-only adjacency' do
      tile = service.get_burrow_tube_tile(n: true)
      # n1e0se0s0w0nw0 should be row 0, col 1
      expect(tile[:row]).to eq(0)
      expect(tile[:col]).to eq(1)
    end
  end
end
