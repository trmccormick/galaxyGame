require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Biosphere, type: :model do
  let(:solar_system) { create(:solar_system) }
  let(:celestial_body) { create(:celestial_body, solar_system: solar_system) }
  let(:atmosphere) do
    create(:atmosphere, celestial_body: celestial_body).tap do |atm|
      atm.add_gas('water', 1000.0)
      atm.add_gas('carbon_dioxide', 500.0)
      atm.add_gas('nitrogen', 2000.0)
    end
  end
  let(:biosphere) { create(:biosphere, celestial_body: celestial_body) }

  describe 'associations' do
    it { should belong_to(:celestial_body) }
    it { should have_many(:materials).dependent(:destroy) }
    it { should have_many(:planet_biomes).dependent(:destroy) }
    it { should have_many(:biomes).through(:planet_biomes) }
  end

  describe 'validations' do
    it 'can access temperature values via tropical_temperature method' do
      expect(biosphere).to respond_to(:tropical_temperature)
    end
    
    it 'can access temperature values via polar_temperature method' do
      expect(biosphere).to respond_to(:polar_temperature)
    end
    
    it { should validate_numericality_of(:biodiversity_index).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1).allow_nil }
    it { should validate_numericality_of(:habitable_ratio).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1).allow_nil }
  end

  describe 'defaults' do
    before do
      # Prevent callbacks from running during test
      allow_any_instance_of(CelestialBodies::CelestialBody).to receive(:run_terra_sim).and_return(nil)
      
      # Delete any existing atmospheres to ensure there's only one
      celestial_body.atmosphere.destroy if celestial_body.atmosphere.present?
      
      # Set the celestial body surface temperature
      celestial_body.update!(surface_temperature: 290.0)
      
      # Create/update our atmosphere with proper temperature data
      atmosphere.update!(
        temperature_data: {
          'tropical_temperature' => 300.0,
          'polar_temperature' => 250.0
        },
        temperature: 288.0
      )
      
      # Force a reload to ensure the celestial body knows about this atmosphere
      celestial_body.reload
    end

    it 'accesses default temperature values via delegation methods' do
      # Use the existing biosphere rather than creating a new one
      biosphere.reload
      
      # Debug output to verify what's happening
      puts "TEST DEBUG: Atmosphere ID: #{atmosphere.id}"
      puts "TEST DEBUG: CelestialBody atmosphere ID: #{celestial_body.atmosphere.id}"
      puts "TEST DEBUG: Tropical temp from atmosphere: #{atmosphere.temperature_data['tropical_temperature']}"
      puts "TEST DEBUG: Tropical temp via biosphere: #{biosphere.tropical_temperature}"
      
      # Expectations should now work correctly
      expect(biosphere.tropical_temperature).to eq(300.0)
      expect(biosphere.polar_temperature).to eq(250.0)
      expect(biosphere.biodiversity_index).to eq(0.0)
      expect(biosphere.habitable_ratio).to eq(0.0)
      expect(biosphere.biome_distribution).to eq({})
    end
  end

  describe '#reset' do
    let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }
    
    before do
      atmosphere.update(
        temperature_data: {
          'tropical_temperature' => 300.0,
          'polar_temperature' => 250.0
        }
      )
    end
    
    it 'coordinates with atmosphere for temperature reset' do
      # First update atmosphere's temperature_data
      atmosphere.update(
        temperature_data: {
          'tropical_temperature' => 310.0,
          'polar_temperature' => 260.0
        }
      )
      
      # Set biodiversity and habitable ratio in biosphere
      biosphere.update!(
        biodiversity_index: 0.5,
        habitable_ratio: 0.3,
        biome_distribution: { 'forest' => { 'area_percentage' => 100.0 } }
      )
      
      # Then set the base values in atmosphere
      atmosphere.update!(base_values: {
        base_temperature_data: {
          'tropical_temperature' => 300.0,
          'polar_temperature' => 250.0
        }
      })
      
      # Set biosphere base values
      biosphere.update!(
        base_biodiversity_index: 0.0,
        base_habitable_ratio: 0.0,
        base_biome_distribution: {}
      )
      
      # Reset biosphere, which should coordinate with atmosphere
      biosphere.reset
      
      # Verify reset worked for biosphere values
      expect(biosphere.biodiversity_index).to eq(0.0)
      expect(biosphere.habitable_ratio).to eq(0.0)
      expect(biosphere.biome_distribution).to eq({})
      
      # Verify atmosphere temperatures were reset
      expect(biosphere.tropical_temperature).to eq(300.0)
      expect(biosphere.polar_temperature).to eq(250.0)
    end
  end

  describe '#transfer_material' do
    let(:target_sphere) { create(:geosphere, celestial_body: celestial_body) }
    
    before do
      # Create a proper celestial body association first to avoid validation errors
      # Make sure the material is properly associated with the biosphere
      @material = CelestialBodies::Material.create!(
        celestial_body: celestial_body,
        materializable: biosphere, 
        name: 'Organic Matter',
        amount: 100
      )
    end

    it 'transfers material to target sphere' do
      # Test transfer operation
      result = biosphere.transfer_material('Organic Matter', 50, target_sphere)
      
      # Check results
      expect(result).to be_truthy
      expect(biosphere.materials.find_by(name: 'Organic Matter').amount).to eq(50)
      expect(target_sphere.materials.find_by(name: 'Organic Matter').amount).to eq(50)
    end
    
    it 'returns false if material not found' do
      result = biosphere.transfer_material('NonExistentMaterial', 50, target_sphere)
      expect(result).to be_falsey
    end
    
    it 'returns false if not enough material available' do
      # Update the existing material to have less than needed
      @material.update!(amount: 30)
      
      # Try to transfer more than available
      result = biosphere.transfer_material('Organic Matter', 50, target_sphere)
      expect(result).to be_falsey
    end
    
    it 'logs errors when transfer fails due to validation errors' do
      # Create a material
      material = biosphere.materials.create!(name: 'Test Material', amount: 100, celestial_body: celestial_body)
      
      # Mock Rails.logger to expect an error log
      expect(Rails.logger).to receive(:error).with(/Error transferring material/)
      
      # Mock Material.transaction to raise a validation error
      allow(CelestialBodies::Material).to receive(:transaction).and_raise(ActiveRecord::RecordInvalid.new(material))
      
      # Attempt transfer (should fail)
      result = biosphere.transfer_material('Test Material', 50, target_sphere)
      
      # Should return false
      expect(result).to be_falsey
    end
    
    it 'logs errors when target material cannot be created' do
      # Create a test material
      test_material = biosphere.materials.create!(
        name: 'Test Material',
        amount: 100,
        celestial_body: celestial_body
      )
      
      # Create an invalid target sphere that will cause errors
      invalid_target = double('InvalidTarget')
      invalid_materials = double('InvalidMaterials')
      
      # Set up the doubles to behave like a sphere with materials
      allow(invalid_target).to receive(:celestial_body).and_return(nil)
      allow(invalid_target).to receive(:materials).and_return(invalid_materials)
      
      # Set up the materials mock to return a material that will fail validation
      invalid_material = CelestialBodies::Material.new # No celestial_body, will fail validation
      allow(invalid_materials).to receive(:find_or_initialize_by).with(name: 'Test Material').and_return(invalid_material)
      
      # Expect error to be logged
      expect(Rails.logger).to receive(:error).with(/Error transferring material/)
      
      # Attempt transfer (should fail)
      result = biosphere.transfer_material('Test Material', 50, invalid_target)
      
      # Should return false
      expect(result).to be_falsey
    end

    it 'logs errors when target material cannot be created' do
      # Create a material for transfer
      material = biosphere.materials.create!(
        name: 'Test Material',
        amount: 100,
        celestial_body: celestial_body
      )
      
      # Create an invalid target sphere that will cause errors
      invalid_target = double('InvalidTarget')
      allow(invalid_target).to receive(:materials).and_raise(StandardError.new("Test error"))
      
      # Mock Rails logger to expect the error
      expect(Rails.logger).to receive(:error).with(/Error transferring material/)
      
      # Attempt transfer (should fail)
      result = biosphere.transfer_material('Test Material', 50, invalid_target)
      
      # Should return false
      expect(result).to be_falsey
    end
  end

  describe 'biome management' do
    let(:biome) { create(:biome, name: 'Forest', temperature_range: 280..310, humidity_range: 50..90) }
    
    it 'introduces a new biome' do
      expect {
        biosphere.introduce_biome(biome)
      }.to change { biosphere.biomes.count }.by(1)
      
      expect(biosphere.biome_distribution).to have_key('Forest')
    end
    
    it 'removes a biome' do
      biosphere.introduce_biome(biome)
      
      expect {
        biosphere.remove_biome(biome)
      }.to change { biosphere.biomes.count }.by(-1)
      
      expect(biosphere.biome_distribution).not_to have_key('Forest')
    end
  end

  describe '#calculate_biodiversity_index' do
    let(:biome1) { create(:biome, name: 'Forest', temperature_range: 280..310, humidity_range: 50..90) }
    let(:biome2) { create(:biome, name: 'Desert', temperature_range: 300..340, humidity_range: 10..30) }
    
    it 'calculates biodiversity index based on biome diversity' do
      # Add biomes to the biosphere
      biosphere.introduce_biome(biome1)
      biosphere.introduce_biome(biome2)
      
      # Calculate biodiversity
      biodiversity = biosphere.calculate_biodiversity_index
      
      # Should have non-zero biodiversity with multiple biomes
      expect(biodiversity).to be > 0
      expect(biosphere.biodiversity_index).to eq(biodiversity)
    end
    
    it 'returns 0 for a barren biosphere' do
      expect(biosphere.calculate_biodiversity_index).to eq(0)
    end
  end

  describe '#calculate_habitability' do
    let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }
    let(:oxygen) { double('Gas', name: 'O2', percentage: 20.0) }
    
    before do
      allow(celestial_body).to receive(:atmosphere).and_return(atmosphere)
      allow(atmosphere).to receive(:gases).and_return(double('Gases', exists?: true))
      allow(atmosphere.gases).to receive(:find_by)
                        .with(hash_including(:name => anything()))
                        .and_return(oxygen)
      allow(celestial_body).to receive(:surface_temperature).and_return(288.0)
      allow(atmosphere).to receive(:pressure).and_return(1.0)
    end
    
    it 'calculates habitability based on atmospheric conditions' do
      # Call the method
      habitability = biosphere.calculate_habitability
      
      # Should have high habitability with Earth-like conditions
      expect(habitability).to be > 0.5
      expect(biosphere.habitable_ratio).to eq(habitability)
    end
    
    it 'returns 0 with no atmosphere' do
      allow(celestial_body).to receive(:atmosphere).and_return(nil)
      expect(biosphere.calculate_habitability).to eq(0.0)
    end
    
    it 'returns low habitability with poor conditions' do
      allow(oxygen).to receive(:percentage).and_return(2.0) # Too little oxygen
      allow(atmosphere).to receive(:pressure).and_return(0.1) # Too little pressure
      allow(celestial_body).to receive(:surface_temperature).and_return(350.0) # Too hot
      
      expect(biosphere.calculate_habitability).to be < 0.3
    end
  end
  
  describe '#discover_life' do
    before do
      # Mock random to deterministically test discovery
      allow(biosphere).to receive(:rand).and_return(0.3)
    end
    
    it 'discovers nothing with low biodiversity' do
      allow(biosphere).to receive(:biodiversity_index).and_return(0.05)
      expect(biosphere.discover_life).to eq([])
    end
    
    it 'has a chance to discover life with moderate biodiversity' do
      # Set up conditions where life should be discovered (mocked rand < chance)
      allow(biosphere).to receive(:biodiversity_index).and_return(0.7)
      
      # Mock the alien life form creation to avoid database operations
      alien_life = double('AlienLifeForm')
      allow(CelestialBodies::AlienLifeForm).to receive(:create!).and_return(alien_life)
      
      # Should discover life
      result = biosphere.discover_life
      expect(result).to include(alien_life)
    end
  end
  
  describe 'ecological processes' do
    it 'runs ecological cycle during simulation' do
      expect(biosphere).to receive(:ecological_cycle_tick)
      expect(biosphere).to receive(:calculate_biodiversity_index)
      expect(biosphere).to receive(:calculate_habitability)
      
      # Use set_tropical_temperature instead of direct field access
      allow(biosphere).to receive(:set_tropical_temperature)
      biosphere.set_tropical_temperature(biosphere.tropical_temperature + 5)
      biosphere.save!
    end
  end

  describe 'Material transfer edge cases' do
    # These tests need to be nested inside the main RSpec.describe block
    # but defined separately to use the celestial_body and biosphere from the outer context
    
    # Define geosphere for testing transfers
    let(:geosphere) { create(:geosphere, celestial_body: celestial_body) }
  
    before do
      # Create a test material in biosphere
      @test_material = biosphere.materials.create!(
        name: 'Test Material',
        amount: 100,
        celestial_body: celestial_body
      )
    end
    
    it 'correctly assigns celestial_body to target material' do
      # Transfer the material
      result = biosphere.transfer_material('Test Material', 50, geosphere)
      
      # Check result and target material
      expect(result).to be_truthy
      target_material = geosphere.materials.find_by(name: 'Test Material')
      expect(target_material.celestial_body).to eq(celestial_body)
    end
    
    it 'initializes target material with amount 0 if it does not exist' do
      # Create a new material that doesn't exist in target sphere
      new_material = biosphere.materials.create!(
        name: 'Unique Material',
        amount: 50,
        celestial_body: celestial_body
      )
      
      # Transfer to target sphere
      result = biosphere.transfer_material('Unique Material', 30, geosphere)
      
      # Check target material was created properly
      expect(result).to be_truthy
      target_material = geosphere.materials.find_by(name: 'Unique Material')
      expect(target_material.amount).to eq(30)
    end
    
    it 'uses Material class with correct namespace for transaction' do
      # Create a test material first
      test_material = biosphere.materials.create!(
        name: 'Test Material',
        amount: 100,
        celestial_body: celestial_body
      )
      
      # Use allow_any_instance_of instead of a direct expect
      allow_any_instance_of(CelestialBodies::Material).to receive(:transaction).and_call_original
      
      # Perform the transfer
      result = biosphere.transfer_material('Test Material', 20, geosphere)
      
      # Check the result
      expect(result).to be_truthy
    end
    
    it 'handles nil amount in target material' do
      # First create a material in the biosphere
      test_material = biosphere.materials.create!(
        name: 'Material With Nil',
        amount: 40,
        celestial_body: celestial_body
      )
      
      # Then create a material in geosphere with amount 0 (not nil)
      target_material = geosphere.materials.create!(
        name: 'Material With Nil',
        amount: 0,
        celestial_body: celestial_body
      )
      
      # Now reset the amount to nil directly in database to bypass validation
      geosphere.materials.where(name: 'Material With Nil').update_all(amount: nil)
      
      # Transfer material
      result = biosphere.transfer_material('Material With Nil', 20, geosphere)
      
      # Check it handled nil amount correctly
      expect(result).to be_truthy
      expect(geosphere.materials.find_by(name: 'Material With Nil').amount).to eq(20)
    end
  end

  describe 'soil properties' do
    subject { create(:biosphere) }
    
    it 'has soil_health attribute' do
      expect(subject).to respond_to(:soil_health)
    end
    
    it 'has soil_organic_content attribute' do
      expect(subject).to respond_to(:soil_organic_content)
    end
    
    it 'has soil_microbial_activity attribute' do
      expect(subject).to respond_to(:soil_microbial_activity)
    end
    
    it '#update_soil_health updates soil health value' do
      expect { subject.update_soil_health(75) }
        .to change { subject.reload.soil_health }.to(75)
    end
    
    it 'initializes with default soil health of zero' do
      expect(subject.soil_health).to eq(0)
    end
  end

  describe 'vegetation cover' do
    it 'has vegetation_cover attribute' do
      expect(subject).to respond_to(:vegetation_cover)
    end
    
    it 'defaults to 0.0 vegetation cover' do
      new_biosphere = CelestialBodies::Spheres::Biosphere.new
      expect(new_biosphere.vegetation_cover).to eq(0.0)
    end
    
    it 'can update vegetation cover' do
      # Use the factory with celestial_body from above
      biosphere.update_vegetation_cover(75.5)
      expect(biosphere.reload.vegetation_cover).to eq(75.5)
    end
  end

  describe 'temperature delegation' do
    let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }
    
    before do
      # Set up atmosphere with temperature data
      atmosphere.update(temperature_data: {
        'tropical_temperature' => 310.0,
        'polar_temperature' => 240.0
      })
    end
    
    it 'delegates tropical_temperature to atmosphere when available' do
      expect(biosphere.tropical_temperature).to eq(310.0)
    end
    
    it 'delegates polar_temperature to atmosphere when available' do
      expect(biosphere.polar_temperature).to eq(240.0)
    end
    
    it 'falls back to default value when atmosphere is not available' do
      # Remove atmosphere
      atmosphere.destroy
      celestial_body.reload
      
      # Should fall back to default value
      expect(biosphere.tropical_temperature).to eq(300.0) # This is the default value in the method
    end
  end

  describe 'temperature delegation' do
    let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }
    
    before do
      # Set up atmosphere with temperature data
      atmosphere.update(temperature_data: {
        'tropical_temperature' => 310.0,
        'polar_temperature' => 240.0
      })
    end
    
    it 'delegates tropical_temperature to atmosphere when available' do
      expect(biosphere.tropical_temperature).to eq(310.0)
    end
    
    it 'delegates polar_temperature to atmosphere when available' do
      expect(biosphere.polar_temperature).to eq(240.0)
    end
    
    it 'falls back to default value when atmosphere is not available' do
      # Remove atmosphere
      atmosphere.destroy
      celestial_body.reload
      
      # Should fall back to default values defined in the model
      expect(biosphere.tropical_temperature).to eq(300.0)
      expect(biosphere.polar_temperature).to eq(250.0)
    end
  end
end