# spec/services/tileset/biome_renderer_config_spec.rb
#
# Validates the BiomeRenderer configuration (biomes.json) and asset file integrity.
# Ensures the JSON contract that the JavaScript BiomeRenderer class depends on
# is complete, well-formed, and backed by real PNG assets.
#
# Run:
#   docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec \
#     spec/services/tileset/biome_renderer_config_spec.rb

require 'rails_helper'

RSpec.describe 'BiomeRenderer configuration', type: :service do
  BIOMES_JSON_PATH = Rails.root.join('public', 'tilesets', 'galaxy_game', 'biomes.json').freeze
  BIOME_ASSETS_DIR = Rails.root.join('public', 'assets', 'biomes').freeze

  EXPECTED_BIOME_KEYS = %w[
    desert
    forest
    grasslands
    jungle
    mountains
    mountains_snow_covered
    ocean
    plains
    swamp
    tundra
  ].freeze

  REQUIRED_BIOME_FIELDS = %w[file label color_fallback elevation_range climate].freeze

  let(:raw_json) { File.read(BIOMES_JSON_PATH) }
  let(:config)   { JSON.parse(raw_json) }

  # ── biomes.json existence & parse ────────────────────────────────
  describe 'biomes.json' do
    it 'exists on disk' do
      expect(File.exist?(BIOMES_JSON_PATH)).to be true
    end

    it 'is valid JSON' do
      expect { JSON.parse(raw_json) }.not_to raise_error
    end

    it 'contains top-level version field' do
      expect(config['version']).to be_present
    end

    it 'tile_size is exactly 142' do
      expect(config['tile_size']).to eq(142)
    end

    it 'asset_path is present' do
      expect(config['asset_path']).to be_present
    end

    it 'biomes key is a Hash' do
      expect(config['biomes']).to be_a(Hash)
    end
  end

  # ── biome key completeness ────────────────────────────────────────
  describe 'biome registry' do
    it 'contains exactly 10 biome entries' do
      expect(config['biomes'].keys.length).to eq(10)
    end

    EXPECTED_BIOME_KEYS.each do |biome|
      it "includes the '#{biome}' biome" do
        expect(config['biomes']).to have_key(biome)
      end
    end

    it 'has no unexpected biome keys' do
      extra = config['biomes'].keys - EXPECTED_BIOME_KEYS
      expect(extra).to be_empty,
        "Unexpected biome keys found: #{extra.inspect}. " \
        "Update EXPECTED_BIOME_KEYS or biomes.json."
    end
  end

  # ── per-biome field validation ────────────────────────────────────
  describe 'individual biome entries' do
    EXPECTED_BIOME_KEYS.each do |biome|
      context "biome: #{biome}" do
        subject(:entry) { config['biomes'][biome] }

        REQUIRED_BIOME_FIELDS.each do |field|
          it "has field '#{field}'" do
            expect(entry[field]).to be_present
          end
        end

        it 'file field ends with .png' do
          expect(entry['file']).to end_with('.png')
        end

        it 'color_fallback is a valid hex colour' do
          expect(entry['color_fallback']).to match(/\A#[0-9a-fA-F]{3,6}\z/)
        end

        it 'elevation_range is an array of two numbers' do
          range = entry['elevation_range']
          expect(range).to be_an(Array)
          expect(range.length).to eq(2)
          expect(range).to all(be_a(Numeric))
          expect(range[0]).to be <= range[1]
        end

        it 'climate is a non-empty string' do
          expect(entry['climate']).to be_a(String)
          expect(entry['climate']).not_to be_empty
        end
      end
    end
  end

  # ── PNG asset presence on disk ────────────────────────────────────
  describe 'biome PNG assets' do
    it 'biomes asset directory exists at public/assets/biomes/' do
      expect(Dir.exist?(BIOME_ASSETS_DIR)).to be true
    end

    EXPECTED_BIOME_KEYS.each do |biome|
      it "#{biome}.png exists in public/assets/biomes/" do
        path = BIOME_ASSETS_DIR.join("#{biome}.png")
        expect(File.exist?(path)).to be(true),
          "Missing PNG: #{path}\n" \
          "Place the file at public/assets/biomes/#{biome}.png"
      end
    end

    it 'all PNG filenames in biomes.json match actual files on disk' do
      config['biomes'].each do |name, meta|
        path = BIOME_ASSETS_DIR.join(meta['file'])
        expect(File.exist?(path)).to be(true),
          "biomes.json entry '#{name}' references missing file: #{meta['file']} (checked in public/assets/biomes/)"
      end
    end
  end
end
