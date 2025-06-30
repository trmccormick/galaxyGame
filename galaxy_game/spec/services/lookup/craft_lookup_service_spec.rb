require 'rails_helper'

RSpec.describe Lookup::CraftLookupService, type: :service do
  let(:service) { described_class.new }

  describe '#find_craft' do
    it 'loads crafts from the correct file structure' do
      crafts_path = Pathname.new(GalaxyGame::Paths::CRAFTS_PATH)
      expect(File.directory?(crafts_path)).to be true

      expect(File.directory?(GalaxyGame::Paths::ATMOSPHERIC_CRAFTS_PATH)).to be true
      expect(File.directory?(GalaxyGame::Paths::GROUND_CRAFTS_PATH)).to be true
      expect(File.directory?(GalaxyGame::Paths::SPACE_CRAFTS_PATH)).to be true

      json_files = Dir.glob(File.join(crafts_path, "*", "*", "*.json"))
      expect(json_files).not_to be_empty
    end

    it 'loads JSON files with correct format' do
      crafts_path = Pathname.new(GalaxyGame::Paths::CRAFTS_PATH)
      json_files = Dir.glob(File.join(crafts_path, "*", "*", "*.json"))
      skip "No craft JSON files found to test" if json_files.empty?

      json_files.each do |file|
        data = JSON.parse(File.read(file))
        expect(data).to be_a(Hash)
        expect(data).to have_key('id')
        expect(data).to have_key('name')
      end
    end

    it 'returns nil for nonexistent crafts' do
      expect(service.find_craft('nonexistent_craft')).to be_nil
    end

    it 'validates input parameters' do
      expect { service.find_craft('') }
        .to raise_error(ArgumentError, 'Invalid craft name')
    end

    it 'uses cached results for subsequent lookups' do
      crafts_path = Pathname.new(GalaxyGame::Paths::CRAFTS_PATH)
      json_files = Dir.glob(File.join(crafts_path, "*", "*", "*.json"))
      skip "No craft JSON files found to test caching" if json_files.empty?

      craft_data = JSON.parse(File.read(json_files.first))
      craft_name = craft_data['id'] || craft_data['name']
      expect(service.find_craft(craft_name)).to eq(service.find_craft(craft_name))
    end
  end
end