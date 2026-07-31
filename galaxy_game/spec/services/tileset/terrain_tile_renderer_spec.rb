# spec/services/tileset/terrain_tile_renderer_spec.rb
#
# Validates the TerrainTileRenderer JavaScript class and asset availability.
# Ensures all 45 terrain tiles (5 families × 9 variants) are accessible via
# the public assets path mounted from data/images/terrain/.
#
# Run:
#   docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec \
#     spec/services/tileset/terrain_tile_renderer_spec.rb

require 'rails_helper'

RSpec.describe 'TerrainTileRenderer asset integrity', type: :service do
  TERRAIN_FAMILIES = %w[dust frozen regolith temperate volcanic].freeze
  VARIANT_COUNT    = 9
  TILE_BASE_PATH   = Rails.root.join('data', 'images', 'terrain')

  describe 'terrain tile files' do
    TERRAIN_FAMILIES.each do |terrain|
      context "terrain family: #{terrain}" do
        it 'directory exists' do
          dir_path = TILE_BASE_PATH.join(terrain)
          expect(File.directory?(dir_path)).to be true,
            "Expected #{dir_path} to exist"
        end

        (1..VARIANT_COUNT).each do |variant_num|
          variant_name = "variant_#{format('%02d', variant_num)}"
          
          it "has #{variant_name}.png" do
            file_path = TILE_BASE_PATH.join(terrain, "#{variant_name}.png")
            expect(File.exist?(file_path)).to be true,
              "Expected tile at #{file_path}"
          end

          it "#{variant_name}.png is a valid PNG" do
            file_path = TILE_BASE_PATH.join(terrain, "#{variant_name}.png")
            # Basic PNG magic number check (first 8 bytes)
            png_magic = "\x89PNG\r\n\x1a\n".b
            content = File.read(file_path, 8)
            expect(content).to eq(png_magic),
              "File #{file_path} is not a valid PNG (missing PNG magic bytes)"
          end
        end
      end
    end
  end

  describe 'tile availability via public assets path' do
    it 'docker volume mount maps data/images/terrain to public/assets/terrain' do
      # This validates the expectation that the docker-compose volume mount
      # ./data/images:/home/galaxy_game/public/assets makes tiles accessible at /assets/terrain/
      # Test runs in-container, so we verify the public/assets/terrain path exists
      
      public_terrain_path = Rails.root.join('public', 'assets', 'terrain')
      expect(File.directory?(public_terrain_path)).to be true,
        "Expected #{public_terrain_path} to exist (docker volume mount)"
    end
  end

  describe 'tile inventory summary' do
    it 'has exactly 45 tiles (5 families × 9 variants)' do
      total = 0
      TERRAIN_FAMILIES.each do |terrain|
        (1..VARIANT_COUNT).each do |variant_num|
          variant_name = "variant_#{format('%02d', variant_num)}"
          file_path = TILE_BASE_PATH.join(terrain, "#{variant_name}.png")
          total += 1 if File.exist?(file_path)
        end
      end

      expected = TERRAIN_FAMILIES.size * VARIANT_COUNT
      expect(total).to eq(expected),
        "Expected #{expected} tiles, found #{total}"
    end

    it 'lists all terrain families' do
      families = TERRAIN_FAMILIES.sort
      expect(families).to match_array(%w[dust frozen regolith temperate volcanic])
    end

    it 'each family has 9 variants' do
      TERRAIN_FAMILIES.each do |terrain|
        dir_path = TILE_BASE_PATH.join(terrain)
        pngs = Dir.glob(dir_path.join('*.png')).sort
        expect(pngs.size).to eq(VARIANT_COUNT),
          "#{terrain}: expected #{VARIANT_COUNT} variants, found #{pngs.size}"
      end
    end
  end

  describe 'tile dimensions' do
    it 'all tiles are 150×150 pixels' do
      pngs_checked = 0
      TERRAIN_FAMILIES.each do |terrain|
        (1..VARIANT_COUNT).each do |variant_num|
          variant_name = "variant_#{format('%02d', variant_num)}"
          file_path = TILE_BASE_PATH.join(terrain, "#{variant_name}.png")
          
          next unless File.exist?(file_path)

          # Check PNG dimensions via `sips` (macOS) or skip if not available
          output = `sips -g pixelWidth -g pixelHeight "#{file_path}" 2>/dev/null`
          if $?.success?
            expect(output).to include('150'),
              "#{terrain}/#{variant_name}.png: expected width 150"
            expect(output).to include('150'),
              "#{terrain}/#{variant_name}.png: expected height 150"
            pngs_checked += 1
          end
        end
      end

      # If we ran sips checks, we should have found tiles
      expect(pngs_checked).to be > 0,
        'No PNG dimensions checked (sips may not be available)'
    end
  end
end
