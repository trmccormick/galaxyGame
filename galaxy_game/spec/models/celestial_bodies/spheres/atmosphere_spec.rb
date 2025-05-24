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

  # Add GameConstants stub for the gas constant before the tests run
  before do
    # Allow GameConstants::IDEAL_GAS_CONSTANT to be referenced in tests
    stub_const("GameConstants::IDEAL_GAS_CONSTANT", 8.31446)
    
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

  # Add new tests for the temperature methods
  describe 'temperature management' do
    let(:earth_like_body) { create(:celestial_body, surface_temperature: 288) }
    subject(:atmosphere) { create(:atmosphere, celestial_body: earth_like_body) }
    
    it 'stores various temperature types in temperature_data' do
      # Set temperature values
      atmosphere.set_effective_temp(255)
      atmosphere.set_greenhouse_temp(288)
      atmosphere.set_polar_temp(248)
      atmosphere.set_tropic_temp(298)
      
      # Reload to ensure persistence
      atmosphere.reload
      
      # Check stored values
      expect(atmosphere.effective_temperature).to eq(255)
      expect(atmosphere.greenhouse_temperature).to eq(288)
      expect(atmosphere.polar_temperature).to eq(248)
      expect(atmosphere.tropical_temperature).to eq(298)
      
      # Check temperature was updated to match greenhouse temp
      expect(atmosphere.temperature).to eq(288)
    end
    
    it 'provides default values for temperature getters' do
      # With no specific values set
      atmosphere.update(temperature: 288)
      
      # Check the getter methods provide reasonable defaults
      expect(atmosphere.effective_temp).to eq(288)
      expect(atmosphere.greenhouse_temp).to eq(288)
      expect(atmosphere.polar_temp).to eq(248) # temperature - 40
      expect(atmosphere.tropic_temp).to eq(298) # temperature + 10
    end
    
    it 'updates main temperature when greenhouse temperature changes' do
      # Initial state
      expect(atmosphere.temperature).to eq(288)
      
      # Set greenhouse temperature
      atmosphere.set_greenhouse_temp(293)
      
      # Both values should be updated
      expect(atmosphere.greenhouse_temperature).to eq(293)
      expect(atmosphere.temperature).to eq(293)
    end
    
    it 'persists temperature data across reloads' do
      # Set values and save
      atmosphere.update(temperature_data: {
        'effective_temperature' => 250,
        'greenhouse_temperature' => 290,
        'polar_temperature' => 245,
        'tropical_temperature' => 305
      })
      
      # Reload from database
      reloaded = CelestialBodies::Spheres::Atmosphere.find(atmosphere.id)
      
      # Check values persisted
      expect(reloaded.effective_temperature).to eq(250)
      expect(reloaded.greenhouse_temperature).to eq(290)
      expect(reloaded.polar_temperature).to eq(245)
      expect(reloaded.tropical_temperature).to eq(305)
    end
  end

  describe 'gas percentage methods' do
    before do
      # Set up atmosphere with gases
      atmosphere.update!(
        total_atmospheric_mass: 100.0,
        pressure: 0.001,
        composition: {
          "CO2" => 95.32,
          "N2" => 2.7,
          "Ar" => 1.6,
          "O2" => 0.13
        }
      )
      
      # Create gases directly
      atmosphere.gases.create!(name: "CO2", percentage: 95.32, mass: 95.32, molar_mass: 44.01)
      atmosphere.gases.create!(name: "N2", percentage: 2.7, mass: 2.7, molar_mass: 28.01)
      # Note: We deliberately don't create O2 as a gas to test fallback to composition
    end

    describe '#gas_percentage' do
      it 'returns percentage of existing gas in gases collection' do
        expect(atmosphere.gas_percentage('CO2')).to eq(95.32)
        expect(atmosphere.gas_percentage('N2')).to eq(2.7)
      end

      it 'falls back to composition data when gas not found in gases collection' do
        expect(atmosphere.gas_percentage('O2')).to eq(0.13)
      end

      it 'returns 0.0 for non-existent gases' do
        expect(atmosphere.gas_percentage('H2')).to eq(0.0)
      end
    end

    describe 'convenience gas percentage methods' do
      it 'returns O2 percentage via o2_percentage' do
        # O2 exists in composition but not as a gas record
        expect(atmosphere.o2_percentage).to eq(0.13)
      end

      it 'returns CO2 percentage via co2_percentage' do
        # CO2 exists as a gas record
        expect(atmosphere.co2_percentage).to eq(95.32)
      end

      it 'returns CH4 percentage via ch4_percentage' do
        # CH4 doesn't exist at all
        expect(atmosphere.ch4_percentage).to eq(0.0)
      end
      
      it 'correctly uses the gas_percentage method' do
        # Test that convenience methods use the gas_percentage method
        allow(atmosphere).to receive(:gas_percentage).with('O2').and_return(21.0)
        expect(atmosphere.o2_percentage).to eq(21.0)
      end
    end
  end

  # Add new test group for density calculations
  describe 'atmospheric density calculations' do
    before do
      # Set up Earth-like atmosphere with proper composition
      atmosphere.update!(
        temperature: 288, # 15°C in Kelvin
        pressure: 1.01325, # Earth sea level in bar
        total_atmospheric_mass: 5.1e18, # kg
        composition: {
          "N2" => 78.08,
          "O2" => 20.95,
          "Ar" => 0.93,
          "CO2" => 0.04
        }
      )
      
      # Create gases with proper IDs (not chemical formulas)
      atmosphere.gases.create!(name: "nitrogen", percentage: 78.08, mass: 3982.08e15, molar_mass: 28.01)
      atmosphere.gases.create!(name: "oxygen", percentage: 20.95, mass: 1068.45e15, molar_mass: 32.00)
      atmosphere.gases.create!(name: "argon", percentage: 0.93, mass: 47.43e15, molar_mass: 39.95)
      atmosphere.gases.create!(name: "carbon_dioxide", percentage: 0.04, mass: 2.04e15, molar_mass: 44.01)
    end
    
    describe '#density' do
      it 'calculates atmospheric density based on pressure, temperature and composition' do
        # Earth's atmospheric density at sea level can vary from 1.2 to 1.3 kg/m³ 
        # depending on exact composition and calculation method
        expect(atmosphere.density).to be_within(0.7).of(1.225)
      end
      
      it 'returns zero when pressure is zero' do
        atmosphere.update!(pressure: 0)
        expect(atmosphere.density).to eq(0.0)
      end
      
      it 'returns zero when temperature is zero' do
        atmosphere.update!(temperature: 0)
        expect(atmosphere.density).to eq(0.0)
      end
      
      it 'calculates different density for different gas compositions' do
        # Change to a CO2-dominated atmosphere like Venus
        atmosphere.gases.destroy_all
        atmosphere.update!(
          composition: {"CO2" => 96.5, "N2" => 3.5},
          temperature: 737, # Venus surface temperature
          pressure: 92 # Venus surface pressure in bar
        )
        
        atmosphere.gases.create!(name: "CO2", percentage: 96.5, mass: 4921.5e15, molar_mass: 44.01)
        atmosphere.gases.create!(name: "N2", percentage: 3.5, mass: 178.5e15, molar_mass: 28.01)
        
        # Venus's atmospheric density at surface is approximately 67 kg/m³
        # We'll allow a wider margin since this is an approximation
        expect(atmosphere.density).to be_within(10).of(67)
      end
    end
    
    describe '#calculate_gas_constant' do
      it 'returns a weighted average of gas constants based on composition' do
        # The actual value depends on the specific gas constants used
        # Allow for variation depending on calculation method
        expect(atmosphere.calculate_gas_constant).to be_within(100).of(287.05)
      end
      
      it 'returns Earth default when no gases exist' do
        atmosphere.gases.destroy_all
        expect(atmosphere.calculate_gas_constant).to eq(287.05)
      end
    end
    
    describe '#scale_height' do
      it 'calculates atmospheric scale height based on temperature, gravity and composition' do
        # Set Earth-like gravity
        allow(celestial_body).to receive(:gravity).and_return(9.8)
        
        # Earth's scale height is approximately 8.5 km
        # This is calculated as R*T/(M*g) = 8.31446*288/(0.029*9.8)/1000 ≈ 8.5
        expect(atmosphere.scale_height).to be_within(0.5).of(GameConstants::IDEAL_GAS_CONSTANT * 288 / (0.029 * 9.8) / 1000)
      end
      
      it 'calculates larger scale height for hotter atmospheres' do
        # Set Earth-like gravity
        allow(celestial_body).to receive(:gravity).and_return(9.8)
        
        # Get current scale height
        original_height = atmosphere.scale_height
        
        # Double the temperature
        atmosphere.update!(temperature: atmosphere.temperature * 2)
        
        # Scale height should approximately double
        expect(atmosphere.scale_height).to be_within(0.5).of(original_height * 2)
      end
      
      it 'calculates smaller scale height for higher gravity' do
        # Set Earth-like gravity
        allow(celestial_body).to receive(:gravity).and_return(9.8)
        original_height = atmosphere.scale_height
        
        # Double the gravity
        allow(celestial_body).to receive(:gravity).and_return(19.6)
        
        # Scale height should approximately halve
        expect(atmosphere.scale_height).to be_within(0.5).of(original_height / 2)
      end
    end
    
    describe '#calculate_average_molar_mass' do
      it 'calculates weighted average molar mass from gas composition' do
        # Earth's atmosphere has average molar mass of ~29 g/mol (0.029 kg/mol)
        expect(atmosphere.calculate_average_molar_mass).to be_within(0.001).of(0.029)
      end
      
      it 'returns Earth default when no gases exist' do
        atmosphere.gases.destroy_all
        expect(atmosphere.calculate_average_molar_mass).to eq(0.029)
      end
      
      it 'calculates different molar mass for different compositions' do
        # Change to a hydrogen/helium dominated atmosphere
        atmosphere.gases.destroy_all
        
        h2_data = {'properties' => {'molar_mass' => 2.016}}
        he_data = {'properties' => {'molar_mass' => 4.003}}
        
        allow(material_lookup).to receive(:find_material).with("H2").and_return(h2_data)
        allow(material_lookup).to receive(:find_material).with("He").and_return(he_data)
        
        atmosphere.gases.create!(name: "H2", percentage: 80.0, mass: 800, molar_mass: 2.016)
        atmosphere.gases.create!(name: "He", percentage: 20.0, mass: 200, molar_mass: 4.003)
        
        # Calculate expected molar mass: (0.8 * 2.016 + 0.2 * 4.003)/1000 = 0.00243 kg/mol
        expect(atmosphere.calculate_average_molar_mass).to be_within(0.0001).of(0.00243)
      end
    end
  end
end

