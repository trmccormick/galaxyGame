# spec/models/biogas_generator_spec.rb
require 'rails_helper'

RSpec.describe Units::BiogasGenerator, type: :model do
  let(:biogas_generator) do
    BiogasGenerator.new(
      name: 'Basic Biogas Generator',
      material_list: { 'biomass' => 20, 'organic_waste' => 20, 'biogas_output' => 10, 'fertilizer_output' => 5 },
      energy_cost: 15  # Updated to use energy_cost
    )
  end

  let(:available_resources) do
    { 'biomass' => 40, 'organic_waste' => 40, 'energy' => 50, 'biogas' => 0, 'fertilizer' => 0 }  # Updated to use energy
  end

  describe '#operate' do
    it 'consumes biomass, organic waste, and energy, producing biogas and fertilizer' do
      expect(biogas_generator.operate(available_resources)).to be_truthy
      expect(available_resources['biomass']).to eq(20)
      expect(available_resources['organic_waste']).to eq(20)
      expect(available_resources['energy']).to eq(35)  # Updated to check energy
      expect(available_resources['biogas']).to eq(10)
      expect(available_resources['fertilizer']).to eq(5)
    end

    it 'returns false if insufficient biomass is available' do
      available_resources['biomass'] = 10
      expect(biogas_generator.operate(available_resources)).to be_falsey
    end

    it 'returns false if insufficient organic waste is available' do
      available_resources['organic_waste'] = 10
      expect(biogas_generator.operate(available_resources)).to be_falsey
    end

    it 'returns false if insufficient energy is available' do
      available_resources['energy'] = 5  # Updated to check energy
      expect(biogas_generator.operate(available_resources)).to be_falsey
    end
  end
end

