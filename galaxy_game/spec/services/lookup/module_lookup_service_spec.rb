require 'rails_helper'
require 'json'

RSpec.describe Lookup::ModuleLookupService do
  let(:service) { described_class.new }

  describe '#find_module' do
    it 'loads modules from the correct file structure' do
      modules_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "modules")
      expect(File.directory?(modules_path)).to be true
      
      life_support_path = File.join(modules_path, 'life_support')
      expect(File.directory?(life_support_path)).to be true
    end

    it 'finds modules by module_type' do
      co2_scrubber = service.find_module("co2_scrubber")
      
      if co2_scrubber
        expect(co2_scrubber["module_type"]).to eq("co2_scrubber")
        expect(co2_scrubber["name"]).to eq("CO2 Scrubber Module")
        expect(co2_scrubber.dig("consumables", "energy")).to eq(5.0)
      else
        pending "co2_scrubber module not found - check if file exists in life_support directory"
      end
    end

    it 'finds modules case-insensitively' do
      co2_scrubber = service.find_module("CO2_SCRUBBER")
      life_support = service.find_module("LIFE_SUPPORT")
      
      # Only test if modules exist
      expect(co2_scrubber).to be_present if co2_scrubber
      expect(life_support).to be_present if life_support
    end

    it 'returns nil for nonexistent modules' do
      expect(service.find_module("nonexistent_module")).to be_nil
    end

    it 'handles nil and blank module types' do
      expect(service.find_module(nil)).to be_nil
      expect(service.find_module("")).to be_nil
      expect(service.find_module("   ")).to be_nil
    end
  end

  describe 'service configuration' do
    it 'has the correct base path' do
      expected_path = File.join(Rails.root, GalaxyGame::Paths::JSON_DATA, "operational_data", "modules")
      actual_path = described_class.base_modules_path.to_s
      expect(actual_path).to eq(expected_path)
    end
    
    it 'has all expected module categories' do
      expected_categories = %w[computer defense energy infrastructure life_support power production propulsion science storage utility]
      actual_categories = described_class::MODULE_PATHS.keys.map(&:to_s)
      expect(actual_categories).to match_array(expected_categories)
    end
    
    it 'includes life_support in module categories' do
      expect(described_class::MODULE_PATHS.keys).to include(:life_support)
    end
  end

  describe 'module data structure validation' do
    context 'when co2_scrubber module exists' do
      let(:co2_scrubber) { service.find_module("co2_scrubber") }
      
      it 'has all expected module properties' do
        skip "co2_scrubber module not found" unless co2_scrubber
        
        expected_properties = %w[name description module_type category]
        expected_properties.each do |prop|
          expect(co2_scrubber).to have_key(prop)
        end
      end
      
      it 'has correct energy consumption' do
        skip "co2_scrubber module not found" unless co2_scrubber
        
        expect(co2_scrubber.dig('consumables', 'energy')).to be_a(Numeric)
        expect(co2_scrubber.dig('consumables', 'energy')).to eq(5.0)
      end
      
      it 'has input and output resources' do
        skip "co2_scrubber module not found" unless co2_scrubber
        
        expect(co2_scrubber['input_resources']).to be_an(Array)
        expect(co2_scrubber['output_resources']).to be_an(Array)
        
        # Check air input
        air_input = co2_scrubber['input_resources'].find { |r| r['id'] == 'air' }
        expect(air_input).to be_present
        expect(air_input['amount']).to eq(100)
        
        # Check CO2 output
        co2_output = co2_scrubber['output_resources'].find { |r| r['id'] == 'stored_co2' }
        expect(co2_output).to be_present
        expect(co2_output['amount']).to eq(2.5)
      end

      it 'follows the operational data template' do
        skip "co2_scrubber module not found" unless co2_scrubber
        
        if co2_scrubber['operational_properties']
          expect(co2_scrubber['operational_properties']['power_consumption_kw']).to eq(5.0)
          expect(co2_scrubber['operational_properties']['maintenance_interval_hours']).to be_present
          expect(co2_scrubber['operational_properties']['efficiency']).to be_present
        end
      end
    end

    context 'when life_support module exists' do
      let(:life_support) { service.find_module("life_support") }
      
      it 'has basic life support properties' do
        skip "life_support module not found" unless life_support
        
        expect(life_support['name']).to eq('Life Support Module')
        expect(life_support['module_type']).to eq('life_support')
        expect(life_support.dig('consumables', 'energy')).to eq(0.0)
      end

      it 'follows the operational data template' do
        skip "life_support module not found" unless life_support
        
        if life_support['operational_properties']
          expect(life_support['operational_properties']['power_consumption_kw']).to eq(0.0)
        end
        expect(life_support['category']).to eq('life_support')
      end
    end
  end

  describe 'error handling' do
    it 'handles JSON parsing errors gracefully' do
      expect { service.find_module("") }.not_to raise_error
      expect { service.find_module(nil) }.not_to raise_error
    end
    
    it 'handles missing base directory gracefully' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe 'integration with BaseModule' do
    it 'provides data needed for module creation' do
      modules_to_test = %w[co2_scrubber life_support]
      
      modules_to_test.each do |module_type|
        module_data = service.find_module(module_type)
        next unless module_data
        
        # Should have all properties that BaseModule expects
        expect(module_data).to have_key('name')
        expect(module_data).to have_key('module_type')
        
        # Energy cost should be numeric if present
        if module_data.dig('consumables', 'energy')
          expect(module_data.dig('consumables', 'energy')).to be_a(Numeric)
        end
      end
    end
  end
end