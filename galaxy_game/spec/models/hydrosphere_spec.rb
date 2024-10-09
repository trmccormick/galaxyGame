require 'rails_helper'

RSpec.describe CelestialBodies::Hydrosphere, type: :model do
  let(:celestial_body) { create(:celestial_body) } # Assuming you have a celestial_body factory
  let(:hydrosphere) { create(:celestial_bodies_hydrosphere, celestial_body: celestial_body) }

  describe 'associations' do
    it { should belong_to(:celestial_body) }
    it { should have_many(:liquid_materials).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:liquid_volume) }
    it { should validate_numericality_of(:lakes) }
    it { should validate_numericality_of(:rivers) }
    it { should validate_numericality_of(:oceans) }
    it { should validate_numericality_of(:ice) }
  end

  describe '#setup_liquid_materials' do
    before do
      hydrosphere.setup_liquid_materials
    end

    it 'calls update_liquid_materials_from_celestial_body' do
      expect(hydrosphere).to receive(:update_liquid_materials_from_celestial_body)
      hydrosphere.setup_liquid_materials
    end

    it 'calculates the liquid volume after setup' do
      expect(hydrosphere.liquid_volume).to be > 0
    end
  end

  describe '#update_liquid_materials_from_celestial_body' do
    let!(:water) { create(:material, state: 'liquid', amount: 100) } # Assuming you have a material factory
    let!(:ice) { create(:material, state: 'solid', amount: 50) }

    before do
      celestial_body.materials << water
      celestial_body.materials << ice
      hydrosphere.update_liquid_materials_from_celestial_body
    end

    it 'adds liquid materials to the hydrosphere' do
      expect(hydrosphere.liquid_materials.count).to eq(1) # Only liquid water
    end

    it 'adds ice to the hydrosphere' do
      expect(hydrosphere.ice).to eq(50)
    end
  end

  describe '#add_liquid' do
    let(:liquid_material) { create(:material, state: 'liquid', amount: 100) }

    it 'distributes liquid between oceans, lakes, and rivers' do
      expect { hydrosphere.add_liquid(liquid_material) }.to change { hydrosphere.oceans }.by(70)
      expect { hydrosphere.add_liquid(liquid_material) }.to change { hydrosphere.lakes }.by(20)
      expect { hydrosphere.add_liquid(liquid_material) }.to change { hydrosphere.rivers }.by(10)
    end
  end

  describe '#calculate_liquid_volume' do
    it 'calculates the total liquid volume correctly' do
      hydrosphere.oceans = 100
      hydrosphere.lakes = 50
      hydrosphere.rivers = 30
      hydrosphere.ice = 20

      hydrosphere.calculate_liquid_volume

      expect(hydrosphere.liquid_volume).to eq(200)
    end
  end

  describe '#update_water_cycle' do
    before do
      allow(hydrosphere).to receive(:current_temperature).and_return(300) # Above freezing
      hydrosphere.ice = 100
      hydrosphere.update_water_cycle
    end

    it 'melts ice when temperature is above freezing' do
      expect(hydrosphere.oceans).to be > 0
      expect(hydrosphere.ice).to be < 100
    end

    it 'does not melt ice when temperature is below freezing' do
      allow(hydrosphere).to receive(:current_temperature).and_return(250)
      hydrosphere.update_water_cycle
      expect(hydrosphere.oceans).to eq(0)
      expect(hydrosphere.ice).to eq(100)
    end
  end

  describe '#evaporate_liquids' do
    before do
      hydrosphere.oceans = 100
      hydrosphere.lakes = 50
      hydrosphere.rivers = 30
      allow(hydrosphere).to receive(:evaporation_condition_met?).and_return(true)
    end

    it 'evaporates liquids when conditions are met' do
      expect { hydrosphere.evaporate_liquids }.to change { hydrosphere.oceans }.by(-70)
      expect { hydrosphere.evaporate_liquids }.to change { hydrosphere.lakes }.by(-20)
      expect { hydrosphere.evaporate_liquids }.to change { hydrosphere.rivers }.by(-10)
    end
  end
end

