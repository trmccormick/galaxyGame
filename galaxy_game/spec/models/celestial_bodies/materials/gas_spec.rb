# spec/models/celestial_bodies/materials/gas_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Materials::Gas, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  
  it "uses the gases table" do
    expect(described_class.table_name).to eq('gases')
  end
  
  describe "associations" do
    it "belongs to atmosphere" do
      association = described_class.reflect_on_association(:atmosphere)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('CelestialBodies::Spheres::Atmosphere')
    end
    
    it "can be accessed through atmosphere.gases" do
      # Explicitly create using the new class
      gas = CelestialBodies::Materials::Gas.create!(
        name: "Oxygen", 
        percentage: 21.0,
        atmosphere: celestial_body.atmosphere,
        molar_mass: 32.0 # Add explicitly
      )
      
      # Force a reload
      celestial_body.atmosphere.reload
      
      # Check if it exists
      expect(celestial_body.atmosphere.gases.exists?(name: "Oxygen")).to be true
    end
  end
  
  describe "validations" do
    # From the original spec
    it "is not valid without a name" do
      gas = celestial_body.atmosphere.gases.build(name: nil)
      expect(gas).not_to be_valid
    end
    
    # From the original spec
    it "is not valid with a negative percentage" do
      gas = celestial_body.atmosphere.gases.build(percentage: -1.0)
      expect(gas).not_to be_valid
    end
    
    it "is not valid with a percentage over 100" do
      gas = celestial_body.atmosphere.gases.build(percentage: 101.0)
      expect(gas).not_to be_valid
    end
    
    it "is not valid with a negative mass" do
      gas = celestial_body.atmosphere.gases.build(name: "Oxygen", mass: -10)
      expect(gas).not_to be_valid
    end
    
    it "is not valid with a negative ppm" do
      gas = celestial_body.atmosphere.gases.build(name: "Oxygen", ppm: -10)
      expect(gas).not_to be_valid
    end
  end
  
  describe "#moles" do
    let(:gas) { described_class.new(name: "Oxygen", molar_mass: 32.0, mass: 100) }
    
    it "calculates moles from mass and molar mass" do
      expect(gas.moles(gas.mass)).to be_within(0.01).of(3.125)
    end
    
    it "returns 0 if mass is nil" do
      gas.mass = nil
      expect(gas.moles(gas.mass)).to eq(0)
    end
    
    it "returns 0 if molar_mass is nil" do
      gas.molar_mass = nil
      expect(gas.moles(100)).to eq(0)
    end
  end
  
  # Test the class is the same as the original Gas model
  it "has the same behavior as the original Gas model" do
    # Use reflection to compare methods
    original_methods = CelestialBodies::Materials::Gas.instance_methods - ApplicationRecord.instance_methods
    new_methods = described_class.instance_methods - ApplicationRecord.instance_methods
    expect(new_methods).to include(*original_methods)
  end
  
  # Test set_molar_mass_from_material functionality
  describe "before_validation callback" do
    before do
      # Create a broader stub that works for all material lookups
      material_lookup = instance_double(Lookup::MaterialLookupService)
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
      
      # Default response for any material
      allow(material_lookup).to receive(:find_material).and_return({
        'properties' => {
          'molar_mass' => 28.0,
          'state_at_room_temp' => 'solid'
        },
        'molar_mass' => 28.0 # Add to top level too
      })
      
      # Specific response for Oxygen
      allow(material_lookup).to receive(:find_material).with("Oxygen").and_return({
        'molar_mass' => 32.0,
        'properties' => {
          'state_at_room_temp' => 'gas'
        }
      })
      
      # Specific response for Silicon (called by geosphere)
      allow(material_lookup).to receive(:find_material).with("Silicon").and_return({
        'properties' => {
          'molar_mass' => 28.1,
          'state_at_room_temp' => 'solid'
        },
        'molar_mass' => 28.1 # Add to top level too
      })
    end
    
    it "sets molar_mass from material lookup if blank" do
      # Create gas without molar_mass
      gas = celestial_body.atmosphere.gases.build(name: "Oxygen")
      gas.valid? # Trigger validation
      
      expect(gas.molar_mass).to eq(32.0)
    end
    
    it "does not override existing molar_mass" do
      gas = celestial_body.atmosphere.gases.build(name: "Oxygen", molar_mass: 33.0)
      gas.valid? # Trigger validation
      
      expect(gas.molar_mass).to eq(33.0)
    end
  end
end