require 'rails_helper'

RSpec.describe AIManager::UniversalDockingService, type: :service do
  let(:service) { described_class.new }

  let(:skimmer) do
    craft = FactoryBot.create(:base_craft,
      craft_name: 'Standard Skimmer',
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 2
      }
    )
    craft.current_population = 2
    craft.save!
    craft.reload
  end

  let(:orbital_depot) do
    craft = FactoryBot.create(:base_craft,
      craft_name: 'Orbital Depot',
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'can_process_volatiles' => true,
        'crew_count' => 10
      }
    )
    craft.current_population = 10
    craft.save!
    craft.reload
  end

  let(:courier) do
    craft = FactoryBot.create(:base_craft,
      craft_name: 'Courier',
      operational_data: {
        'blueprint_ports' => ['docking_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 1
      }
    )
    craft.current_population = 1
    craft.save!
    craft.reload
  end

  let(:cycler) do
    craft = FactoryBot.create(:base_craft,
      craft_name: 'Long-Hull Cycler',
      operational_data: {
        'blueprint_ports' => ['docking_port', 'external_module_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 20
      }
    )
    craft.current_population = 20
    craft.save!
    craft.reload
  end

  let(:shipyard) do
    craft = FactoryBot.create(:base_craft,
      craft_name: 'L1 Shipyard',
      operational_data: {
        'blueprint_ports' => ['docking_port'],
        'interface_adapters' => ['Standard_I_Beam_Ring'],
        'crew_count' => 100
      }
    )
    craft.current_population = 100
    craft.save!
    craft.reload
  end

  describe 'Universal Docking Handshake' do
    it 'allows a Skimmer to dock with a Cycler (craft-to-craft polymorphic docking)' do
      expect(service.dock(skimmer, cycler)).to eq(true)
      skimmer.reload
      expect(skimmer.docked_at).to eq(cycler)
      expect(skimmer.docked_at_type).to eq('Craft::BaseCraft')
      expect(skimmer.docked_at_id).to eq(cycler.id)
    end
    it 'prevents docking if blueprint ports do not match' do
      skimmer.operational_data['blueprint_ports'] = ['custom_port']
      expect(service.dock(skimmer, cycler)).to eq(false)
    end
    it 'prevents docking if interface adapters do not match' do
      cycler.operational_data['interface_adapters'] = ['Nonstandard_Interface']
      expect(service.dock(skimmer, cycler)).to eq(false)
    end
  end

  describe 'Carrier & Hitchhiker Logic' do
    it 'puts the smaller craft in hitchhiker state and disables propulsion' do
      expect(skimmer).to receive(:enter_hitchhiker_state!).with(parent: cycler).and_call_original
      service.dock(skimmer, cycler)
      skimmer.reload
      expect(skimmer.operational_data['status']).to eq('docked')
    end
    it 'lets a Courier dock with a Cycler for a ride-along' do
      expect(service.dock(courier, cycler)).to eq(true)
      courier.reload
      expect(courier.docked_at).to eq(cycler)
      expect(courier.docked_at_type).to eq('Craft::BaseCraft')
    end
  end

  describe 'Universal Payload Handover' do
    it 'lets a Skimmer offload gas to an Orbital Depot with volatiles processing' do
      skimmer.inventory.add_item('Methane', 10, skimmer.owner)
      puts "After add_item: Skimmer inventory: #{skimmer.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "Before transfer:"
      puts "  Skimmer inventory: #{skimmer.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot inventory: #{orbital_depot.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot can_process_volatiles?: #{orbital_depot.can_process_volatiles?}"
      service.dock(skimmer, orbital_depot)
      skimmer.reload
      orbital_depot.reload
      result = service.transfer_cargo(skimmer, orbital_depot)
      puts "After transfer:"
      puts "  Skimmer inventory: #{skimmer.inventory.reload.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot inventory: #{orbital_depot.inventory.reload.items.map { |i| [i.name, i.amount] }}"
      puts "  transfer_cargo result: #{result}"
      skimmer.reload
      orbital_depot.reload
      puts "Skimmer operational_data after dock: #{skimmer.operational_data}"
      puts "Skimmer status after dock: #{skimmer.operational_data['status']}"
      expect(skimmer.inventory.items.where(name: 'Methane').sum(:amount)).to eq(0)
      expect(orbital_depot.inventory.items.where(name: 'Methane').sum(:amount)).to eq(10)
    end
    it 'lets a Harvester offload gas to a Depot (Inventory realism)' do
      harvester = FactoryBot.create(:craft_harvester,
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
      harvester.current_population = 5
      harvester.save!
      harvester.reload
      orbital_depot.current_population = 10
      orbital_depot.save!
      orbital_depot.reload
      harvester.inventory.add_item('Methane', 10, harvester.owner)
      puts "After add_item: Harvester inventory: #{harvester.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "Before transfer:"
      puts "  Harvester inventory: #{harvester.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot inventory: #{orbital_depot.inventory.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot can_process_volatiles?: #{orbital_depot.can_process_volatiles?}"
      service.dock(harvester, orbital_depot)
      harvester.reload
      orbital_depot.reload
      result = service.transfer_cargo(harvester, orbital_depot)
      puts "After transfer:"
      puts "  Harvester inventory: #{harvester.inventory.reload.items.map { |i| [i.name, i.amount] }}"
      puts "  Depot inventory: #{orbital_depot.inventory.reload.items.map { |i| [i.name, i.amount] }}"
      puts "  transfer_cargo result: #{result}"
      harvester.reload
      orbital_depot.reload
      puts "Harvester operational_data after dock: #{harvester.operational_data}"
      puts "Harvester status after dock: #{harvester.operational_data['status']}"
      expect(harvester.inventory.items.where(name: 'Methane').sum(:amount)).to eq(0)
      expect(orbital_depot.inventory.items.where(name: 'Methane').sum(:amount)).to eq(10)
    end
    it 'lets personnel move from the L1 Shipyard to a docked craft' do
      shipyard.current_population = 100
      shipyard.save!
      shipyard.reload
      courier.current_population = 1
      courier.save!
      courier.reload
      service.dock(courier, shipyard)
      expect { service.transfer_personnel(shipyard, courier, 5) }.to change { courier.crew_count }.by(5)
    end
    it 'lets the parent service the hitchhiker by swapping I-beam panels' do
      expect(orbital_depot).to receive(:add_equipment!).with('ibeam_panel_1')
      expect(skimmer).to receive(:remove_equipment!).with('ibeam_panel_1')
      result = service.dock(skimmer, orbital_depot)
      puts "Called dock: result=#{result}"
      puts "Skimmer operational_data after dock: #{skimmer.reload.operational_data}"
      puts "Skimmer status after dock: #{skimmer.operational_data['status']}"
      service.transfer_equipment(skimmer, orbital_depot, 'ibeam_panel_1')
    end
  end
end
