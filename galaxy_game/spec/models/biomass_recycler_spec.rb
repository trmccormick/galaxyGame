
# spec/models/biomass_recycler_spec.rb
require 'rails_helper'

RSpec.describe Units::BaseUnit, type: :model do
  # let(:biomass_recycler) { create(:biomass_recycler) }
  # let(:inventory) { double('Inventory') }

  before do
    allow(biomass_recycler).to receive(:inventory).and_return(inventory)
  end

  describe '#operate' do
    it 'consumes biomass and energy, producing fertilizer and biofuel' do
      allow(inventory).to receive(:consume_materials).with({ 'biomass' => 50 }).and_return(true)
      allow(biomass_recycler).to receive(:sufficient_energy?).and_return(true)
      expect(inventory).to receive(:produce_materials).with({ 'fertilizer' => 10, 'biofuel' => 5 })
      expect(biomass_recycler.operate(inventory)).to be_truthy
    end

    it 'returns false if insufficient biomass is available' do
      allow(inventory).to receive(:consume_materials).with({ 'biomass' => 50 }).and_return(false)
      allow(biomass_recycler).to receive(:sufficient_energy?).and_return(true)
      expect(biomass_recycler.operate(inventory)).to be_falsey
    end

    it 'returns false if insufficient energy is available' do
      allow(inventory).to receive(:consume_materials).with({ 'biomass' => 50 }).and_return(true)
      allow(biomass_recycler).to receive(:sufficient_energy?).and_return(false)
      expect(biomass_recycler.operate(inventory)).to be_falsey
    end
  end
end


