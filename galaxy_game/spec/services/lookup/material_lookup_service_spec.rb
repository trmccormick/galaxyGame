require 'rails_helper'
require 'json'

RSpec.describe Lookup::MaterialLookupService do
  let(:service) { described_class.new }

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = Rails.root.join("app", "data", "materials", "raw", "gases")
      expect(File.directory?(gases_path)).to be true
      json_files = Dir.glob(File.join(gases_path, "*.json"))
      expect(json_files).not_to be_empty
    end

    it 'loads json files with correct format' do
      co2 = service.find_material("CO2")
      expect(co2).to include(
        "id",
        "name",
        "chemical_formula",
        "properties"
      )
    end

    it 'finds atmospheric gases by chemical formula' do
      co2 = service.find_material("CO2")
      expect(co2).to include("chemical_formula" => "CO2")
      expect(co2["properties"]).to include("molar_mass" => 44.01)

      n2 = service.find_material("N2")
      expect(n2).to include("chemical_formula" => "N2")
      expect(n2["properties"]).to include("molar_mass" => 28.0134)

      ar = service.find_material("Ar")
      expect(ar).to include("chemical_formula" => "Ar")
      expect(ar["properties"]).to include("molar_mass" => 39.948)
    end

    it 'finds materials case-insensitively' do
      expect(service.find_material("co2")).to include("chemical_formula" => "CO2")
      expect(service.find_material("n2")).to include("chemical_formula" => "N2")
    end

    it 'returns nil for nonexistent materials' do
      expect(service.find_material("xyz")).to be_nil
    end
  end
end