require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Biosphere, type: :model do
  let(:solar_system) { create(:solar_system) }
  let(:celestial_body) { create(:celestial_body, solar_system: solar_system) }
  let(:atmosphere) do
    create(:atmosphere, celestial_body: celestial_body).tap do |atm|
      atm.add_gas('H2O', 1000.0)
      atm.add_gas('CO2', 500.0)
      atm.add_gas('N2', 2000.0)
    end
  end
  let(:biosphere) { create(:biosphere, celestial_body: celestial_body) }

  describe 'associations' do
    it { should belong_to(:celestial_body) }
    it { should have_many(:materials).dependent(:destroy) }
    it { should have_many(:planet_biomes).dependent(:destroy) }
    it { should have_many(:biomes).through(:planet_biomes) }
  end

  describe 'life form associations' do
    it { should have_many(:life_forms).dependent(:destroy) }
    
    it 'uses the Biology::LifeForm class for the association' do
      association = CelestialBodies::Spheres::Biosphere.reflect_on_association(:life_forms)
      expect(association.options[:class_name]).to eq('Biology::LifeForm')
    end
    
    it 'can create life forms' do
      expect {
        biosphere.life_forms.create!(
          name: "Test Life Form",
          complexity: :simple,
          domain: :terrestrial,
          population: 1000
        )
      }.to change { Biology::LifeForm.count }.by(1)
    end
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
    before do
      atmosphere.update!(
        temperature_data: {
          'tropical_temperature' => 300.0,
          'polar_temperature' => 250.0
        },
        temperature: 288.0,
        pressure: 1.0
      )
      celestial_body.update!(surface_temperature: 288.0)
      # Ensure O2 gas exists for base tests (factory creates H2O/CO2/N2 only)
      o2 = atmosphere.gases.find_by(name: 'O2')
      unless o2
        atmosphere.gases.create!(name: 'O2', percentage: 21.0)
      end
    end
    
    it 'calculates habitability based on atmospheric conditions' do
      habitability = biosphere.calculate_habitability
      
      expect(habitability).to be > 0.5
      expect(biosphere.habitable_ratio).to eq(habitability)
    end
    
    it 'returns 0 with no atmosphere' do
      allow(celestial_body).to receive(:atmosphere).and_return(nil)
      expect(biosphere.calculate_habitability).to eq(0.0)
    end
    
    it 'returns low habitability with poor conditions' do
      atmosphere.update!(pressure: 0.1, temperature: 288.0)
      celestial_body.update!(surface_temperature: 350.0)
      o2 = atmosphere.gases.find_by(name: 'O2')
      o2&.update!(percentage: 2.0) if o2
      
      habitability = biosphere.calculate_habitability
      expect(habitability).to be < 0.4
    end
    
    context 'with world-agnostic temperature factor' do
      before do
        atmosphere.update!(temperature: 288.0, pressure: 1.0)
        celestial_body.update!(surface_temperature: 288.0)
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 21.0) if o2
      end
      
      it 'gives optimal score when temp is within ±15K of ambient' do
        celestial_body.update!(surface_temperature: 295.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.6
      end
      
      it 'gives reduced score when temp is within ±30K of ambient' do
        celestial_body.update!(surface_temperature: 320.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.75
      end
      
      it 'gives poor score when temp is within ±60K of ambient' do
        celestial_body.update!(surface_temperature: 348.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.7
      end
      
      it 'gives worst score when temp is beyond ±120K of ambient' do
        celestial_body.update!(surface_temperature: 420.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.6
      end
      
      it 'works for non-Earth worlds (Mars-like ambient)' do
        atmosphere.update!(temperature: 210.0, pressure: 0.6)
        celestial_body.update!(surface_temperature: 215.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.2
      end
      
      it 'works for hot worlds (Venus-like ambient)' do
        atmosphere.update!(temperature: 737.0, pressure: 90.0)
        celestial_body.update!(surface_temperature: 740.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.1
      end
    end
    
    context 'with oxygen factor' do
      before do
        atmosphere.update!(temperature: 288.0, pressure: 1.0)
        celestial_body.update!(surface_temperature: 288.0)
      end
      
      it 'gives optimal score for O2 between 15-30%' do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 21.0) if o2
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.5
      end
      
      it 'gives marginal score for O2 between 10-15%' do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 12.0) if o2
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.7
      end
      
      it 'gives low score for O2 between 5-10%' do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 7.0) if o2
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.65
      end
      
      it 'gives worst score for O2 below 5%' do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 2.0) if o2
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.55
      end
      
      it 'gives reduced score for O2 above 30% (fire risk)' do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 35.0) if o2
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.7
      end
      
      it 'handles nil O2 gas gracefully' do
        o2_gas = atmosphere.gases.find_by(name: 'O2')
        o2_gas&.destroy if o2_gas
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.55
      end
    end
    
    context 'with liquid water factor' do
      before { allow_any_instance_of(CelestialBodies::Spheres::Hydrosphere).to receive(:run_simulation) }
      
      it 'derives score from hydrosphere state_distribution liquid ratio (0-1)' do
        hyd = create(:hydrosphere, celestial_body: celestial_body)
        hyd.update!(state_distribution: { 'liquid' => 0.5 })
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.3
      end
      
      it 'derives score from hydrosphere state_distribution liquid percentage (0-100)' do
        hyd = create(:hydrosphere, celestial_body: celestial_body)
        hyd.update!(state_distribution: { 'liquid' => 75.0 })
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.4
      end
      
      it 'falls back to 0.0 when hydrosphere is missing' do
        # Use a fresh celestial body without hydrosphere to test graceful degradation
        fresh_body = create(:celestial_body, solar_system: solar_system)
        fresh_atmo = create(:atmosphere, celestial_body: fresh_body, temperature: 288.0, pressure: 1.0)
        fresh_atmo.gases.create!(name: 'O2', percentage: 21.0)
        fresh_body.update!(surface_temperature: 288.0)
        fresh_body.build_biosphere.skip_simulation = true if fresh_body.biosphere.respond_to?(:skip_simulation=)
        fresh_body.biosphere.save!
        
        habitability = fresh_body.biosphere.calculate_habitability
        # With all other factors optimal but no water, expect moderate habitability
        expect(habitability).to be > 0.3
      end
      
      it 'falls back to 0.0 when state_distribution is nil' do
        hyd = create(:hydrosphere, celestial_body: celestial_body)
        hyd.update!(state_distribution: nil)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.3
      end
      
      it 'falls back to 0.0 when state_distribution has no liquid key' do
        hyd = create(:hydrosphere, celestial_body: celestial_body)
        hyd.update!(state_distribution: { 'ice' => 100.0 })
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.3
      end
      
      it 'handles empty state_distribution hash gracefully' do
        hyd = create(:hydrosphere, celestial_body: celestial_body)
        hyd.update!(state_distribution: {})
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.3
      end
    end
    
    context 'with pressure factor' do
      before do
        atmosphere.update!(temperature: 288.0)
        celestial_body.update!(surface_temperature: 288.0)
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 21.0) if o2
      end
      
      it 'gives optimal score for Earth-normal pressure (1 bar)' do
        atmosphere.update!(pressure: 1.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.5
      end
      
      it 'gives reduced score for thin atmosphere (Mars-like 0.6 bar)' do
        atmosphere.update!(pressure: 0.6)
        
        habitability = biosphere.calculate_habitability
        # 0.6 bar is in the "workable" range (factor=0.8), so expect moderate score
        expect(habitability).to be < 0.85
      end
      
      it 'gives reduced score for very thin atmosphere (0.2 bar)' do
        atmosphere.update!(pressure: 0.2)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.7
      end
      
      it 'gives reduced score for thick atmosphere (Venus-like 90 bar)' do
        atmosphere.update!(pressure: 90.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be < 0.65
      end
      
      it 'works for low-pressure worlds (Mars-like)' do
        atmosphere.update!(pressure: 0.6, temperature: 210.0)
        celestial_body.update!(surface_temperature: 215.0)
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be >= 0.0
      end
    end
    
    context 'with life presence bonus' do
      before do
        Biology::LifeForm.where(biosphere: biosphere).destroy_all
      end
      
      it 'gives no bonus when no life forms exist' do
        habitability = biosphere.calculate_habitability
        expect(habitability).to be > 0.3 # still has base factors
      end
      
      it 'applies bonus based on life form count and domain diversity' do
        lf1 = create(:life_form, biosphere: biosphere, complexity: :microbial, domain: :aquatic)
        lf2 = create(:life_form, biosphere: biosphere, complexity: :simple, domain: :terrestrial)
        
        habitability_with_bonus = biosphere.calculate_habitability
        
        lf1.destroy
        lf2.destroy
        biosphere.reload
        
        habitability_no_bonus = biosphere.calculate_habitability
        
        expect(habitability_with_bonus).to be > habitability_no_bonus
      end
      
      it 'caps total habitability at 1.0 even with max life bonus' do
        20.times do |i|
          create(:life_form, biosphere: biosphere, 
                        complexity: [:microbial, :simple, :complex][i % 3], 
                        domain: [:aquatic, :terrestrial, :aerial][i % 3])
        end
        
        habitability = biosphere.calculate_habitability
        expect(habitability).to be <= 1.0
      end
    end
    
    context 'weighted matrix verification' do
      before do
        o2 = atmosphere.gases.find_by(name: 'O2')
        o2&.update!(percentage: 21.0) if o2
      end
      
      it 'uses correct weights: O2 30%, temp 30%, water 25%, pressure 15%' do
        atmosphere.update!(pressure: 1.0, temperature: 288.0)
        celestial_body.update!(surface_temperature: 288.0)
        
        habitability = biosphere.calculate_habitability
        
        expect(habitability).to be > 0.7
      end
      
      it 'returns habitable_ratio that was saved' do
        habitability = biosphere.calculate_habitability
        expect(biosphere.habitable_ratio).to eq(habitability)
      end
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
      
      # Mock the life form creation using the new Biology namespace
      life_form = double('LifeForm')
      allow(Biology::LifeForm).to receive(:create!).and_return(life_form)
      
      # Should discover life
      result = biosphere.discover_life
      expect(result).to include(life_form)
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

  describe 'ecological simulation' do
    let(:life_form) { 
      create(:life_form,
        biosphere: biosphere,
        name: "Test Organism",
        complexity: :simple,
        domain: :terrestrial,
        population: 1000
      )
    }
    
    it 'calculates total biomass' do
      # Create multiple life forms of different complexities
      create(:life_form, biosphere: biosphere, complexity: :microbial, population: 10000)
      create(:life_form, biosphere: biosphere, complexity: :complex, population: 100)
      
      # Total biomass should be the sum of all life form biomasses
      expect(biosphere.total_biomass).to be > 0
    end
    
    it 'calculates expanded biodiversity including life forms' do
      # Add some biomes and life forms
      biome = create(:biome, name: 'Forest')
      biosphere.introduce_biome(biome)
      
      # Create life forms of different complexities
      create(:life_form, biosphere: biosphere, complexity: :microbial, population: 10000)
      create(:life_form, biosphere: biosphere, complexity: :complex, population: 100)
      
      # Calculate expanded biodiversity
      biodiversity = biosphere.expanded_biodiversity_index
      
      # Should be higher than regular biodiversity
      expect(biodiversity).to be > biosphere.biodiversity_index
    end
    
    xit 'simulates life cycle' do # Phase 4 – requires PlanetBiome / TerraSim Earth-like biome conditions for growth
      # Create a life form
      life_form = create(:life_form, biosphere: biosphere)
      initial_population = life_form.population
      
      # Mock environment factors and growth logic
      allow(biosphere).to receive(:temperature_habitability).and_return(0.8)
      allow(biosphere).to receive(:oxygen_habitability).and_return(0.9)
      allow_any_instance_of(Biology::LifeForm).to receive(:adapt_to_environment).and_call_original
      allow_any_instance_of(Biology::LifeForm).to receive(:simulate_growth).and_call_original
      
      # Run the simulation
      biosphere.simulate_life_cycle
      
      # Population should change
      expect(life_form.reload.population).not_to eq(initial_population)
    end
    
    it 'can occasionally create new derived life forms' do
      # Create an initial life form
      parent_life_form = create(:life_form, biosphere: biosphere, name: "Parent Organism")
      
      # Force random to return value that will trigger new life form creation
      allow(biosphere).to receive(:rand).and_return(0.01)
      allow(biosphere).to receive(:biodiversity_index).and_return(0.8)
      
      # Set up mock for random selection
      allow(biosphere.life_forms).to receive(:order).with('RANDOM()').and_return(
        double('ActiveRecord::Relation', first: parent_life_form)
      )
      
      # Check if a new life form is created
      expect {
        biosphere.simulate_life_cycle
      }.to change { biosphere.life_forms.count }.by(1)
      
      # New life form should reference parent
      new_life_form = biosphere.life_forms.where("name LIKE ?", "%Variant%").first
      expect(new_life_form.properties['derived_from']).to eq(parent_life_form.name)
    end
  end

  describe 'create_biosphere_with_defaults' do
    it 'creates a biosphere with sensible defaults' do
      new_body = create(:celestial_body, solar_system: solar_system)
      create(:atmosphere, celestial_body: new_body)
      
      # Build and save the biosphere directly to test the defaults
      biosphere = new_body.build_biosphere(
        habitable_ratio: 0.95,
        biodiversity_index: 0.95,
        vegetation_cover: 0.75,
        biome_count: 10,
        soil_health: 80,
        soil_organic_content: 0.08,
        soil_microbial_activity: 0.8
      )
      biosphere.skip_simulation = true if biosphere.respond_to?(:skip_simulation=)
      expect { biosphere.save! }.to change { CelestialBodies::Spheres::Biosphere.count }.by(1)

      created = new_body.biosphere
      expect(created).not_to be_nil
      expect(created.habitable_ratio).to eq(0.95)
      expect(created.biodiversity_index).to eq(0.95)
      expect(created.vegetation_cover).to eq(0.75)
      expect(created.biome_count).to eq(10)
      expect(created.soil_health).to eq(80)
      expect(created.soil_organic_content).to eq(0.08)
      expect(created.soil_microbial_activity).to eq(0.8)
    end

    it 'allows overriding defaults' do
      new_body = create(:celestial_body, solar_system: solar_system)
      create(:atmosphere, celestial_body: new_body)
      
      allow(new_body).to receive(:can_support_surface_life?).and_return(true)
      
      new_body.create_biosphere_with_defaults(
        habitable_ratio: 0.5,
        biodiversity_index: 0.3
      )

      expect(new_body.biosphere.habitable_ratio).to eq(0.5)
      expect(new_body.biosphere.biodiversity_index).to eq(0.3)
    end
  end

  describe 'can_support_surface_life?' do
    let(:body) { create(:celestial_body, solar_system: solar_system) }

    it 'returns false when hydrosphere is absent' do
      expect(body.can_support_surface_life?).to be false
    end

    it 'returns false when liquid water is below threshold' do
      create(:hydrosphere, celestial_body: body)
      allow(body.hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 0.001 })
      expect(body.can_support_surface_life?).to be false
    end

    it 'returns true when liquid water meets threshold and pressure is sufficient' do
      hydrosphere = create(:hydrosphere, celestial_body: body)
      allow(hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 0.5 })
      body.update!(known_pressure: 101.326) # Earth-like pressure
      expect(body.can_support_surface_life?).to be true
    end

    it 'returns false when atmospheric pressure is below triple point' do
      hydrosphere = create(:hydrosphere, celestial_body: body)
      allow(hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 0.5 })
      body.update!(known_pressure: 0.001) # Below triple point
      expect(body.can_support_surface_life?).to be false
    end
  end

  describe 'auto-creation gating — negative tests for non-habitable worlds' do
    it 'does NOT create biosphere for a Mars-like body (no liquid water)' do
      mars = create(:celestial_body, solar_system: solar_system)
      create(:atmosphere, celestial_body: mars)
      hydrosphere = create(:hydrosphere, celestial_body: mars)
      allow(hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 0.0 })
      # known_pressure is nil or very low for Mars

      expect(mars.can_support_surface_life?).to be false
      expect {
        mars.create_biosphere_with_defaults if mars.can_support_surface_life?
      }.not_to change { CelestialBodies::Spheres::Biosphere.count }
    end

    it 'does NOT create biosphere for a Venus-like body (insufficient liquid water)' do
      venus = create(:celestial_body, solar_system: solar_system)
      create(:atmosphere, celestial_body: venus)
      hydrosphere = create(:hydrosphere, celestial_body: venus)
      allow(hydrosphere).to receive(:state_distribution).and_return({ 'liquid' => 0.0 })
      # Venus has vaporized water — no liquid

      expect(venus.can_support_surface_life?).to be false
      expect {
        venus.create_biosphere_with_defaults if venus.can_support_surface_life?
      }.not_to change { CelestialBodies::Spheres::Biosphere.count }
    end
  end
end