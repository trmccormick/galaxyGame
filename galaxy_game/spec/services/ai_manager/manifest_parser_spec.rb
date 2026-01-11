require 'rails_helper'
require_relative '../../../app/services/ai_manager'


RSpec.describe AIManager::ManifestParser do
  let(:parser) { described_class.new }
  let(:manifest_file) { GalaxyGame::Paths::MISSIONS_PATH.join('mars_settlement/mars_orbital_establishment_manifest_v1.json').to_s }

  describe '#extract_equipment_from_manifest' do
    it 'extracts complete equipment data from manifest' do
      result = parser.extract_equipment_from_manifest(manifest_file)

      expect(result).to have_key(:craft_fit)
      expect(result).to have_key(:inventory)
      expect(result).to have_key(:economic_profile)
    end

    it 'handles missing manifest file gracefully' do
      result = parser.extract_equipment_from_manifest('nonexistent_file.json')
      expect(result).to eq({})
    end
  end

  describe '#extract_craft_fit' do
    let(:craft_data) do
      {
        "recommended_fit" => {
          "modules" => [
            { "id" => "compact_nuclear_reactor", "count" => 2 },
            { "id" => "atmospheric_scoop", "count" => 4 }
          ],
          "units" => [
            { "id" => "raptor_engine", "count" => 6 },
            { "id" => "cryogenic_storage_unit", "count" => 4 }
          ]
        }
      }
    end

    it 'extracts modules and units from craft fit' do
      result = parser.extract_craft_fit(craft_data)

      expect(result[:modules]).to include("compact_nuclear_reactor (2)")
      expect(result[:modules]).to include("atmospheric_scoop (4)")
      expect(result[:units]).to include("raptor_engine (6)")
      expect(result[:units]).to include("cryogenic_storage_unit (4)")
      expect(result[:total_modules]).to eq(6)
      expect(result[:total_units]).to eq(10)
    end

    it 'handles nil craft data' do
      result = parser.extract_craft_fit(nil)
      expect(result).to eq({})
    end
  end

  describe '#extract_inventory' do
    let(:inventory_data) do
      {
        "units" => [
          { "name" => "Mars Skimmer Harvesters", "count" => 3 },
          { "name" => "Orbital Assembly Drones", "count" => 5 }
        ],
        "supplies" => [
          { "id" => "titanium_alloy", "count" => 5000, "unit" => "kilogram" },
          { "id" => "carbon_nanotube_material", "count" => 2000, "unit" => "kilogram" }
        ],
        "consumables" => [
          { "id" => "methalox_fuel", "count" => 100000, "unit" => "kilogram" },
          { "id" => "water", "count" => 20000, "unit" => "kilogram" }
        ]
      }
    end

    it 'extracts deployable units, supplies, and consumables' do
      result = parser.extract_inventory(inventory_data)

      expect(result[:deployable_units]).to include("Mars Skimmer Harvesters (3)")
      expect(result[:deployable_units]).to include("Orbital Assembly Drones (5)")
      expect(result[:supplies]).to include("titanium_alloy (5000 kilogram)")
      expect(result[:supplies]).to include("carbon_nanotube_material (2000 kilogram)")
      expect(result[:consumables]).to include("methalox_fuel (100000 kilogram)")
      expect(result[:consumables]).to include("water (20000 kilogram)")
      expect(result[:total_mass]).to eq("127000 kg")
    end
  end

  describe '#calculate_economics' do
    let(:manifest) do
      {
        "inventory" => {
          "supplies" => [
            { "id" => "enriched_uranium_fuel", "count" => 1000, "unit" => "kilogram" },
            { "id" => "titanium_alloy", "count" => 5000, "unit" => "kilogram" },
            { "id" => "carbon_nanotube_material", "count" => 2000, "unit" => "kilogram" }
          ],
          "consumables" => [
            { "id" => "methalox_fuel", "count" => 100000, "unit" => "kilogram" },
            { "id" => "water", "count" => 20000, "unit" => "kilogram" }
          ]
        }
      }
    end

    it 'calculates economic profile with path determination' do
      result = parser.calculate_economics(manifest)

      expect(result[:path]).to be_present
      expect(result[:import_ratio]).to be_a(Float)
      expect(result[:estimated_cost]).to be_a(Integer)
      expect(result[:earth_import_items]).to be_an(Array)
      expect(result[:local_production_items]).to be_an(Array)
    end

    it 'identifies Earth imports vs local production' do
      result = parser.calculate_economics(manifest)

      expect(result[:earth_import_items]).to include("enriched_uranium_fuel")
      expect(result[:local_production_items]).to include("methalox_fuel")
      expect(result[:local_production_items]).to include("water")
    end
  end

  describe '#determine_path' do
    it 'returns Path A for high Earth dependency' do
      earth_imports = ['item1', 'item2', 'item3', 'item4']
      local_potential = ['item5']
      result = parser.send(:determine_path, earth_imports, local_potential)
      expect(result).to eq("A (Complete Modules)")
    end

    it 'returns Path B for mixed approach' do
      earth_imports = ['item1', 'item2']
      local_potential = ['item3', 'item4']
      result = parser.send(:determine_path, earth_imports, local_potential)
      expect(result).to eq("B (Seed Equipment)")
    end

    it 'returns Path C for mostly local production' do
      earth_imports = ['item1']
      local_potential = ['item2', 'item3', 'item4', 'item5']
      result = parser.send(:determine_path, earth_imports, local_potential)
      expect(result).to eq("C (Hybrid)")
    end
  end
end