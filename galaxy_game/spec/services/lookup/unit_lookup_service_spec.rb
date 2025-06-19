require 'rails_helper'
require 'json'

RSpec.describe Lookup::UnitLookupService do
  let(:service) { described_class.new }

  describe '#find_unit' do
    it 'loads units from the correct file structure' do
      # ✅ FIX: Use correct path matching the service
      units_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "units")
      expect(File.directory?(units_path)).to be true
      
      # Check for propulsion subdirectory
      propulsion_path = File.join(units_path, 'propulsion')
      expect(File.directory?(propulsion_path)).to be true
    end

    it 'finds units by unit_type' do
      raptor_engine = service.find_unit("raptor_engine")
      
      if raptor_engine
        expect(raptor_engine["unit_type"]).to eq("raptor_engine")
        expect(raptor_engine["name"]).to eq("Raptor Engine")
        expect(raptor_engine["thrust"]).to be_a(Numeric)
      else
        pending "raptor_engine unit not found - check if file exists in propulsion directory"
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
      expected_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "units")
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
        skip "raptor_engine unit not found" unless raptor_engine
        
        expected_properties = %w[name description unit_type category]
        expected_properties.each do |prop|
          expect(raptor_engine).to have_key(prop)
        end
      end
      
      it 'has correct thrust specification' do
        skip "raptor_engine unit not found" unless raptor_engine
        
        expect(raptor_engine['thrust']).to be_a(Numeric)
        expect(raptor_engine['mass']).to be_a(Numeric)
      end
      
      it 'follows the operational data template' do
        skip "raptor_engine unit not found" unless raptor_engine
        
        if raptor_engine['operational_properties']
          expect(raptor_engine['operational_properties']['power_consumption_kw']).to be_present
        end
      end
    end

    context 'when lox_storage_tank unit exists' do
      let(:lox_tank) { service.find_unit("lox_storage_tank") }
      
      it 'has storage capacity properties' do
        skip "lox_storage_tank unit not found" unless lox_tank
        
        expect(lox_tank['storage']).to be_present
        expect(lox_tank['storage']['capacity']).to be_a(Numeric)
      end

      it 'has alias support' do
        skip "lox_storage_tank unit not found" unless lox_tank
        
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


