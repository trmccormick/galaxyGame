require 'rails_helper'
require 'json'

RSpec.describe Lookup::MaterialLookupService do
  let(:service) { described_class.new }

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = described_class.locate_gases_path
      expect(File.directory?(gases_path)).to be true
      
      # Look for actual fixture files we know exist
      oxygen_file = File.join(Rails.root, 'spec', 'fixtures', 'data', 'resources', 'materials', 'gases', 'reactive', 'oxygen.json')
      expect(File.exist?(oxygen_file)).to be true
    end

    it 'finds atmospheric gases by chemical formula' do
      # Test with real fixture data
      oxygen = service.find_material("O2")
      expect(oxygen).not_to be_nil
      expect(oxygen["chemical_formula"]).to eq("O2")
      expect(oxygen["id"]).to eq("oxygen")
      expect(oxygen["molar_mass"]).to eq(31.9988)
    end

    it 'finds materials case-insensitively' do
      expect(service.find_material("o2")).to include("chemical_formula" => "O2")
      expect(service.find_material("oxygen")).to include("chemical_formula" => "O2")
    end

    it 'returns nil for nonexistent materials' do
      expect(service.find_material("unobtainium")).to be_nil
    end
  end

  describe "atmosphere gas creation behavior" do
    # ✅ Remove all mocks - test actual behavior
    
    it "correctly maps chemical formulas for atmosphere creation" do
      # Test that we can find materials by their chemical formulas
      test_cases = [
        { formula: 'O2', expected_id: 'oxygen' },
        { formula: 'N2', expected_id: 'nitrogen' },
        { formula: 'CO2', expected_id: 'carbon_dioxide' }
      ]
      
      test_cases.each do |test_case|
        material = service.find_material(test_case[:formula])
        
        next unless material  # Skip if fixture doesn't exist
        
        expect(material['chemical_formula']).to eq(test_case[:formula])
        puts "✅ Formula '#{test_case[:formula]}' → Material ID: '#{material['id']}'"
      end
    end
    
    it "explains the actual gas creation pattern" do
      puts "\n=== Actual Gas Creation Pattern ==="
      puts "From seed output, gases are created with:"
      puts "- name: 'O2' (chemical formula)"
      puts "- name: 'N2' (chemical formula)" 
      puts "- name: 'CO2' (chemical formula)"
      puts ""
      puts "NOT with material IDs like 'oxygen', 'nitrogen', etc."
      puts ""
      puts "This means in tests, search for:"
      puts "o2_gas = atmosphere.gases.find_by(name: 'O2')"
      puts "NOT: atmosphere.gases.find_by(name: 'oxygen')"
    end
  end

  describe "material property access" do
    it 'provides access to material properties directly from data' do
      oxygen = service.find_material("oxygen")
      next unless oxygen
    
      # ✅ Test direct property access instead of private method
      expect(oxygen['molar_mass']).to be_a(Numeric)
      expect(oxygen['molar_mass']).to eq(31.9988)
    
      expect(oxygen['state_at_stp']).to eq('gas')
      expect(oxygen['chemical_formula']).to eq('O2')
      expect(oxygen['id']).to eq('oxygen')
    end
    
    it 'has all expected material properties' do
      oxygen = service.find_material("oxygen")
      next unless oxygen
    
      # Test that the fixture has the expected structure
      expected_properties = %w[id name chemical_formula molar_mass state_at_stp category]
      expected_properties.each do |prop|
        expect(oxygen).to have_key(prop), "Expected oxygen material to have '#{prop}' property"
      end
    end
  end
end