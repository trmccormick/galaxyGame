# spec/models/biomass_recycler_spec.rb
require 'rails_helper'

RSpec.describe Units::BiomassRecycler, type: :model do
  let(:biomass_recycler) do
    BiomassRecycler.new(
      name: 'Basic Biomass Recycler',
      material_list: { 'biomass' => 50, 'fertilizer_output' => 10, 'biofuel_output' => 5 },
      energy_cost: 20  # Updated to use energy_cost
    )
  end

  let(:available_resources) do
    { 'biomass' => 100, 'energy' => 50, 'fertilizer' => 0, 'biofuel' => 0 }  # Updated to use energy
  end

  describe '#operate' do
    it 'consumes biomass and energy, producing fertilizer and biofuel' do
      expect(biomass_recycler.operate(available_resources)).to be_truthy
      expect(available_resources['biomass']).to eq(50)
      expect(available_resources['energy']).to eq(30)  # Updated to check energy
      expect(available_resources['fertilizer']).to eq(10)
      expect(available_resources['biofuel']).to eq(5)
    end

    it 'returns false if insufficient biomass is available' do
      available_resources['biomass'] = 20
      expect(biomass_recycler.operate(available_resources)).to be_falsey
    end

    it 'returns false if insufficient energy is available' do
      available_resources['energy'] = 10  # Updated to check energy
      expect(biomass_recycler.operate(available_resources)).to be_falsey
    end
  end
end

