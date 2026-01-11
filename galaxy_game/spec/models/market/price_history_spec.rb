require 'rails_helper'

RSpec.describe Market::PriceHistory, type: :model do
  let(:marketplace) { create(:marketplace) }
  let(:market_condition) { create(:market_condition, marketplace: marketplace) }

  describe 'associations' do
    it { should belong_to(:market_condition).class_name('Market::Condition') }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      price_history = described_class.new(
        market_condition: market_condition,
        price: 100
      )
      expect(price_history).to be_valid
    end

    it 'is not valid without a price' do
      price_history = described_class.new(
        market_condition: market_condition,
        price: nil
      )
      expect(price_history).not_to be_valid
    end
  end
end