require 'rails_helper'

RSpec.describe AtmosphereConcern do
  # Use the actual Atmosphere model that includes the concern
  let(:celestial_body) { create(:celestial_body) }
  let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }
  
  # Use real services with proper formatters mocked
  before do
    # Mock the lookup service to return known molar masses
    lookup_service = instance_double("Lookup::MaterialLookupService")
    allow(Lookup::MaterialLookupService).to receive(:new).and_return(lookup_service)
    
    # Mock different responses for different gases
    allow(lookup_service).to receive(:find_material).with('CO2').and_return({
      'properties' => { 'molar_mass' => 44.01 }
    })
    allow(lookup_service).to receive(:find_material).with('N2').and_return({
      'properties' => { 'molar_mass' => 28.01 }
    })
    allow(lookup_service).to receive(:find_material).with('O2').and_return({
      'properties' => { 'molar_mass' => 32.0 }
    })
    allow(lookup_service).to receive(:find_material).with('H2').and_return({
      'properties' => { 'molar_mass' => 2.02 }
    })
    allow(lookup_service).to receive(:find_material).with('Test Gas').and_return({
      'properties' => { 'molar_mass' => 28.0 }
    })
    # Default response for any other gas
    allow(lookup_service).to receive(:find_material).and_return({
      'properties' => { 'molar_mass' => 29.0 }
    })
    
    # Mock GameFormatters to avoid display formatting issues
    allow(GameFormatters::AtmosphericData).to receive(:format_mass).and_return("100 kg")
    allow(GameFormatters::AtmosphericData).to receive(:format_pressure).and_return("1.0 atm")
    allow(GameFormatters::AtmosphericData).to receive(:format_ratio).and_return("+10%")
    
    # Stop puts statements from polluting test output
    allow_any_instance_of(Object).to receive(:puts)
    
    # Mock logger calls to avoid noise
    allow(Rails.logger).to receive(:debug)
    allow(Rails.logger).to receive(:warn)
  end
  
  describe '#reset' do
    it 'restores atmosphere to base values' do
      # Set up base values
      atmosphere.base_values = {
        'composition' => {'CO2' => 95.0, 'N2' => 5.0},
        'total_atmospheric_mass' => 1000,
        'dust' => {'concentration' => 0.1}
      }
      atmosphere.save!
      
      # Add some existing gases to be destroyed - with molar_mass
      atmosphere.gases.create!(
        name: 'Test Gas', 
        percentage: 100, 
        mass: 500,
        molar_mass: 28.0
      )
      
      # Reset the atmosphere
      atmosphere.reset
      
      # Check that values were restored
      expect(atmosphere.composition).to eq({'CO2' => 95.0, 'N2' => 5.0})
      expect(atmosphere.total_atmospheric_mass).to eq(1000)
      expect(atmosphere.dust).to eq({'concentration' => 0.1})
    end
    
    it 'does nothing when base_values is empty' do
      atmosphere.base_values = {}
      atmosphere.save!
      
      # Should not fail
      expect { atmosphere.reset }.not_to raise_error
    end
  end
  
  describe '#calculate_pressure' do
    it 'calculates atmospheric pressure' do
      # Setup the celestial body with realistic values
      allow(celestial_body).to receive(:gravity).and_return(9.8)
      allow(celestial_body).to receive(:radius).and_return(6371000)
      allow(celestial_body).to receive(:name).and_return("Earth")
      
      # Set a realistic atmospheric mass for Earth
      atmosphere.total_atmospheric_mass = 5.0e18
      atmosphere.save!
      
      pressure = atmosphere.calculate_pressure
      # Rough approximation of Earth's pressure in atm
      expect(pressure).to be_within(0.2).of(1.0)
    end
    
    it 'returns 0 for zero mass' do
      atmosphere.total_atmospheric_mass = 0
      atmosphere.save!
      
      expect(atmosphere.calculate_pressure).to eq(0)
    end
  end
  
  describe '#add_gas' do
    it 'adds a new gas to the atmosphere' do
      # Start with empty atmosphere
      expect(atmosphere.gases.count).to eq(0)
      
      # Add a gas
      gas = atmosphere.add_gas('N2', 1000)
      
      # Should have created a gas record
      expect(atmosphere.gases.count).to eq(1)
      expect(gas.name).to eq('N2')
      expect(gas.mass).to eq(1000)
      
      # Should have updated total mass
      expect(atmosphere.reload.total_atmospheric_mass).to eq(1000)
    end
    
    it 'updates existing gas' do
      # Create an existing gas with molar_mass
      existing_gas = atmosphere.gases.create!(
        name: 'O2', 
        percentage: 100, 
        mass: 500,
        molar_mass: 32.0
      )
      
      atmosphere.update!(total_atmospheric_mass: 500)
      
      # Add more of the same gas
      atmosphere.add_gas('O2', 500)
      
      # Check the gas was updated
      existing_gas.reload
      expect(existing_gas.mass).to eq(1000)
      
      # And total mass updated
      expect(atmosphere.reload.total_atmospheric_mass).to eq(1000)
    end
    
    it 'raises error for invalid gas' do
      expect { atmosphere.add_gas('', 100) }.to raise_error(AtmosphereConcern::InvalidGasError)
      expect { atmosphere.add_gas('O2', -100) }.to raise_error(AtmosphereConcern::InvalidGasError)
    end
  end
  
  describe '#remove_gas' do
    it 'removes gas from the atmosphere' do
      # Create a gas to remove with molar_mass
      atmosphere.gases.create!(
        name: 'O2', 
        percentage: 100, 
        mass: 1000,
        molar_mass: 32.0
      )
      
      atmosphere.update!(total_atmospheric_mass: 1000)
      
      # Remove some of the gas
      atmosphere.remove_gas('O2', 600)
      
      # Should have reduced the gas amount
      expect(atmosphere.gases.first.mass).to eq(400)
      
      # And reduced the total mass
      expect(atmosphere.reload.total_atmospheric_mass).to eq(400)
    end
    
    it 'deletes gas when amount becomes zero' do
      # Create a gas to remove completely with molar_mass
      atmosphere.gases.create!(
        name: 'H2', 
        percentage: 100, 
        mass: 10,
        molar_mass: 2.02
      )
      
      atmosphere.update!(total_atmospheric_mass: 10)
      
      # Remove all of it
      atmosphere.remove_gas('H2', 10)
      
      # Gas should be gone
      expect(atmosphere.gases.where(name: 'H2').exists?).to be_falsey
      
      # Total mass should be zero
      expect(atmosphere.reload.total_atmospheric_mass).to eq(0)
    end
    
    it 'raises error when removing non-existent gas' do
      expect { atmosphere.remove_gas('XenonPlus', 100) }.to raise_error(AtmosphereConcern::InvalidGasError)
    end
    
    it 'raises error when removing more than exists' do
      # Create gas with molar_mass
      atmosphere.gases.create!(
        name: 'N2', 
        percentage: 100, 
        mass: 50,
        molar_mass: 28.01
      )
      
      expect { atmosphere.remove_gas('N2', 100) }.to raise_error(AtmosphereConcern::InvalidGasError)
    end
  end
  
  describe '#set_default_values' do
    it 'sets initial values for a new atmosphere' do
      # Important: Create a new atmosphere WITHOUT a temperature value
      new_atmosphere = build(:atmosphere, celestial_body: celestial_body, temperature: nil)
      
      # Stub celestial body values
      allow(celestial_body).to receive(:surface_temperature).and_return(288)
      allow(celestial_body).to receive(:known_pressure).and_return(1.0)
      
      # Save to trigger the callback
      new_atmosphere.save!
      
      # Check default values were set
      expect(new_atmosphere.temperature).to eq(288)
      expect(new_atmosphere.composition).to eq({})
      expect(new_atmosphere.dust).to eq({})
      expect(new_atmosphere.pollution).to eq(0)
    end
  end
end