require 'rails_helper'

RSpec.describe AIManager::AtmosphericHarvesterService, type: :service do
  let(:service) { described_class.new }

  describe '#venus_harvest' do
    let(:venus) { {} }
    it 'imports H2 and produces methane, reducing fuel imports' do
      result = service.venus_harvest(venus)
      expect(result[:h2_imported]).to eq(100)
      expect(result[:methane_produced]).to eq(80.0)
      expect(venus[:fuel_imports_reduced]).to eq(true)
    end
  end

  describe '#titan_harvest' do
    let(:titan) { {} }
    it 'collects nitrogen and methane' do
      result = service.titan_harvest(titan)
      expect(result[:nitrogen]).to eq(200)
      expect(result[:methane]).to eq(150)
    end
  end

  describe '#skimmer_docking' do
    let(:skimmer) { { docking_port: true, panel_config: :solar, cargo: { methane: 50 } } }
    let(:cycler) { { docking_port: true, panel_config: :solar, cargo: {} } }
    let(:gases) { { methane: 50 } }
    it 'transfers gases from skimmer to cycler if dockable' do
      result = service.skimmer_docking(skimmer, cycler, gases)
      expect(result).to eq(true)
      expect(cycler[:cargo][:methane]).to eq(50)
      expect(skimmer[:cargo]).to eq({})
    end
    it 'fails if panel configs do not match' do
      cycler[:panel_config] = :rugged
      result = service.skimmer_docking(skimmer, cycler, gases)
      expect(result).to eq(false)
    end
  end

  describe '#mark_exportable_surplus' do
    let(:depot) { { reserve: 25, capacity: 100 } }
    it 'marks depot as exportable surplus if reserve > 20%' do
      service.mark_exportable_surplus(depot)
      expect(depot[:exportable_surplus]).to eq(true)
    end
    it 'does not mark as exportable if reserve <= 20%' do
      depot[:reserve] = 20
      service.mark_exportable_surplus(depot)
      expect(depot[:exportable_surplus]).to eq(false)
    end
  end
end
