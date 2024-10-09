require 'rails_helper'

RSpec.describe MaterialLookupService do
  let(:service) { MaterialLookupService.new }

  before do
    allow(YAML).to receive(:load_file).and_return({
      "ores" => [{"name" => "iron", "properties" => "Metallic element."}],
      "meteorites" => [{"name" => "iron meteorite", "properties" => "Type of meteorite."}],
      "raw_ores" => [{"name" => "copper", "properties" => "Another metallic element."}]
    })
  end

  describe '#find_material' do
    it 'returns the correct material' do
      expect(service.find_material("iron")).to include("name" => "iron")
      expect(service.find_material("copper")).to include("name" => "copper")
      expect(service.find_material("iron meteorite")).to include("name" => "iron meteorite")
    end

    it 'returns nil for a nonexistent material' do
      expect(service.find_material("gold")).to be_nil
    end
  end
end