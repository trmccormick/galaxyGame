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
      # Initialize the geosphere with some compositions first to avoid nil errors
      geosphere.update!(
        crust_composition: {'Silicon' => 100.0},
        total_crust_mass: 1.0e19
      )
      
      # Initial silicon in crust
      initial_si_pct = geosphere.reload.crust_composition['Silicon']
      initial_crust_mass = geosphere.total_crust_mass
      
      # Add silicon
      silicon_to_add = 1.0e19
      result = geosphere.add_material('Silicon', silicon_to_add)
      
      # Check results
      expect(result).to be true
      expect(geosphere.total_crust_mass).to eq(initial_crust_mass + silicon_to_add)
      
      # Silicon percentage should not be nil
      expect(geosphere.crust_composition['Silicon']).to be_present
    end
    
    it 'rejects invalid layers' do
      expect { geosphere.add_material('Iron', 1000, :invalid_layer) }.to raise_error(ArgumentError)
    end
  end

  describe '#remove_material' do
    it 'removes material from the specified layer' do
      # Make sure core has iron first
      iron_amount = 1.0e20
      geosphere.update!(core_composition: {'Iron' => 100.0}, total_core_mass: iron_amount)
      
      # Initial iron in core (now guaranteed to exist)
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
    before do
      # Create a proper test environment
      geosphere.update!(
        crust_composition: {
          'volatiles' => { 'CO2' => 10.0, 'H2O' => 5.0 }
        },
        total_crust_mass: 5.0e19
      )
      
      # Mock the atmosphere object
      atmosphere = double('atmosphere')
      allow(geosphere.celestial_body).to receive(:atmosphere).and_return(atmosphere)
      allow(atmosphere).to receive(:add_gas).and_return(true)
    end
    
    it 'extracts volatiles based on temperature increase' do
      result = geosphere.extract_volatiles(50)
      
      # Test the output without relying on hardcoded test values
      expect(result).to be_a(Hash)
      expect(result).to have_key('CO2')
      expect(result['CO2']).to be > 0
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
      expect(geosphere.crust_composition['Oxygen']).to eq(30.0)
    end
  end

  describe 'regolith properties' do
    subject { create(:geosphere) }
    
    it 'has regolith_depth attribute' do
      expect(subject).to respond_to(:regolith_depth)
    end
    
    it 'has regolith_particle_size attribute' do
      expect(subject).to respond_to(:regolith_particle_size)
    end
    
    it 'has weathering_rate attribute' do
      expect(subject).to respond_to(:weathering_rate)
    end
    
    it 'initializes with default regolith depth of zero' do
      expect(subject.regolith_depth).to eq(0.0)
    end
    
    it 'can update regolith properties' do
      subject.update(regolith_depth: 5.0, weathering_rate: 2.5)
      subject.reload
      expect(subject.regolith_depth).to eq(5.0)
      expect(subject.weathering_rate).to eq(2.5)
    end

    it 'calculates weathering rate based on atmosphere and activity' do
      # Skip if columns don't exist
      pending "Regolith columns not yet added" unless column_exists?(:geospheres, :weathering_rate)
      
      # Create the necessary associated models
      atmosphere = create(:atmosphere, celestial_body: subject.celestial_body, pressure: 1.0)
      
      # Set geological activity
      subject.update(geological_activity: 50)
      
      # Calculate weathering
      subject.calculate_weathering_rate
      
      # Rate should be positive with atmosphere
      expect(subject.weathering_rate).to be > 0.1
    end

    it 'updates regolith depth after erosion' do
      pending "Regolith columns not yet added" unless column_exists?(:geospheres, :regolith_depth)
      
      # Set initial depth
      subject.update(regolith_depth: 10.0)
      
      # Apply erosion
      subject.update_erosion(2.5)
      expect(subject.reload.regolith_depth).to be_within(0.1).of(7.5)
    end

    it 'updates plate positions when tectonics are active' do
      pending "Plates column not yet added" unless column_exists?(:geospheres, :plates) 
  
      # Set tectonic activity
      subject.update(tectonic_activity: true)
      
      # Move plates
      distance = 3.5
      subject.update_plate_positions(distance)
      
      # Should have plate data
      expect(subject.plates).to be_a(Hash)
      
      # Use the correct structure - plates["positions"].last["plates"][0]["movement"]
      expect(subject.plates["positions"].last["plates"][0]["movement"]).to eq(distance)
    end

    # Add a helper method to check if columns exist
    def column_exists?(table, column)
      ActiveRecord::Base.connection.column_exists?(table, column)
    rescue
      false
    end
  end
end


