require 'rails_helper'

RSpec.describe Market::Condition, type: :model do
  let(:marketplace) { create(:marketplace) }
  let(:condition) { create(:market_condition, marketplace: marketplace) }

  describe 'associations' do
    it { should belong_to(:marketplace).class_name('Market::Marketplace') }
    it { should have_many(:market_orders).class_name('Market::Order').dependent(:destroy) }
    it { should have_many(:price_histories).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe '#current_price' do
    it 'returns the latest price from price_histories' do
      condition.price_histories.create!(price: 42)
      condition.price_histories.create!(price: 55)
      expect(condition.current_price).to eq(55)
    end

    it 'returns default price if no price_histories exist' do
      expect(condition.current_price).to eq(10)
    end
  end
end