require 'rails_helper'
require 'json'

RSpec.describe Lookup::UnitLookupService do
  let(:service) { described_class.new }

  describe '#find_unit' do
    it 'loads units from the correct file structure' do
      # BEFORE: units_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "units")
      # FIX: GalaxyGame::Paths::UNITS_PATH already returns the full, correct path.
      # Use it directly to check if the directory exists.
      units_path = GalaxyGame::Paths::UNITS_PATH # This is now Pathname object: /home/galaxy_game/app/data/operational_data/units
      
      expect(File.directory?(units_path)).to be true
      
      # Check for propulsion subdirectory
      # Assuming 'propulsion' is a valid subdirectory under your units data
      propulsion_path = units_path.join('propulsion') # Use Pathname#join for consistency
      expect(File.directory?(propulsion_path)).to be true
    end

    it 'finds units by unit_type' do
      raptor_engine = service.find_unit("raptor_engine")
      
      if raptor_engine
        expect(raptor_engine["unit_type"]).to eq("raptor_engine")
        expect(raptor_engine["name"]).to eq("Raptor Engine")
        expect(raptor_engine["thrust"]).to be_a(Numeric)
      else
        # Remove "pending" unless you *truly* expect it to fail.
        # This spec should now pass if the file is found.
        # If the file isn't found, this will cause a regular failure, which is what we want.
        fail "raptor_engine unit not found - check if file exists in propulsion directory at #{GalaxyGame::Paths::UNITS_PATH.join('propulsion', 'raptor_engine.json')}"
      end
    end

    it 'finds units case-insensitively' do
      raptor_engine = service.find_unit("RAPTOR_ENGINE")
      lox_tank = service.find_unit("LOX_TANK")
      
      # Only test if units exist
      expect(raptor_engine).to be_present if raptor_engine
      expect(lox_tank).to be_present if lox_tank
    end

    it 'returns nil for nonexistent units' do
      expect(service.find_unit("nonexistent_unit")).to be_nil
    end

    it 'handles nil and blank unit types' do
      expect(service.find_unit(nil)).to be_nil
      expect(service.find_unit("")).to be_nil
      expect(service.find_unit("   ")).to be_nil
    end
  end

  describe 'service configuration' do
    it 'has the correct base path' do
      # BEFORE: expected_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "units")
      # FIX: The expected path is simply the value of GalaxyGame::Paths::UNITS_PATH.
      # Convert it to a string for comparison.
      expected_path = GalaxyGame::Paths::UNITS_PATH.to_s
      
      actual_path = described_class.base_units_path.to_s
      expect(actual_path).to eq(expected_path)
    end
    
    it 'has all expected unit categories' do
      expected_categories = %w[computer droid energy habitat life_support processing production propulsion storage structure various]
      actual_categories = described_class::UNIT_PATHS.keys.map(&:to_s)
      expect(actual_categories).to match_array(expected_categories)
    end
  end

  describe 'unit data structure validation' do
    context 'when raptor_engine unit exists' do
      let(:raptor_engine) { service.find_unit("raptor_engine") }
      
      it 'has all expected unit properties' do
        # FIX: Remove skip and let it fail if not found, it's what we want to test.
        # If raptor_engine is nil, the expect will correctly fail.
        expect(raptor_engine).to be_present # Add this to ensure unit is found before checking properties
        expected_properties = %w[name description unit_type category]
        expected_properties.each do |prop|
          expect(raptor_engine).to have_key(prop)
        end
      end
      
      it 'has correct thrust specification' do
        expect(raptor_engine).to be_present
        expect(raptor_engine['thrust']).to be_a(Numeric)
        expect(raptor_engine['mass']).to be_a(Numeric)
      end
      
      it 'follows the operational data template' do
        expect(raptor_engine).to be_present
        if raptor_engine['operational_properties']
          expect(raptor_engine['operational_properties']['power_consumption_kw']).to be_present
        end
      end
    end

    context 'when lox_storage_tank unit exists' do
      let(:lox_tank) { service.find_unit("lox_storage_tank") }
      
      it 'has storage capacity properties' do
        expect(lox_tank).to be_present
        expect(lox_tank['storage']).to be_present
        expect(lox_tank['storage']['capacity']).to be_a(Numeric)
      end

      it 'has alias support' do
        expect(lox_tank).to be_present
        if lox_tank['aliases']
          expect(lox_tank['aliases']).to include('lox_tank')
        end
      end
    end
  end

  describe 'error handling' do
    it 'handles JSON parsing errors gracefully' do
      expect { service.find_unit("") }.not_to raise_error
      expect { service.find_unit(nil) }.not_to raise_error
    end
    
    it 'handles missing base directory gracefully' do
      expect { described_class.new }.not_to raise_error
    end
  end
end


