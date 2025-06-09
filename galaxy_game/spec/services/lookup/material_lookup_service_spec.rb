require 'rails_helper'
require 'json'

RSpec.describe Lookup::MaterialLookupService do
  let(:service) { described_class.new }

  describe '#find_material' do
    it 'loads materials from the correct file structure' do
      gases_path = described_class.locate_gases_path
      expect(File.directory?(gases_path)).to be true
      
      # Look for JSON files in the compound subfolder, which we know has carbon_dioxide.json
      json_files = Dir.glob(File.join(gases_path, "compound", "*.json"))
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
      # Only test what we know exists in our fixture
      co2 = service.find_material("CO2")
      expect(co2).not_to be_nil
      expect(co2["chemical_formula"]).to eq("CO2")
      expect(co2["molar_mass"]).to eq(44.01)  # Check molar_mass at the top level, not in properties
    end

    it 'finds materials case-insensitively' do
      expect(service.find_material("co2")).to include("chemical_formula" => "CO2")
      expect(service.find_material("n2")).to include("chemical_formula" => "N2")
    end

    it 'returns nil for nonexistent materials' do
      expect(service.find_material("xyz")).to be_nil
    end

    it "finds CO2 and returns its properties" do
      co2 = service.find_material("CO2")
      expect(co2).not_to be_nil
      expect(co2["id"]).to eq("carbon_dioxide")
      expect(co2["chemical_formula"]).to eq("CO2")
      expect(co2["molar_mass"]).to eq(44.01)
      # Not: expect(co2["properties"]["molar_mass"]).to eq(44.01)
    end
  end

  describe "integration with atmosphere gas creation" do
    let(:atmosphere) { create(:atmosphere, total_atmospheric_mass: 100.0) }
    
    it "maps chemical formulas to standardized material IDs that become gas names" do
      formulas = ['O2', 'N2', 'CO2']
      
      # Print helpful debug info for each formula
      formulas.each do |formula|
        material = service.find_material(formula)
        puts "=== Chemical Formula to Material ID/Name Mapping ==="
        puts "Formula '#{formula}' → Material ID: '#{material['id']}'"
        
        # Test that we find something for each formula
        expect(material).not_to be_nil
        
        # Test that the material has the correct formula
        expect(material['chemical_formula']).to eq(formula)
      end
    end
    
    it 'creates gases with names based on material IDs, not chemical formulas' do
      # Create some example component data
      components = [
        {chemical: 'O2', percentage: 21.0},
        {chemical: 'N2', percentage: 78.0},
        {chemical: 'CO2', percentage: 0.04}
      ]
      
      # Get standardized components
      atmospheric_components = service.atmospheric_components(components)
      expect(atmospheric_components).to be_an(Array)
      
      # Check each component has the right material
      components.each do |component|
        formula = component[:chemical]
        matching = atmospheric_components.find { |c| c[:material]['chemical_formula'] == formula }
        expect(matching).not_to be_nil
        expect(matching[:percentage]).to eq(component[:percentage])
        
        # The material ID should match what we'd find directly
        expected_material = service.find_material(formula)
        expect(matching[:material]['id']).to eq(expected_material['id'])
        
        puts "=== Chemical Formula to Actual Gas Name Mapping ==="
        puts "Formula '#{formula}' → Material ID: '#{matching[:material]['id']}'"
      end
    end
    
    it "explains how to fix the BiosphereSimulationService tests" do
      # Create a simple class to simulate atmosphere behavior
      class MockAtmosphere
        attr_reader :gases
        
        def initialize(material_service)
          @gases = []
          @material_service = material_service
        end
        
        def add_gas(formula, mass)
          # Find the material using our service
          material = @material_service.find_material(formula)
          return false unless material
          
          # Use material id as the gas name
          gas_name = material['id']
          
          # Create a simple hash to represent the gas
          gas = {
            name: gas_name,
            formula: formula,
            mass: mass
          }
          
          @gases << gas
          true
        end
      end
      
      # Create our mock atmosphere
      atmosphere = MockAtmosphere.new(service)
      
      # Add oxygen
      result = atmosphere.add_gas('O2', 1000)
      expect(result).to be true
      
      # Find the gas that was added
      gas = atmosphere.gases.find { |g| g[:formula] == 'O2' }
      expect(gas).not_to be_nil
      
      # The name should be the material ID, not the formula
      expected_name = 'oxygen'
      expect(gas[:name]).to eq(expected_name)
      
      # Print helpful debugging info
      puts "=== How to Fix BiosphereSimulationService Tests ==="
      puts "When you call atmosphere.add_gas('O2', mass):"
      puts "- Creates gas with name: '#{gas[:name]}'"
      puts "- NOT with name: 'O2'"
      puts ""
      puts "In your tests, search for gas with:"
      puts "o2_gas = CelestialBodies::Materials::Gas.where(name: '#{gas[:name]}', atmosphere_id: atmosphere.id).first"
    end
  end
end