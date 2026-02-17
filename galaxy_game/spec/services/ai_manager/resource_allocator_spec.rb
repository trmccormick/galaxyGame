require 'rails_helper'

RSpec.describe AIManager::ResourceAllocator, type: :service do
  let(:allocator) { described_class.new(settlement_size: 'small') }

  describe '#initial_resource_package' do
    it 'returns correct 30-day supply for a small settlement' do
      package = allocator.initial_resource_package
      expect(package[:energy]).to eq(3000)
      expect(package[:water]).to eq(900)
      expect(package[:food]).to eq(600)
      expect(package[:construction]).to eq(2000)
    end
  end

  describe '#isru_priority_list' do
    it 'ranks oxygen and water as top priorities' do
      priorities = allocator.isru_priority_list
      expect(priorities.first[:resource]).to eq('oxygen')
      expect(priorities.second[:resource]).to eq('water')
      expect(priorities.first[:timeline]).to eq(60)
      expect(priorities.second[:timeline]).to eq(90)
    end
  end
end
