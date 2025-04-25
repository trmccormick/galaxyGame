require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Atmosphere, type: :model do
  # Simplified setup like geosphere
  let(:celestial_body) { create(:celestial_body, :minimal) }
  let(:atmosphere) { celestial_body.atmosphere }
  let(:material_lookup) { instance_double(Lookup::MaterialLookupService) }

  # Test composition data
  let(:atmosphere_composition) do
    {
      "CO2" => { "percentage" => 95.32 },
      "N2" => { "percentage" => 2.7 },
      "Ar" => { "percentage" => 1.6 }
    }
  end

  before do
    allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
    allow(material_lookup).to receive(:find_material).and_return({
      'properties' => {
        'state_at_room_temp' => 'gas',
        'molar_mass' => 44.01
      }
    })
  end

  describe 'initialization' do
    it 'creates an atmosphere with default attributes' do
      expect(atmosphere).to be_valid
      expect(atmosphere.temperature).to eq(celestial_body.surface_temperature)
      expect(atmosphere.pressure).to eq(0)
      expect(atmosphere.total_atmospheric_mass).to eq(0)
      expect(atmosphere.composition).to eq({})
    end

    it 'updates atmosphere with provided information' do
      atmosphere.update!(
        composition: {
          "CO2" => 95.32,
          "N2" => 2.7,
          "Ar" => 1.6
        },
        pressure: 0.006,
        total_atmospheric_mass: 2.5e16
      )
    
      expect(atmosphere.composition["CO2"]).to eq(95.32)
      expect(atmosphere.composition["N2"]).to eq(2.7)
      expect(atmosphere.composition["Ar"]).to eq(1.6)
      expect(atmosphere.pressure).to eq(0.006)
      expect(atmosphere.total_atmospheric_mass).to eq(2.5e16)
    end
  end

  describe '#initialize_gases' do
    before do
      # Set up the atmosphere composition
      atmosphere.update!(
        temperature: celestial_body.surface_temperature,
        pressure: 0.006,
        total_atmospheric_mass: 2.5e16,
        composition: {
          "CO2" => 95.32,
          "N2" => 2.7,
          "Ar" => 1.6
        }
      )
      
      # Set up gas-specific material data
      co2_data = {'properties' => {'molar_mass' => 44.01}}
      n2_data = {'properties' => {'molar_mass' => 28.01}}
      ar_data = {'properties' => {'molar_mass' => 39.95}}
      
      # Return different data based on the gas
      allow(material_lookup).to receive(:find_material).with("CO2").and_return(co2_data)
      allow(material_lookup).to receive(:find_material).with("N2").and_return(n2_data)
      allow(material_lookup).to receive(:find_material).with("Ar").and_return(ar_data)
      
      # Initialize the gases
      atmosphere.initialize_gases
    end

    it 'creates gases based on the composition' do
      gases = atmosphere.gases
      
      # Check the gases count matches the composition keys
      expect(gases.count).to eq(3)
      
      # Validate the CO2
      co2 = gases.find_by(name: "CO2")
      expect(co2).to be_present
      expect(co2.percentage).to be_within(0.1).of(95.32)
      expect(co2.mass).to be_within(1e13).of(2.383e16)
      
      # Validate the N2
      n2 = gases.find_by(name: "N2")
      expect(n2).to be_present
      expect(n2.percentage).to be_within(0.1).of(2.7)
    end
  end

  describe '#add_gas' do
    it 'adds a gas and updates total atmospheric mass' do
      # Mock gas lookup data
      allow(material_lookup).to receive(:find_material).with("O2").and_return({
        'properties' => {'molar_mass' => 32.0}
      })
      
      # Initial state
      initial_mass = atmosphere.total_atmospheric_mass
      
      # Add gas
      atmosphere.add_gas("O2", 100.0)
      
      # Verify gas was added
      o2 = atmosphere.gases.find_by(name: "O2")
      expect(o2).to be_present
      expect(o2.mass).to eq(100.0)
      
      # Check total mass was updated
      expect(atmosphere.total_atmospheric_mass).to eq(initial_mass + 100.0)
    end
  end

  describe '#remove_gas' do
    before do
      # Set up atmosphere with gases
      allow(material_lookup).to receive(:find_material).with("CO2").and_return({
        'properties' => {'molar_mass' => 44.01}
      })
      
      atmosphere.update!(
        total_atmospheric_mass: 100.0,
        pressure: 0.001
      )
      
      # Create a gas directly
      atmosphere.gases.create!(
        name: "CO2",
        percentage: 100.0,
        mass: 100.0,
        molar_mass: 44.01
      )
    end
    
    it 'removes gas and updates total atmospheric mass' do
      # Check initial state
      expect(atmosphere.gases.count).to eq(1)
      expect(atmosphere.total_atmospheric_mass).to eq(100.0)
      
      # Remove part of the gas
      atmosphere.remove_gas("CO2", 30.0)
      
      # Check gas was updated
      co2 = atmosphere.gases.find_by(name: "CO2")
      expect(co2.mass).to eq(70.0)
      
      # Check total mass was updated
      expect(atmosphere.total_atmospheric_mass).to eq(70.0)
    end
  end
end

