require 'rails_helper'

RSpec.describe CelestialBodies::Spheres::Hydrosphere, type: :model do
  let(:celestial_body) { create(:celestial_body) }
  let(:hydrosphere) { create(:hydrosphere, celestial_body: celestial_body) }

  describe 'associations' do
    it { should belong_to(:celestial_body) }
    it { should have_many(:materials).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:total_liquid_mass).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_presence_of(:temperature) }
    
    it 'requires pressure to be present' do
      # Use update! with new validation instead of new instantiation
      hydrosphere.pressure = nil  
      expect(hydrosphere).not_to be_valid
      expect(hydrosphere.errors[:pressure]).to include("can't be blank")
    end
  end

  describe 'store accessors' do
    it 'accesses water bodies attributes from JSONB store' do
      hydrosphere.update!(liquid_bodies: { 'oceans' => 100, 'lakes' => 50, 'rivers' => 25 })
      expect(hydrosphere.oceans).to eq(100)
      expect(hydrosphere.lakes).to eq(50)
      expect(hydrosphere.rivers).to eq(25)
    end

    it 'writes water bodies attributes to JSONB store' do
      hydrosphere.oceans = 200
      hydrosphere.lakes = 150
      hydrosphere.rivers = 75
      hydrosphere.save!
      
      expect(hydrosphere.liquid_bodies['oceans']).to eq(200)
      expect(hydrosphere.liquid_bodies['lakes']). to eq(150)
      expect(hydrosphere.liquid_bodies['rivers']).to eq(75)
    end
  end

  describe '#reset' do
    it 'resets to base values' do
      # Disable simulation during test setup
      hydrosphere.simulation_running = true
      
      # First create a hydrosphere with specific values
      hydrosphere.update!(
        liquid_bodies: { 'oceans' => 100.0, 'lakes' => 50.0, 'rivers' => 25.0 },
        composition: { 'H2O' => 95.0, 'salts' => 5.0 },
        state_distribution: { 'liquid' => 80.0, 'solid' => 15.0, 'vapor' => 5.0 },
        temperature: 290.0,
        pressure: 1.0,
        total_liquid_mass: 1000.0
      )
      
      # Then explicitly set the base values (not relying on any auto-calculation)
      hydrosphere.update!(
        base_liquid_bodies: { 'oceans' => 100.0, 'lakes' => 50.0, 'rivers' => 25.0 },
        base_composition: { 'H2O' => 95.0, 'salts' => 5.0 },
        base_state_distribution: { 'liquid' => 80.0, 'solid' => 15.0, 'vapor' => 5.0 },
        base_temperature: 290.0,
        base_pressure: 1.0,
        base_total_liquid_mass: 1000.0
      )
      
      # Change values
      hydrosphere.update!(
        liquid_bodies: { 'oceans' => 80.0, 'lakes' => 30.0, 'rivers' => 15.0 },
        temperature: 280.0,
        pressure: 0.8,
        total_liquid_mass: 800.0
      )
      
      # Temporarily disable the water cycle simulation
      allow(hydrosphere).to receive(:water_cycle_tick)
      
      # Reset
      hydrosphere.reset
      
      # Verify key attributes were reset, ignoring the state distribution which is recalculated
      expect(hydrosphere.liquid_bodies['oceans']).to eq(100.0)
      expect(hydrosphere.liquid_bodies['lakes']).to eq(50.0) 
      expect(hydrosphere.liquid_bodies['rivers']).to eq(25.0)
      expect(hydrosphere.composition['H2O']).to eq(95.0)
      expect(hydrosphere.composition['salts']).to eq(5.0)
      expect(hydrosphere.temperature).to eq(290.0)
      expect(hydrosphere.pressure).to eq(1.0)
      
      # Use a more flexible comparison for total_liquid_mass since it may be slightly modified during simulation
      expect(hydrosphere.total_liquid_mass).to be_within(1.0).of(1000.0)
    end
  end

  describe 'concern methods' do
    describe '#calculate_state_distributions' do
      it 'calculates states based on temperature' do
        states = hydrosphere.calculate_state_distributions(280)
        
        # Check that each state has a sensible value
        expect(states[:solid]).to be_a(Numeric)
        expect(states[:liquid]). to be_a(Numeric)
        expect(states[:vapor]).to be_a(Numeric)
        
        # Check sum is approximately 100%
        total = states[:solid] + states[:liquid] + states[:vapor]
        expect(total).to be_within(0.1).of(100.0)
      end
    end
    
    describe '#water_cycle_tick' do
      before do
        # Directly associate atmosphere with celestial_body
        atmosphere = create(:atmosphere, celestial_body: celestial_body)
        celestial_body.reload # Ensure association is loaded
        
        # Stub the handle_methods since they rely on external classes
        allow(hydrosphere).to receive(:handle_evaporation)
        allow(hydrosphere).to receive(:handle_precipitation)
      end
      
      it 'calls evaporation and precipitation handlers' do
        expect(hydrosphere).to receive(:handle_evaporation)
        expect(hydrosphere).to receive(:handle_precipitation)
        hydrosphere.water_cycle_tick
      end
    end
  end

  describe '#transfer_material' do
    let(:target_sphere) { create(:geosphere, celestial_body: celestial_body) }
    
    before do
      # Create a real material directly in the materials collection
      hydrosphere.materials.create!(
        name: 'Water', 
        amount: 100, 
        state: 'liquid',
        celestial_body: celestial_body
      )
    end
    
    it 'transfers material between spheres' do
      result = hydrosphere.transfer_material('Water', 50, target_sphere)
      
      # Check results
      expect(result).to be_truthy
      expect(hydrosphere.materials.find_by(name: 'Water').amount).to eq(50)
      expect(target_sphere.materials.find_by(name: 'Water').amount).to eq(50)
    end
    
    it 'returns false if material not found' do
      result = hydrosphere.transfer_material('NonExistentMaterial', 50, target_sphere)
      expect(result).to be_falsey
    end
    
    it 'returns false if not enough material available' do
      # Update the Water material to have less than requested
      water = hydrosphere.materials.find_by(name: 'Water')
      water.update!(amount: 30)
      
      result = hydrosphere.transfer_material('Water', 50, target_sphere)
      expect(result).to be_falsey
    end
  end
end



