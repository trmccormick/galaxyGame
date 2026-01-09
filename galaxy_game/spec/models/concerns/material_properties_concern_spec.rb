# spec/models/concerns/material_properties_concern_spec.rb
require 'rails_helper'

RSpec.describe MaterialPropertiesConcern do
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new(ApplicationRecord) do
      include MaterialPropertiesConcern
      
      # Mock the table name
      def self.table_name
        'gases'
      end
      
      # Add accessor for molar_mass
      attr_accessor :molar_mass, :name
    end
  end
  
  let(:instance) { test_class.new(name: 'Oxygen') }
  
  describe '#properties' do
    it 'fetches material properties from lookup service' do
      material_lookup = instance_double(Lookup::MaterialLookupService)
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
      allow(material_lookup).to receive(:find_material).with('Oxygen').and_return({
        'properties' => {'molar_mass' => 32.0}
      })
      
      properties = instance.properties
      expect(properties).to include('properties')
      expect(properties['properties']).to include('molar_mass')
    end
  end
  
  describe '#molar_mass_from_properties' do
    it 'returns molar mass from nested properties' do
      allow(instance).to receive(:properties).and_return({
        'properties' => {'molar_mass' => 32.0}
      })
      
      expect(instance.molar_mass_from_properties).to eq(32.0)
    end
    
    it 'returns molar mass from top level if nested not available' do
      allow(instance).to receive(:properties).and_return({
        'molar_mass' => 32.0
      })
      
      expect(instance.molar_mass_from_properties).to eq(32.0)
    end
    
    it 'returns nil if molar mass not found' do
      allow(instance).to receive(:properties).and_return({})
      
      expect(instance.molar_mass_from_properties).to be_nil
    end
  end
  
  describe '#set_molar_mass_from_material' do
    it 'sets molar_mass from properties if blank' do
      # Mock the lookup service response
      allow(instance).to receive(:properties).and_return({
        'properties' => {'molar_mass' => 32.0}
      })
      
      instance.set_molar_mass_from_material
      expect(instance.molar_mass).to eq(32.0)
    end
    
    it 'does not override existing molar_mass' do
      instance.molar_mass = 33.0
      allow(instance).to receive(:properties).and_return({
        'properties' => {'molar_mass' => 32.0}
      })
      
      instance.set_molar_mass_from_material
      expect(instance.molar_mass).to eq(33.0)
    end
  end
  
  describe '#state_at' do
    before do
      allow(instance).to receive(:properties).and_return({
        'properties' => {
          'melting_point' => 54.8,  # Oxygen melting point in K
          'boiling_point' => 90.2   # Oxygen boiling point in K
        }
      })
    end
    
    it 'returns solid state when temperature is below melting point' do
      expect(instance.state_at(50.0)).to eq('solid')
    end
    
    it 'returns liquid state when temperature is between melting and boiling points' do
      expect(instance.state_at(70.0)).to eq('liquid')
    end
    
    it 'returns gas state when temperature is above boiling point' do
      expect(instance.state_at(100.0)).to eq('gas')
    end
    
    it 'returns default state when temperature is nil' do
      allow(instance).to receive(:default_state).and_return('gas')
      expect(instance.state_at(nil)).to eq('gas')
    end
    
    it 'uses default values when melting/boiling points are missing' do
      allow(instance).to receive(:properties).and_return({})
      expect(instance.state_at(250.0)).to eq('solid')      # Below default 273.15K
      expect(instance.state_at(300.0)).to eq('liquid')     # Between default 273.15K and 373.15K
      expect(instance.state_at(400.0)).to eq('gas')        # Above default 373.15K
    end
  end
  
  describe 'state helper methods' do
    before do
      allow(instance).to receive(:properties).and_return({
        'properties' => {
          'melting_point' => 54.8,
          'boiling_point' => 90.2,
          'state_at_room_temp' => 'gas'
        }
      })
    end
    
    describe '#solid?' do
      it 'returns true when temperature is below melting point' do
        expect(instance.solid?(50.0)).to be true
      end
      
      it 'returns false when temperature is above melting point' do
        expect(instance.solid?(60.0)).to be false
      end
      
      it 'returns true when default state is solid and no temperature given' do
        allow(instance).to receive(:default_state).and_return('solid')
        expect(instance.solid?).to be true
      end
    end
    
    describe '#liquid?' do
      it 'returns true when temperature is between melting and boiling points' do
        expect(instance.liquid?(70.0)).to be true
      end
      
      it 'returns false when temperature is below melting point or above boiling point' do
        expect(instance.liquid?(50.0)).to be false
        expect(instance.liquid?(100.0)).to be false
      end
      
      it 'returns true when default state is liquid and no temperature given' do
        allow(instance).to receive(:default_state).and_return('liquid')
        expect(instance.liquid?).to be true
      end
    end
    
    describe '#gas?' do
      it 'returns true when temperature is above boiling point' do
        expect(instance.gas?(100.0)).to be true
      end
      
      it 'returns false when temperature is below boiling point' do
        expect(instance.gas?(80.0)).to be false
      end
      
      it 'returns true when default state is gas and no temperature given' do
        allow(instance).to receive(:default_state).and_return('gas')
        expect(instance.gas?).to be true
      end
    end
  end
  
  describe '#default_state' do
    it 'returns state_at_room_temp from properties if available' do
      allow(instance).to receive(:properties).and_return({
        'properties' => {'state_at_room_temp' => 'gas'}
      })
      
      expect(instance.send(:default_state)).to eq('gas')
    end
    
    it 'returns solid if state_at_room_temp not available' do
      allow(instance).to receive(:properties).and_return({})
      
      expect(instance.send(:default_state)).to eq('solid')
    end
  end

  describe "exotic state handling" do
    let(:test_class) do
      Class.new(ApplicationRecord) do
        include MaterialPropertiesConcern
        
        def self.table_name
          'geological_materials'
        end
        
        attr_accessor :state, :name
      end
    end
    
    it "identifies exotic states" do
      material = test_class.new(state: 'solid')
      expect(material.exotic_state?).to be false
      
      material.state = 'metallic_hydrogen'
      expect(material.exotic_state?).to be true
      
      material.state = 'plasma'
      expect(material.exotic_state?).to be true
      
      material.state = 'superfluid'
      expect(material.exotic_state?).to be true
    end
    
    it "calculates phase transitions for exotic conditions" do
      # Regular phase transition
      material = test_class.new(name: 'Iron')
      allow(material).to receive(:properties).and_return({
        'properties' => {
          'melting_point' => 1811,
          'boiling_point' => 3134
        }
      })
      
      expect(material.state_at(2000)).to eq('liquid')
      
      # Hydrogen at extreme pressure
      hydrogen = test_class.new(name: 'Hydrogen')
      allow(hydrogen).to receive(:properties).and_return({
        'properties' => {
          'melting_point' => 14.01,
          'boiling_point' => 20.28
        }
      })
      
      expect(hydrogen.state_at(300, 1_500_000)).to eq('metallic_hydrogen')
      
      # Material at extreme temperature
      oxygen = test_class.new(name: 'Oxygen')
      allow(oxygen).to receive(:properties).and_return({
        'properties' => {
          'melting_point' => 54.36,
          'boiling_point' => 90.19
        }
      })
      
      expect(oxygen.state_at(12000)).to eq('plasma')
    end
  end
end