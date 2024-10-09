# spec/models/storage/base_storage_spec.rb
require 'rails_helper'

RSpec.describe Storage::BaseStorage, type: :model do
  let(:base_storage) { Storage::BaseStorage.new(100, 'Material') }

  describe '#add_item' do
    it 'adds item successfully' do
      item = double('Item', name: 'Iron', quantity: 0)
      expect(base_storage.add_item(item, 50)).to eq('50 Iron added to storage.')
      expect(base_storage.current_stock).to eq(50)
    end

    it 'fails to add item if not enough capacity' do
      base_storage.current_stock = 90
      item = double('Item', name: 'Iron', quantity: 0)
      expect(base_storage.add_item(item, 20)).to eq('Not enough capacity to add 20 Iron.')
    end
  end

  describe '#remove_item' do
    it 'removes item successfully' do
      item = double('Item', name: 'Iron', quantity: 20)
      base_storage.add_item(item, 50)
      expect(base_storage.remove_item('Iron', 20)).to eq('20 Iron removed from storage.')
      expect(base_storage.current_stock).to eq(30)
    end

    it 'fails to remove item if not enough available' do
      item = double('Item', name: 'Iron', quantity: 10)
      base_storage.add_item(item, 50)
      expect(base_storage.remove_item('Iron', 100)).to eq('Not enough Iron available.')
    end
  end
end
