require 'rails_helper'

RSpec.describe Logistics::Provider, type: :model do
  describe '#normalized_capabilities' do
    it 'returns array of strings when capabilities is a Ruby array' do
      provider = described_class.new(capabilities: ['orbital_transfer', 'surface_conveyance'])
      expect(provider.normalized_capabilities).to eq(['orbital_transfer', 'surface_conveyance'])
    end

    it 'returns array of strings when capabilities is a JSON string' do
      provider = described_class.new(capabilities: '["orbital_transfer"]')
      expect(provider.normalized_capabilities).to eq(['orbital_transfer'])
    end

    it 'returns array of strings when capabilities is a plain string' do
      provider = described_class.new(capabilities: 'orbital_transfer')
      expect(provider.normalized_capabilities).to eq(['orbital_transfer'])
    end

    it 'returns empty array when capabilities is nil' do
      provider = described_class.new(capabilities: nil)
      expect(provider.normalized_capabilities).to eq([])
    end

    it 'returns empty array when capabilities is an empty array' do
      provider = described_class.new(capabilities: [])
      expect(provider.normalized_capabilities).to eq([])
    end
  end
end
