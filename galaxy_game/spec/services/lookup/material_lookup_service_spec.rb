require 'rails_helper'
require 'json'

RSpec.describe Lookup::MaterialLookupService do
  let(:service) { described_class.new }

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = described_class.locate_gases_path
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

  describe "integration with atmosphere gas creation" do
    let(:atmosphere) { create(:atmosphere, total_atmospheric_mass: 100.0) }
    
    it "maps chemical formulas to standardized material IDs that become gas names" do
      formulas = ['O2', 'CO2', 'N2', 'CH4']
      formula_to_name_map = {}
      
      puts "\n=== Chemical Formula to Material ID/Name Mapping ==="
      formulas.each do |formula|
        material = service.find_material(formula)
        formula_to_name_map[formula] = material['id']
        
        puts "Formula '#{formula}' → Material ID: '#{material['id']}'"
        
        # Verify the material has the expected chemical formula
        expect(material['chemical_formula']).to eq(formula)
        
        # Verify the material ID is consistent
        expect(material['id']).to be_present
      end
      
      # Important test for the specific issue we're debugging
      o2_material = service.find_material('O2')
      expect(o2_material['id']).to eq('oxygen'), 
        "Expected O2 material ID to be 'oxygen', got '#{o2_material['id']}'"
    end
    
    it "creates gases with names based on material IDs, not chemical formulas" do
      formulas = ['O2', 'CO2', 'N2', 'CH4']
      
      puts "\n=== Chemical Formula to Actual Gas Name Mapping ==="
      formulas.each do |formula|
        # Clean up any existing gases
        atmosphere.gases.where("name LIKE ?", "%#{formula}%").destroy_all
        atmosphere.gases.where("name LIKE ?", "%#{formula.downcase}%").destroy_all
        
        # Look up the material
        material = service.find_material(formula)
        expected_name = material['id']
        
        # Add gas with the formula name
        gas = atmosphere.add_gas(formula, 1.0)
        
        # Report findings
        puts "add_gas('#{formula}') → Gas with name '#{gas.name}'"
        
        # Test that the gas name matches the material ID, not the formula
        expect(gas.name).to eq(expected_name), 
          "Expected gas name to be '#{expected_name}', got '#{gas.name}'"
          
        # Test that searching by formula doesn't work
        expect(atmosphere.gases.find_by(name: formula)).to be_nil,
          "Should NOT find gas with name '#{formula}'"
          
        # Test that searching by material ID does work
        expect(atmosphere.gases.find_by(name: expected_name)).to eq(gas),
          "Should find gas with name '#{expected_name}'"
      end
    end
    
    it "explains how to fix the BiosphereSimulationService tests" do
      # Clean up
      atmosphere.gases.destroy_all
      
      # Get the material info
      o2_material = service.find_material('O2')
      expected_name = o2_material['id']
      
      puts "\n=== How to Fix BiosphereSimulationService Tests ==="
      puts "When you call atmosphere.add_gas('O2', mass):"
      puts "- Creates gas with name: '#{expected_name}'"
      puts "- NOT with name: 'O2'"
      puts ""
      puts "In your tests, search for gas with:"
      puts "o2_gas = CelestialBodies::Materials::Gas.where(name: '#{expected_name}', atmosphere_id: atmosphere.id).first"
      
      # Demonstrate
      gas = atmosphere.add_gas('O2', 1.0)
      expect(gas.name).to eq(expected_name)
      expect(atmosphere.gases.find_by(name: 'O2')).to be_nil
      expect(atmosphere.gases.find_by(name: expected_name)).to be_present
    end
  end
end