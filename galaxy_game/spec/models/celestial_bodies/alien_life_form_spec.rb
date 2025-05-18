require 'rails_helper'

RSpec.describe CelestialBodies::AlienLifeForm, type: :model do
  describe 'associations' do
    it { should belong_to(:biosphere).class_name('CelestialBodies::Spheres::Biosphere') }
  end

  describe 'enums' do
    it { should define_enum_for(:complexity).with_values([:microbial, :simple, :complex, :intelligent]) }
    it { should define_enum_for(:domain).with_values([:aquatic, :terrestrial, :aerial, :subterranean]) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:population).is_greater_than_or_equal_to(0) }
  end

  describe 'store_accessors' do
    it 'should define store accessors for description, biochemistry, and ecological_role' do
      alien_life_form = CelestialBodies::AlienLifeForm.new
      expect(alien_life_form).to respond_to(:description)
      expect(alien_life_form).to respond_to(:description=)
      expect(alien_life_form).to respond_to(:biochemistry)
      expect(alien_life_form).to respond_to(:biochemistry=)
      expect(alien_life_form).to respond_to(:ecological_role)
      expect(alien_life_form).to respond_to(:ecological_role=)
    end
  end

  describe '#simulate_growth' do
    # Create a solar system and celestial body first
    let(:solar_system) { create(:solar_system) }
    let(:celestial_body) { create(:celestial_body, solar_system: solar_system) }
    let(:biosphere) { create(:biosphere, celestial_body: celestial_body, habitable_ratio: 0.8) }
    let(:alien_life_form) do 
      CelestialBodies::AlienLifeForm.create(
        biosphere: biosphere,
        name: 'Test Alien',
        population: 100,
        complexity: :simple
      )
    end

    it 'should update the population based on growth rate' do
      expect {
        alien_life_form.simulate_growth
      }.to change { alien_life_form.population }.to(96) # 100 * 1.2 * 0.8 = 96
    end

    it 'should save the updated population' do
      alien_life_form.simulate_growth
      expect(alien_life_form.reload.population).to eq(96)
    end
  end
end