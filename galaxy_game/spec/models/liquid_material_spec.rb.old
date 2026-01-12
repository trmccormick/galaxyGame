require 'rails_helper'

RSpec.describe LiquidMaterial, type: :model do
  let(:hydrosphere) { create(:hydrosphere) }

  subject(:liquid_material) { LiquidMaterial.new(name: 'Methane', amount: 500.0, hydrosphere: hydrosphere) }

  describe 'associations' do
    it { is_expected.to belong_to(:hydrosphere) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(liquid_material).to be_valid
    end

    it 'is not valid without a name' do
      liquid_material.name = nil
      expect(liquid_material).not_to be_valid
      expect(liquid_material.errors.messages[:name]).to include("can't be blank")
    end

    it 'is not valid without an amount' do
      liquid_material.amount = nil
      expect(liquid_material).not_to be_valid
      expect(liquid_material.errors.messages[:amount]).to include("can't be blank")
    end

    it 'is not valid with a negative amount' do
      liquid_material.amount = -1.0
      expect(liquid_material).not_to be_valid
      expect(liquid_material.errors.messages[:amount]).to include('must be greater than or equal to 0')
    end
  end
end

