require 'rails_helper'

RSpec.describe AIManager::SkimmerCyclerHandshakeService, type: :service do
  let(:service) { described_class.new }

  let(:cycler) do
    FactoryBot.create(:base_craft,
      craft_name: 'Long-Hull Cycler',
      operational_data: {
        'chassis' => 'long_hull',
        'roles' => ['cycler'],
        'panel_config' => 'i_beam_adapter',
        'units' => [{ 'id' => 'docking_hub', 'count' => 1 }],
        'processing_capabilities' => {
          'atmospheric_processing' => { 'enabled' => true, 'types' => ['gas_conversion'] }
        },
        'energy_reserve' => 500
      }
    )
  end

  let(:skimmer) do
    FactoryBot.create(:base_craft,
      craft_name: 'Standard Skimmer',
      operational_data: {
        'variant' => 'standard_skimmer',
        'panel_config' => 'i_beam_adapter',
        'raw_cargo' => { 'methane' => 50, 'nitrogen' => 30 },
        'available' => false
      }
    )
  end

  describe 'I-Beam Docking Adapter capability' do
    it 'allows docking if both crafts have I-Beam panel config and cycler has docking hub' do
      expect(service.dock_skimmer(skimmer, cycler)).to eq(true)
      expect(cycler.docked_at).to eq(skimmer)
    end
    it 'prevents docking if panel configs do not match' do
      skimmer.operational_data['panel_config'] = 'solar_adapter'
      expect(service.dock_skimmer(skimmer, cycler)).to eq(false)
    end
    it 'prevents docking if cycler lacks docking hub' do
      cycler.operational_data['units'] = []
      expect(service.dock_skimmer(skimmer, cycler)).to eq(false)
    end
  end

  describe 'In-route gas processing (Dump and Dive loop)' do
    before { service.dock_skimmer(skimmer, cycler) }
    it 'processes skimmer raw gas, empties cargo, and marks skimmer available' do
      skimmer.raw_cargo = { 'methane' => 50, 'nitrogen' => 30 }
      expect(service.process_cargo(skimmer, cycler)).to eq(true)
      expect(skimmer.processed_cargo['methane']).to eq(45.0)
      expect(skimmer.processed_cargo['nitrogen']).to eq(27.0)
      expect(skimmer.raw_cargo).to be_empty
      expect(skimmer.available).to eq(true)
      expect(cycler.energy_reserve).to be < 500
    end
    it 'prevents processing if not docked' do
      cycler.docked_at = nil
      expect(service.process_cargo(skimmer, cycler)).to eq(false)
    end
    it 'prevents processing if not enough energy' do
      cycler.energy_reserve = 0
      expect(service.process_cargo(skimmer, cycler)).to eq(false)
    end
    it 'prevents processing if cycler cannot process atmosphere' do
      cycler.operational_data['processing_capabilities']['atmospheric_processing']['enabled'] = false
      expect(service.process_cargo(skimmer, cycler)).to eq(false)
    end
  end
end
