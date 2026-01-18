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
      # First create a hydrosphere with specific values
      hydrosphere.update!(
        liquid_bodies: { 'oceans' => 100.0, 'lakes' => 50.0, 'rivers' => 25.0 },
        composition: { 'H2O' => 95.0, 'salts' => 5.0 },
        state_distribution: { 'liquid' => 80.0, 'solid' => 15.0, 'vapor' => 5.0 },
        temperature: 300.0,
        pressure: 1.0,
        total_liquid_mass: 1000.0
      )
      
      # Reset
      hydrosphere.reset
      
      # Check that it reverted to base values
      expect(hydrosphere.liquid_bodies).to eq({})
      expect(hydrosphere.composition).to eq({})
      expect(hydrosphere.state_distribution).to eq({ 'liquid' => 0.0, 'solid' => 0.0, 'vapor' => 0.0 })
      expect(hydrosphere.temperature).to eq(0.0)
      expect(hydrosphere.pressure).to eq(0.0)
      expect(hydrosphere.total_liquid_mass).to eq(0.0)
    end
  end

  describe '#add_liquid' do
    it 'adds liquid material to the hydrosphere' do
      expect {
        hydrosphere.add_liquid('water', 100)
      }.to change { hydrosphere.total_liquid_mass }.by(100)
      
      expect(hydrosphere.liquid_materials.find_by(name: 'water').amount).to eq(100)
    end
  end

  describe '#remove_liquid' do
    before do
      hydrosphere.add_liquid('water', 100)
    end
    
    it 'removes liquid material from the hydrosphere' do
      expect {
        hydrosphere.remove_liquid('water', 50)
      }.to change { hydrosphere.total_liquid_mass }.by(-50)
      
      expect(hydrosphere.liquid_materials.find_by(name: 'water').amount).to eq(50)
    end
  end

  describe '#transfer_material' do
    let(:target_sphere) { create(:hydrosphere, celestial_body: celestial_body) }
    
    before do
      hydrosphere.add_liquid('water', 100)
    end
    
    it 'transfers material to another sphere' do
      expect {
        hydrosphere.transfer_material('water', 50, target_sphere)
      }.to change { hydrosphere.liquid_materials.find_by(name: 'water').amount }.by(-50)
      
      expect(target_sphere.materials.find_by(name: 'water').amount).to eq(50)
    end
  end

  describe '#in_ocean?' do
    it 'returns true when there are significant oceans' do
      hydrosphere.update!(liquid_bodies: { 'oceans' => 1.0e16 })
      expect(hydrosphere.in_ocean?).to be true
    end
    
    it 'returns false when there are no significant oceans' do
      hydrosphere.update!(liquid_bodies: { 'oceans' => 1.0e10 })
      expect(hydrosphere.in_ocean?).to be false
    end
  end

  describe '#ice' do
    it 'gets ice from liquid_bodies' do
      hydrosphere.update!(liquid_bodies: { 'ice_caps' => 100.0 })
      expect(hydrosphere.ice).to eq(100.0)
    end
    
    it 'sets ice in liquid_bodies' do
      hydrosphere.ice = 200.0
      hydrosphere.save!
      expect(hydrosphere.liquid_bodies['ice_caps']).to eq(200.0)
    end
  end

  describe '#water_coverage' do
    it 'calculates water coverage percentage' do
      hydrosphere.celestial_body.update!(surface_area: 100.0)
      hydrosphere.update!(water_bodies: { 'oceans' => 25.0, 'lakes' => 25.0, 'rivers' => 25.0 })
      
      expect(hydrosphere.water_coverage).to eq(75.0)
    end
  end
end

