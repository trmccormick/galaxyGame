
require 'rails_helper'
require_relative '../../../app/services/logistics/isru_capability_manager'

describe Logistics::ISRUCapabilityManager do
  let(:settlement) { double('Settlement') }

  it 'returns true if O2 extraction and power are present' do
    allow(settlement).to receive(:operational_data).and_return({ 'isru' => { 'o2_extraction' => true }, 'power_grid' => { 'status' => 'online' } })
    expect(described_class.has_basic_isru?(settlement)).to be true
    expect(described_class.missing_for_survival(settlement)).to be_empty
  end

  it 'returns false if O2 extraction is missing' do
    allow(settlement).to receive(:operational_data).and_return({ 'isru' => { 'o2_extraction' => false }, 'power_grid' => { 'status' => 'online' } })
    expect(described_class.has_basic_isru?(settlement)).to be false
    expect(described_class.missing_for_survival(settlement)).to include('O2 extraction')
  end

  it 'returns false if power is offline' do
    allow(settlement).to receive(:operational_data).and_return({ 'isru' => { 'o2_extraction' => true }, 'power_grid' => { 'status' => 'offline' } })
    expect(described_class.has_basic_isru?(settlement)).to be false
    expect(described_class.missing_for_survival(settlement)).to include('Power')
  end

  it 'returns both missing if neither present' do
    allow(settlement).to receive(:operational_data).and_return({ 'isru' => { 'o2_extraction' => false }, 'power_grid' => { 'status' => 'offline' } })
    expect(described_class.has_basic_isru?(settlement)).to be false
    expect(described_class.missing_for_survival(settlement)).to include('O2 extraction', 'Power')
  end
end
