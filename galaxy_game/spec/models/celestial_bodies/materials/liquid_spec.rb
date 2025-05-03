# spec/models/celestial_bodies/materials/liquid_spec.rb
require 'rails_helper'

RSpec.describe CelestialBodies::Materials::Liquid, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:hydrosphere) { celestial_body.hydrosphere }
  
  subject(:liquid_material) { described_class.new(name: 'Methane', amount: 500.0, hydrosphere: hydrosphere) }
  
  it "uses the liquid_materials table" do
    expect(described_class.table_name).to eq('liquid_materials')
  end
  
  describe 'associations' do
    it { is_expected.to belong_to(:hydrosphere) }
    
    it "associates with the correct class name" do
      association = described_class.reflect_on_association(:hydrosphere)
      expect(association.macro).to eq(:belongs_to)
      expect(association.options[:class_name]).to eq('CelestialBodies::Spheres::Hydrosphere')
    end
    
    it "can be accessed through hydrosphere.liquid_materials" do
      # Explicitly create using the new class
      liquid = CelestialBodies::Materials::Liquid.create!(
        name: "Methane", 
        amount: 500.0,
        hydrosphere: hydrosphere
      )
      
      # Force a reload
      hydrosphere.reload
      
      # Check if it exists
      expect(hydrosphere.liquid_materials.exists?(name: "Methane")).to be true
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(liquid_material).to be_valid
    end

    it 'is not valid without a name' do
      liquid_material.name = nil
      expect(liquid_material).not_to be_valid
      expect(liquid_material.errors.messages[:name]).to include("can't be blank")
    end

    it 'is not valid without an amount' do
      liquid_material.amount = nil
      expect(liquid_material).not_to be_valid
    end

    it 'is not valid with a negative amount' do
      liquid_material.amount = -1.0
      expect(liquid_material).not_to be_valid
      expect(liquid_material.errors.messages[:amount]).to include('must be greater than or equal to 0')
    end
  end
end