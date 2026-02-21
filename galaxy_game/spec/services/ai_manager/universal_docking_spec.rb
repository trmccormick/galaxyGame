require 'rails_helper'

RSpec.describe AIManager::UniversalDockingService, type: :service do
  let(:service) { described_class.new }

  let(:skimmer) do
    FactoryBot.create(:base_craft,
      craft_name: 'Standard Skimmer',
      current_population: 2,
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 2,
        'velocity' => 100
      }
    )
  end

  let(:orbital_depot) do
    FactoryBot.create(:base_craft,
      craft_name: 'Orbital Depot',
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'can_process_volatiles' => true,
        'crew_count' => 10,
        'velocity' => 200
      }
    )
  end

  let(:courier) do
    FactoryBot.create(:base_craft,
      craft_name: 'Courier',
      operational_data: {
        'blueprint_ports' => ['docking_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 1,
        'velocity' => 50
      }
    )
  end

  let(:cycler) do
    FactoryBot.create(:base_craft,
      craft_name: 'Long-Hull Cycler',
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 20,
        'velocity' => 300
      }
    )
  end

  let(:shipyard) do
    FactoryBot.create(:base_craft,
      craft_name: 'L1 Shipyard',
      operational_data: {
        'blueprint_ports' => ['docking_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 100,
        'velocity' => 400
      }
    )
  end

  let(:harvester) do
    FactoryBot.create(:craft_harvester,
      craft_name: 'Gas Harvester',
      extraction_rate: 1.2,
      operational_data: {
        'blueprint_ports' => ['docking_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 2,
        'velocity' => 120,
        'extraction_rate' => 1.2
      }
    )
  end

  # PATCH: Add storage units for craft that need inventory
  let(:skimmer_storage) do
    Units::BaseUnit.create!(
      identifier: 'skimmer_cargo_bay_001',
      name: 'Skimmer Cargo Bay',
      attachable: skimmer,
      owner: skimmer.owner,
      unit_type: 'storage_unit',
      operational_data: {
        'storage' => {
          'capacity' => 1000,
          'type' => 'general',
          'current_level' => 0
        }
      }
    )
  end

  let(:depot_storage) do
    Units::BaseUnit.create!(
      identifier: 'depot_cargo_bay_001',
      name: 'Depot Cargo Bay',
      attachable: orbital_depot,
      owner: orbital_depot.owner,
      unit_type: 'storage_unit',
      operational_data: {
        'storage' => {
          'capacity' => 10000,
          'type' => 'general',
          'current_level' => 0
        }
      }
    )
  end

  let(:courier_storage) do
    Units::BaseUnit.create!(
      identifier: 'courier_cargo_bay_001',
      name: 'Courier Cargo Bay',
      attachable: courier,
      owner: courier.owner,
      unit_type: 'storage_unit',
      operational_data: {
        'storage' => {
          'capacity' => 500,
          'type' => 'general',
          'current_level' => 0
        }
      }
    )
  end

  let(:harvester_storage) do
    Units::BaseUnit.create!(
      identifier: 'harvester_cargo_bay_001',
      name: 'Harvester Cargo Bay',
      attachable: harvester,
      owner: harvester.owner,
      unit_type: 'storage_unit',
      operational_data: {
        'storage' => {
          'capacity' => 5000,
          'type' => 'general',
          'current_level' => 0
        }
      }
    )
  end

  # No mocks needed; docking port logic is always available

  describe 'Universal Docking Handshake' do
    it 'allows any craft to dock with another if both have at least one docking port' do
      expect(service.dock(skimmer, orbital_depot)).to eq(true)
      expect(skimmer.docked_at).to eq(orbital_depot)
    end
    
    it 'prevents docking if all ports are occupied' do
      # Simulate all ports occupied
      allow(skimmer).to receive(:has_available_docking_port?).and_return(false)
      expect(service.dock(skimmer, orbital_depot)).to eq(false)
    end
  end

  describe 'Carrier & Hitchhiker Logic' do
    # Docking only; no hitchhiker or velocity inheritance logic
    it 'lets a Courier dock with a Cycler if ports are available' do
      expect(service.dock(courier, cycler)).to eq(true)
      expect(courier.docked_at).to eq(cycler)
    end
  end

  describe 'Universal Payload Handover' do
    # No payload, equipment, or personnel transfer tests; only docking logic is tested
  end
end
