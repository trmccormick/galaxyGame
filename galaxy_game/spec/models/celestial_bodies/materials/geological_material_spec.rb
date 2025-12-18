# spec/models/celestial_bodies/materials/geological_material_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Materials::GeologicalMaterial, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  
  it "uses the geological_materials table" do
    expect(described_class.table_name).to eq('geological_materials')
  end
  
  describe "associations" do
    it "belongs to geosphere" do
      association = described_class.reflect_on_association(:geosphere)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('CelestialBodies::Spheres::Geosphere')
    end
    
    it "can be accessed through geosphere.geological_materials" do
      # Explicitly create using the new class
      material = CelestialBodies::Materials::GeologicalMaterial.create!(
        name: "Silicon", 
        percentage: 25.0,
        geosphere: celestial_body.geosphere,
        layer: "crust",
        mass: 100,
        state: "solid"
      )
      
      # Force a reload
      celestial_body.geosphere.reload
      
      # Check if it exists
      expect(celestial_body.geosphere.geological_materials.exists?(name: "Silicon")).to be true
    end
  end
  
  describe "validations" do
    it "is not valid without a name" do
      material = celestial_body.geosphere.geological_materials.build(
        percentage: 25.0, layer: "crust", mass: 100, state: "solid"
      )
      expect(material).not_to be_valid
    end
    
    it "is not valid with an invalid layer" do
      material = celestial_body.geosphere.geological_materials.build(
        name: "Silicon", percentage: 25.0, layer: "invalid", mass: 100, state: "solid"
      )
      expect(material).not_to be_valid
    end
    
    it "is not valid with a negative percentage" do
      material = celestial_body.geosphere.geological_materials.build(
        name: "Silicon", percentage: -1.0, layer: "crust", mass: 100, state: "solid"
      )
      expect(material).not_to be_valid
    end
    
    it "is not valid with a percentage over 100" do
      material = celestial_body.geosphere.geological_materials.build(
        name: "Silicon", percentage: 101.0, layer: "crust", mass: 100, state: "solid"
      )
      expect(material).not_to be_valid
    end
    
    it "is not valid with a negative mass" do
      material = celestial_body.geosphere.geological_materials.build(
        name: "Silicon", percentage: 25.0, layer: "crust", mass: -1, state: "solid"
      )
      expect(material).not_to be_valid
    end
    
    it "is not valid with an invalid state" do
      material = celestial_body.geosphere.geological_materials.build(
        name: "Silicon", percentage: 25.0, layer: "crust", mass: 100, state: "invalid"
      )
      expect(material).not_to be_valid
    end
  end
  
  describe "state helper methods" do
    let(:material) { CelestialBodies::Materials::GeologicalMaterial.new(state: "solid") }
    
    it "returns true for solid? when state is 'solid'" do
      expect(material.solid?).to be true
      expect(material.liquid?).to be false
      expect(material.gas?).to be false
    end
    
    it "returns true for liquid? when state is 'liquid'" do
      material.state = "liquid"
      expect(material.solid?).to be false
      expect(material.liquid?).to be true
      expect(material.gas?).to be false
    end
    
    it "returns true for gas? when state is 'gas'" do
      material.state = "gas"
      expect(material.solid?).to be false
      expect(material.liquid?).to be false
      expect(material.gas?).to be true
    end
  end

  describe "exotic state handling" do
    let(:geosphere) { create(:celestial_body).geosphere }
    let(:exotic_material) { 
      CelestialBodies::Materials::GeologicalMaterial.new(
        name: 'Hydrogen',
        state: 'metallic_hydrogen',
        layer: 'core',
        mass: 1000,
        percentage: 10,
        geosphere: geosphere
      )
    }
    
    it "correctly reports state for exotic materials" do
      expect(exotic_material.solid?).to be false
      expect(exotic_material.liquid?).to be false
      expect(exotic_material.gas?).to be false
      expect(exotic_material.exotic_state?).to be true
    end
    
    it "handles metallic hydrogen specifically" do
      expect(exotic_material.metallic_hydrogen?).to be true
      expect(exotic_material.plasma?).to be false
    end
    
    it "handles plasma state" do
      exotic_material.state = 'plasma'
      expect(exotic_material.plasma?).to be true
      expect(exotic_material.metallic_hydrogen?).to be false
    end
  end
end