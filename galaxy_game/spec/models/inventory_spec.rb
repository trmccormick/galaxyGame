require 'rails_helper'

RSpec.describe Inventory, type: :model do
  let(:colony) { create(:colony) }
  let(:inventory) { create(:inventory, name: 'Iron', quantity: 500, material_type: 'raw_material', colony: colony) }
  let(:buyer_colony) { create(:colony) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(inventory).to be_valid
    end

    it 'is invalid without a name' do
      inventory.name = nil
      expect(inventory).to_not be_valid
    end

    it 'is invalid with a negative quantity' do
      inventory.quantity = -10
      expect(inventory).to_not be_valid
    end
  end

  describe '#tradeable?' do
    it 'returns true when quantity is greater than 0' do
      expect(inventory.tradeable?).to be_truthy
    end

    it 'returns false when quantity is 0' do
      inventory.quantity = 0
      expect(inventory.tradeable?).to be_falsey
    end
  end

  describe '#add_quantity' do
    it 'increases the quantity by the given amount' do
      inventory.add_quantity(100)
      expect(inventory.quantity).to eq(600)
    end
  end

  describe '#remove_quantity' do
    it 'decreases the quantity by the given amount if enough inventory is available' do
      expect(inventory.remove_quantity(100)).to be_truthy
      expect(inventory.quantity).to eq(400)
    end

    it 'does not decrease quantity if not enough inventory is available' do
      expect(inventory.remove_quantity(600)).to be_falsey
      expect(inventory.quantity).to eq(500)
    end
  end

  describe '#dynamic_price' do
    it 'returns a price using the TradeService' do
      trade_service = instance_double('TradeService')
      allow(TradeService).to receive(:new).with(inventory, buyer_colony).and_return(trade_service)
      allow(trade_service).to receive(:dynamic_price).and_return(100.0)

      expect(inventory.dynamic_price(buyer_colony)).to eq(100.0)
    end

    it 'handles errors when TradeService is unavailable' do
      allow(TradeService).to receive(:new).with(inventory, buyer_colony).and_raise(StandardError.new('Service unavailable'))

      expect { inventory.dynamic_price(buyer_colony) }.to raise_error(StandardError, 'Service unavailable')
    end
  end
end

