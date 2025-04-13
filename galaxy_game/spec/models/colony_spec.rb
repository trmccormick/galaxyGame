# spec/models/colony_spec.rb
require 'rails_helper'

RSpec.describe Colony, type: :model do
  let(:colony) { create(:colony, :with_multiple_settlements) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(colony).to be_valid
    end

    it 'requires at least two settlements' do
      new_colony = build(:colony)
      new_colony.settlements = [build(:base_settlement)]
      expect(new_colony).not_to be_valid
      expect(new_colony.errors[:base]).to include("Colony must have at least two settlements")
    end
  end

  describe 'associations' do
    it 'has multiple settlements' do
      expect(colony.settlements.count).to eq(2)
    end

    it 'has an account' do
      expect(colony.account).to be_present
    end

    it 'has an inventory' do
      expect(colony.inventory).to be_present
    end
  end

  describe 'population calculations' do
    it 'calculates total population' do
      total = colony.settlements.sum(:current_population)
      expect(colony.total_population).to eq(total)
    end
  end
end
