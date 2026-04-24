require 'rails_helper'

describe EmHarvestingService do
  let(:target) { double('Target', flux: 100, dual_connection?: false) }

  let(:satellite) { double('Infra', id: 'wormhole_stabilization_satellite_mk1', efficiency: 0.8, capacity: 50, operational?: true, positioned?: true) }
  let(:nwa) { double('Infra', id: 'natural_wormhole_anchor_mk1h', efficiency: 0.9, capacity: 100, operational?: true, positioned?: true) }
  let(:aws) { double('Infra', id: 'artificial_wormhole_station_alpha', efficiency: 1.0, capacity: 200, operational?: true, positioned?: true) }
  let(:mid_skimmer) { double('Infra', id: 'orbital_em_skimmer_mid', efficiency: 0.7, capacity: 80, operational?: true, positioned?: true) }

  it 'calculates satellite yield' do
    service = described_class.new(infrastructure: satellite, target: target)
    expect(service.harvest_cycle).to eq(0.8 * 50 * 100)
  end

  it 'calculates NWA yield' do
    service = described_class.new(infrastructure: nwa, target: target)
    expect(service.harvest_cycle).to eq(0.9 * 100 * 100)
  end

  it 'calculates AWS yield' do
    service = described_class.new(infrastructure: aws, target: target)
    expect(service.harvest_cycle).to eq(1.0 * 200 * 100)
  end

  it 'calculates mid-skimmer yield' do
    service = described_class.new(infrastructure: mid_skimmer, target: target)
    expect(service.harvest_cycle).to eq(0.7 * 80 * 100)
  end

  it 'applies dual connection bonus' do
    dual_target = double('Target', flux: 100, dual_connection?: true)
    service = described_class.new(infrastructure: aws, target: dual_target)
    expect(service.harvest_cycle).to eq(1.0 * 200 * 100 * 2.5)
  end

  it 'returns 0 if not operational' do
    bad_sat = double('Infra', id: 'wormhole_stabilization_satellite_mk1', efficiency: 0.8, capacity: 50, operational?: false, positioned?: true)
    service = described_class.new(infrastructure: bad_sat, target: target)
    expect(service.harvest_cycle).to eq(0)
  end

  it 'returns 0 if not positioned' do
    bad_sat = double('Infra', id: 'wormhole_stabilization_satellite_mk1', efficiency: 0.8, capacity: 50, operational?: true, positioned?: false)
    service = described_class.new(infrastructure: bad_sat, target: target)
    expect(service.harvest_cycle).to eq(0)
  end
end
