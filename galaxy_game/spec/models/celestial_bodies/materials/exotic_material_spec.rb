# spec/models/celestial_bodies/materials/exotic_material_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Materials::ExoticMaterial, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:geosphere) { celestial_body.geosphere }
  
  subject(:exotic_material) { 
    described_class.new(
      name: 'Metallic Hydrogen', 
      state: 'metallic_hydrogen',
      geosphere: geosphere,
      rarity: 95,
      stability: 20,
      percentage: 10,
      mass: 1000
    ) 
  }
  
  it "uses the exotic_materials table" do
    expect(described_class.table_name).to eq('exotic_materials')
  end
  
  describe "associations" do
    it { is_expected.to belong_to(:geosphere) }
  end
  
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:rarity).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { is_expected.to validate_numericality_of(:stability).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  end
  
  describe "state helper methods" do
    it "identifies metallic hydrogen state" do
      expect(exotic_material.metallic_hydrogen?).to be true
      expect(exotic_material.solid?).to be false
      expect(exotic_material.liquid?).to be false
      expect(exotic_material.gas?).to be false
    end
    
    it "identifies plasma state" do
      exotic_material.state = 'plasma'
      expect(exotic_material.plasma?).to be true
      expect(exotic_material.metallic_hydrogen?).to be false
    end
  end
  
  describe "#phase_transition_at" do
    it "returns metallic_hydrogen for hydrogen at extreme pressure" do
      hydrogen = described_class.new(name: 'Hydrogen')
      expect(hydrogen.phase_transition_at(300, 1_500_000)).to eq('metallic_hydrogen')
    end
    
    it "returns plasma at extreme temperatures" do
      any_material = described_class.new(name: 'Oxygen')
      expect(any_material.phase_transition_at(15000, 1.0)).to eq('plasma')
    end
    
    it "returns superfluid for helium at low temperatures" do
      helium = described_class.new(name: 'Helium')
      expect(helium.phase_transition_at(2.0, 1.0)).to eq('superfluid')
    end
    
    it "falls back to standard states otherwise" do
      allow_any_instance_of(MaterialPropertiesConcern).to receive(:state_at).and_return('liquid')
      
      iron = described_class.new(name: 'Iron')
      expect(iron.phase_transition_at(1800, 1.0)).to eq('liquid')
    end
  end
end