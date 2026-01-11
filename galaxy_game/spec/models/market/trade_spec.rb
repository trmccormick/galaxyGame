require 'rails_helper'

RSpec.describe Market::Trade, type: :model do
  let(:buyer) { create(:player) }
  let(:seller) { create(:player) }
  let(:buyer_settlement) { create(:base_settlement) }
  let(:seller_settlement) { create(:base_settlement) }

  describe 'associations' do
    it { should belong_to(:buyer) }
    it { should belong_to(:seller) }
    it { should belong_to(:buyer_settlement).class_name('Settlement::BaseSettlement') }
    it { should belong_to(:seller_settlement).class_name('Settlement::BaseSettlement') }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      trade = described_class.new(
        buyer: buyer,
        seller: seller,
        buyer_settlement: buyer_settlement,
        seller_settlement: seller_settlement
      )
      expect(trade).to be_valid
    end
  end
end