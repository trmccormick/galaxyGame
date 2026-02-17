require 'rails_helper'
require 'cycler'

RSpec.describe AIManager::SkimmerCyclerHandshakeService, type: :service do
  let(:service) { described_class.new }
  let(:cycler) { Cycler.new(docking_capacity: 2, processing_power: 100, energy_reserve: 500, panel_config: :rugged) }
  let(:skimmer) { { panel_config: :rugged, raw_cargo: { methane: 50, nitrogen: 30 } } }

  describe '#dock_skimmer' do
    it 'docks a compatible skimmer if capacity allows' do
      expect(service.dock_skimmer(skimmer, cycler)).to eq(true)
      expect(cycler.docked_skimmers).to include(skimmer)
    end
    it 'does not dock if panel configs do not match' do
      skimmer[:panel_config] = :solar
      expect(service.dock_skimmer(skimmer, cycler)).to eq(false)
    end
    it 'does not dock if capacity is full' do
      2.times { service.dock_skimmer(skimmer.dup, cycler) }
      expect(service.dock_skimmer(skimmer, cycler)).to eq(false)
    end
  end

  describe '#process_cargo' do
    before { service.dock_skimmer(skimmer, cycler) }
    it 'processes skimmer cargo using cycler energy' do
      expect(service.process_cargo(skimmer, cycler)).to eq(true)
      expect(skimmer[:processed_cargo][:methane]).to eq(45.0)
      expect(skimmer[:processed_cargo][:nitrogen]).to eq(27.0)
      expect(skimmer[:raw_cargo]).to be_empty
      expect(cycler.energy_reserve).to be < 500
    end
    it 'does not process if not docked' do
      cycler.undock(skimmer)
      expect(service.process_cargo(skimmer, cycler)).to eq(false)
    end
    it 'does not process if not enough energy' do
      cycler.energy_reserve = 0
      expect(service.process_cargo(skimmer, cycler)).to eq(false)
    end
  end
end
