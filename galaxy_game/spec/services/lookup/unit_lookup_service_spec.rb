require 'rails_helper'
require 'json'

RSpec.describe Lookup::UnitLookupService do
  let(:service) { described_class.new }

  describe '#find_unit' do
    it 'loads units from the correct file structure' do
      units_path = Rails.root.join("app", "data", "units")
      expect(File.directory?(units_path)).to be true
      
      # Check subdirectories exist
      expect(File.directory?(units_path.join("propulsion"))).to be true
      expect(File.directory?(units_path.join("storage"))).to be true
      
      # Verify we have JSON files
      json_files = Dir.glob(File.join(units_path, "**", "*.json"))
      expect(json_files).not_to be_empty
    end

    it 'loads JSON files with correct format' do
      # Get an engine unit to check structure
      engine_unit = service.find_unit("raptor_engine")
      expect(engine_unit).to include(
        "name",
        "unit_type",
        "thrust" # Actual field in the JSON
      )
      
      # Get a storage unit to check structure
      storage_unit = service.find_unit("lox_storage_tank")
      expect(storage_unit).to include(
        "name",
        "unit_type"
      )
    end

    it 'finds storage tanks with correct data' do
      # Get actual data from the JSON files
      tank = service.find_unit('lox_storage_tank')
      expect(tank).to include("name" => include("Storage"))
      
      # Check for storage capacity field with correct nesting
      expect(tank).to include("storage")
      expect(tank["storage"]).to include("capacity")
      expect(tank["storage"]["capacity"]).to be_a(Numeric)
    end

    it 'finds unit by alias' do
      # Get actual data from the JSON files
      tank = service.find_unit('lox_tank')
      expect(tank).to include("aliases" => include("lox_tank"))
      
      # Check storage capacity field with correct nesting
      expect(tank).to include("storage")
      expect(tank["storage"]).to include("capacity")
      expect(tank["storage"]["capacity"]).to be_a(Numeric)
    end

    it 'caches results when found by alias' do
      first_result = service.find_unit('lox_tank')
      second_result = service.find_unit('lox_tank')
      expect(first_result.object_id).to eq(second_result.object_id)
    end

    it 'returns nil when unit does not exist' do
      result = service.find_unit('nonexistent_unit')
      expect(result).to be_nil
    end
  end

  describe '#units' do
    it 'loads all units' do
      units = service.units
      expect(units.keys).to include('storage', 'propulsion', 'housing')
      
      storage_units = units['storage']
      expect(storage_units).to include(
        a_hash_including('name' => 'LOX Storage Tank')
      )
    end
  end
end


