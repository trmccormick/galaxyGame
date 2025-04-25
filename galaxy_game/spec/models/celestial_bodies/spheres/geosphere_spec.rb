require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Geosphere, type: :model do
  # Keep the simple factory setup
  let(:celestial_body) { create(:celestial_body, :minimal) }
  let(:geosphere) { celestial_body.geosphere }
  let(:material_lookup) { instance_double(Lookup::MaterialLookupService) }

  before do
    allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
    allow(material_lookup).to receive(:find_material).and_return({
      'properties' => {
        'state_at_room_temp' => 'solid',
        'melting_point' => 1000,
        'boiling_point' => 2000
      }
    })
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:total_crust_mass).allow_nil }
    it { is_expected.to validate_numericality_of(:total_mantle_mass).allow_nil }
    it { is_expected.to validate_numericality_of(:total_core_mass).allow_nil }
    it { is_expected.to validate_numericality_of(:geological_activity).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
    it { is_expected.to validate_inclusion_of(:tectonic_activity).in_array([true, false]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:celestial_body) }
  end

  describe 'default values' do
    it 'sets default values for compositions and masses' do
      geosphere = described_class.new
      expect(geosphere.crust_composition).to eq({})
      expect(geosphere.mantle_composition).to eq({})
      expect(geosphere.core_composition).to eq({})
      expect(geosphere.total_crust_mass).to eq(0.0)
      expect(geosphere.total_mantle_mass).to eq(0.0)
      expect(geosphere.total_core_mass).to eq(0.0)
    end
  end

  describe '#calculate_materials' do
    it 'calculates and updates materials based on crust, mantle, and core composition' do
      skip "calculate_materials method not yet implemented"
      # ...rest of test
    end
  end

  describe '#add_material' do
    let(:material_lookup_service) { double('MaterialLookupService', find_material: { 'molar_mass' => 55.845, 'melting_point' => 1538, 'boiling_point' => 2862, 'vapor_pressure' => 0 }) }

    before do
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup_service)
    end

    it 'adds a material and updates the celestial body and geosphere' do
      # Use a unique material name to ensure it's newly created
      unique_name = "UniqueTestMaterial-#{SecureRandom.hex(4)}"
      
      # Mock the lookup service for this unique material
      allow(material_lookup_service).to receive(:find_material).with(unique_name).and_return({ 
        'properties' => {
          'state_at_room_temp' => 'solid',
          'melting_point' => 1538, 
          'boiling_point' => 2862
        }
      })
      
      # Track the initial count
      initial_count = geosphere.materials.count
      
      # Add the unique material
      geosphere.add_material(unique_name, 1000)

      # Simply check that we added something
      expect(geosphere.materials.count).to be > initial_count
      
      # Find the material
      new_material = geosphere.materials.find_by(name: unique_name)
      expect(new_material).to be_present
      expect(new_material.amount).to be_within(0.0001).of(1000)
      expect(new_material.location).to eq('geosphere')
    end

    it 'raises an error if the material is not found in the lookup service' do
      allow(material_lookup_service).to receive(:find_material).and_return(nil)

      expect { geosphere.add_material('UnknownMaterial', 1000) }.to raise_error(ArgumentError, "Material 'UnknownMaterial' not found in the lookup service.")
    end

    it 'does not add material if the mass is non-positive' do
      initial_count = geosphere.materials.count
      geosphere.add_material('Iron', -1000)

      # Expect no new materials
      expect(geosphere.materials.count).to eq(initial_count)
    end

    it 'adds material to the specified layer' do
      # Initial silicon in crust
      initial_si_pct = geosphere.crust_composition['Silicon']
      initial_crust_mass = geosphere.total_crust_mass
      
      # Add silicon
      silicon_to_add = 1.0e19
      result = geosphere.add_material('Silicon', silicon_to_add)
      
      # Check results
      expect(result).to be true
      expect(geosphere.total_crust_mass).to eq(initial_crust_mass + silicon_to_add)
      
      # Silicon percentage should increase
      expect(geosphere.crust_composition['Silicon']).to be > initial_si_pct
    end
    
    it 'rejects invalid layers' do
      expect { geosphere.add_material('Iron', 1000, :invalid_layer) }.to raise_error(ArgumentError)
    end
  end

  describe '#remove_material' do
    it 'removes material from the specified layer' do
      # Initial iron in core
      initial_fe_pct = geosphere.core_composition['Iron']
      initial_core_mass = geosphere.total_core_mass
      
      # Calculate how much iron that represents
      iron_mass = (initial_fe_pct / 100.0) * initial_core_mass
      
      # Remove 10% of the iron
      iron_to_remove = iron_mass * 0.1
      result = geosphere.remove_material('Iron', iron_to_remove, :core)
      
      # Check results
      expect(result).to be_within(0.1).of(iron_to_remove)
      expect(geosphere.total_core_mass).to be_within(0.1).of(initial_core_mass - iron_to_remove)
      
      # Percentage of iron should remain about the same (other materials were reduced proportionally)
      expect(geosphere.core_composition['Iron']).to be_within(0.1).of(initial_fe_pct)
    end
  end

  describe '#set_default_values' do
    it 'sets default values after initialization' do
      new_geosphere = described_class.new
      expect(new_geosphere.crust_composition).to eq({})
      expect(new_geosphere.mantle_composition).to eq({})
      expect(new_geosphere.core_composition).to eq({})
      expect(new_geosphere.total_crust_mass).to eq(0.0)
      expect(new_geosphere.total_mantle_mass).to eq(0.0)
      expect(new_geosphere.total_core_mass).to eq(0.0)
    end
  end

  describe 'callbacks' do
    it 'triggers TerraSim service after adding a material' do
      skip "run_terrasim_service method not yet implemented"
      # ...rest of test
    end
  end

  describe 'material management' do
    it 'creates materials in correct layer' do
      # Reset the geosphere to have zero mass first
      geosphere.update!(total_crust_mass: 0, crust_composition: {})
      
      # Now add material to empty crust - USE EXACT VALUE
      amount_to_add = 1000.0
      geosphere.add_material('Iron', amount_to_add, :crust)
      
      material = geosphere.materials.find_by(name: 'Iron')
      expect(material).to be_present
      expect(material.amount).to be_within(0.1).of(amount_to_add)
      expect(material.state).to eq('solid')
      
      expect(geosphere.crust_composition['Iron']).to be_present
      expect(geosphere.total_crust_mass).to be_within(0.1).of(amount_to_add)
    end

    it 'updates composition percentages' do
      # Reset the geosphere first
      geosphere.update!(total_crust_mass: 0, crust_composition: {})
      
      # Now add iron to empty crust
      geosphere.add_material('Iron', 1000, :crust)
      expect(geosphere.crust_composition['Iron']).to be_within(0.001).of(100)

      allow(material_lookup).to receive(:find_material).with('Silicon')
        .and_return('properties' => {'state_at_room_temp' => 'solid'})
      
      geosphere.add_material('Silicon', 1000, :crust)
      expect(geosphere.crust_composition['Iron']).to be_within(0.001).of(50)
      expect(geosphere.crust_composition['Silicon']).to be_within(0.001).of(50)
    end

    it 'prevents adding gas materials' do
      allow(material_lookup).to receive(:find_material).with('CO2')
        .and_return('properties' => {'state_at_room_temp' => 'gas'})
      
      expect {
        geosphere.add_material('CO2', 1000, :crust)
      }.to raise_error(ArgumentError, /Cannot add gas to geosphere/)
    end
  end

  describe 'material transfers' do
    it 'transfers material to atmosphere when heated' do
      skip "heat_material method not yet implemented"
      # ...rest of test
    end
  end

  describe '#reset' do
    it 'resets geosphere to base values' do
      # Change some values - use string keys not symbols
      geosphere.update!(
        crust_composition: { 'Silicon' => 40.0, 'Oxygen' => 35.0, 'Aluminum' => 10.0 },
        total_crust_mass: 9.0e19,
        geological_activity: 30,
        tectonic_activity: false
      )
      
      # Store these values in base_values to ensure the test works
      geosphere.update_column(:base_values, {
        'crust_composition' => { 'Silicon' => 45.0, 'Oxygen' => 30.0, 'Aluminum' => 15.0 },
        'total_crust_mass' => 1.0e20,
        'geological_activity' => 60,
        'tectonic_activity' => true
      })
      
      # Reset
      expect(geosphere.reset).to be true
      
      # Check values were restored
      expect(geosphere.crust_composition['Silicon']).to eq(45.0)
      expect(geosphere.crust_composition['Oxygen']).to eq(30.0)
      expect(geosphere.total_crust_mass).to eq(1.0e20)
      expect(geosphere.geological_activity).to eq(60)
      expect(geosphere.tectonic_activity).to be true
    end
  end
  
  describe '#extract_volatiles' do
    it 'extracts volatiles based on temperature increase' do
      # Initial state
      initial_co2_in_regolith = geosphere.crust_composition.dig('volatiles', 'CO2')
      initial_co2_in_atmo = celestial_body.atmosphere.gases.find_by(name: 'CO2')&.mass || 0
      
      # Apply temperature increase
      volatiles_released = geosphere.extract_volatiles(50)
      
      # Check that CO2 was released
      expect(volatiles_released).to have_key('CO2')
      expect(volatiles_released['CO2']).to be > 0
      
      # Check regolith has less CO2
      expect(geosphere.crust_composition.dig('volatiles', 'CO2')).to be < initial_co2_in_regolith
      
      # Check atmosphere has more CO2
      current_co2_in_atmo = celestial_body.atmosphere.gases.find_by(name: 'CO2')&.mass || 0
      expect(current_co2_in_atmo).to be > initial_co2_in_atmo
    end
  end

  describe '#calculate_tectonic_activity' do
    it 'sets tectonic_activity based on geological_activity' do
      # Set activity to low value
      geosphere.update!(geological_activity: 30)
      geosphere.calculate_tectonic_activity
      expect(geosphere.tectonic_activity).to be false
      
      # Set activity to high value
      geosphere.update!(geological_activity: 70)
      geosphere.calculate_tectonic_activity
      expect(geosphere.tectonic_activity).to be true
    end
  end
  
  describe '#update_geological_activity' do
    it 'updates geological_activity based on planet parameters' do
      # Initial value
      initial_activity = geosphere.geological_activity
      
      # Update activity
      new_activity = geosphere.update_geological_activity
      
      # Should have calculated a value
      expect(new_activity).to be >= 0
      expect(new_activity).to be <= 100
      expect(geosphere.geological_activity).to eq(new_activity)
    end
  end

  describe '#materials association' do
    it 'has materials as materializable' do
      # Get initial count
      initial_count = geosphere.materials.count
      
      # Add a distinctive material to geosphere
      geosphere.add_material('Platinum', 1.0e19, :core)
      
      # Check the material was created
      expect(geosphere.materials.count).to be > initial_count
      
      # Check attributes of the specific material we added
      platinum = geosphere.materials.find_by(name: 'Platinum')
      expect(platinum).to be_present
      expect(platinum.amount).to eq(1.0e19)
      expect(platinum.location).to eq('geosphere')
      expect(platinum.state).to eq('solid')
    end
    
    it 'updates material state based on temperature' do
      # Clear existing materials first
      geosphere.materials.destroy_all
      
      # Add material with known melting point
      allow(material_lookup).to receive(:find_material).with('Mercury').and_return({
        'properties' => {
          'melting_point' => 234.32,
          'boiling_point' => 629.88
        }
      })
      
      # Add at room temperature (solid)
      geosphere.temperature = 200 # Well below melting point
      geosphere.save!
      geosphere.add_material('Mercury', 1000, :crust)
      
      # Check state
      mercury = geosphere.materials.find_by(name: 'Mercury')
      expect(mercury.state).to eq('solid')
      
      # Increase temperature above melting point
      geosphere.temperature = 300
      geosphere.save!
      geosphere.update_material_states
      
      # Check state changed to liquid
      mercury.reload
      expect(mercury.state).to eq('liquid')
    end
  end
  
  describe '#extract_volatiles' do
    it 'properly transfers volatiles to the atmosphere' do
      # Set up a geosphere with volatiles
      geosphere.update!(
        crust_composition: { 
          'Silicon': 45.0, 
          'Oxygen': 30.0, 
          'volatiles': { 
            'CO2': 10.0, 
            'H2O': 5.0 
          } 
        },
        total_crust_mass: 1.0e20
      )
      
      # Track initial values
      initial_co2_in_regolith = 1.0e19 # 10% of crust mass
      initial_co2_in_atmo = celestial_body.atmosphere.gases.find_by(name: 'CO2')&.mass || 0
      
      # Extract volatiles
      volatiles_released = geosphere.extract_volatiles(50)
      
      # Check that CO2 was released
      expect(volatiles_released).to have_key('CO2')
      expect(volatiles_released['CO2']).to be > 0
      
      # Check atmosphere has more CO2
      current_co2_in_atmo = celestial_body.atmosphere.gases.find_by(name: 'CO2')&.mass || 0
      expect(current_co2_in_atmo).to be > initial_co2_in_atmo
      
      # Material record should exist
      co2_material = geosphere.materials.find_by(name: 'CO2')
      expect(co2_material).to be_present
      
      # Material amount should match composition
      expected_co2 = (geosphere.crust_composition.dig('volatiles', 'CO2').to_f / 100.0) * geosphere.total_crust_mass
      expect(co2_material.amount).to be_within(1.0e9).of(expected_co2)
    end
  end
  
  describe '#reset' do
    it 'resets both compositions and material records' do
      # Store current values
      geosphere.update_column(:base_values, {
        'crust_composition' => { 'Silicon' => 45.0, 'Oxygen' => 30.0 }
      })
      
      # Change composition 
      geosphere.update!(
        crust_composition: { 'Silicon' => 30.0, 'Oxygen' => 45.0 }
      )
      
      # Reset
      geosphere.reset
      
      # Check composition restored
      expect(geosphere.crust_composition['Silicon']).to eq(45.0)
      expect(geosphere.crust_composition['Oxygen']). to eq(30.0)
    end
  end
end


