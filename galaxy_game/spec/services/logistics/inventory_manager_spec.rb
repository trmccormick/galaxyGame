require 'rails_helper'

RSpec.describe Logistics::InventoryManager, type: :service do
  let(:player) { create(:player) }
  let(:station) { create(:base_settlement, :station, owner: player) }
  let(:surface_settlement) { create(:base_settlement, :base, owner: player) }
  let(:station_inventory) { station.inventory }
  let(:surface_inventory) { surface_settlement.inventory }

  describe '.transfer_item' do
    let!(:source_item) { create(:item, inventory: surface_inventory, name: 'ibeam', amount: 1000) }

    context 'when transferring to a station with orbital construction projects' do
      let!(:project) { create(:orbital_construction_project, station: station) }

      before do
        project.update!(
          required_materials: { 'ibeam' => 500 },
          delivered_materials: { 'ibeam' => 0 }
        )
      end

      it 'intercepts materials for orbital construction' do
        expect(Construction::OrbitalShipyardService).to receive(:deliver_materials).with(
          station, 'ibeam', 1000, surface_settlement
        ).and_return(500) # 500 consumed, 500 remaining

        Logistics::InventoryManager.transfer_item(
          item_name: 'ibeam',
          quantity: 1000,
          from_inventory: surface_inventory,
          to_inventory: station_inventory
        )

        # Check that only remaining quantity was added to station inventory
        station_item = station_inventory.items.find_by(name: 'ibeam')
        expect(station_item.amount).to eq(500)
      end

      it 'does not add materials to station inventory if all consumed by projects' do
        expect(Construction::OrbitalShipyardService).to receive(:deliver_materials).with(
          station, 'ibeam', 1000, surface_settlement
        ).and_return(0) # All consumed

        Logistics::InventoryManager.transfer_item(
          item_name: 'ibeam',
          quantity: 1000,
          from_inventory: surface_inventory,
          to_inventory: station_inventory
        )

        # Check that no materials were added to station inventory
        station_item = station_inventory.items.find_by(name: 'ibeam')
        expect(station_item).to be_nil
      end
    end

    context 'when transferring orbital construction materials to non-orbital settlement' do
      let(:regular_settlement) { create(:base_settlement, :base, owner: player) }
      let(:regular_inventory) { regular_settlement.inventory }

      it 'transfers materials normally without interception' do
        expect(Construction::OrbitalShipyardService).not_to receive(:deliver_materials)

        Logistics::InventoryManager.transfer_item(
          item_name: 'ibeam',
          quantity: 100,
          from_inventory: surface_inventory,
          to_inventory: regular_inventory
        )

        regular_item = regular_inventory.items.find_by(name: 'ibeam')
        expect(regular_item.amount).to eq(100)
      end
    end

    context 'when transferring non-orbital materials to orbital station' do
      let!(:project) { create(:orbital_construction_project, station: station) }
      let!(:food_item) { create(:item, inventory: surface_inventory, name: 'food', amount: 200) }

      it 'transfers materials normally without interception' do
        expect(Construction::OrbitalShipyardService).not_to receive(:deliver_materials)

        Logistics::InventoryManager.transfer_item(
          item_name: 'food',
          quantity: 100,
          from_inventory: surface_inventory,
          to_inventory: station_inventory
        )

        station_item = station_inventory.items.find_by(name: 'food')
        expect(station_item.amount).to eq(100)
      end
    end
  end

  describe '.should_check_orbital_projects?' do
    it 'returns true for known orbital materials' do
      expect(described_class.send(:should_check_orbital_projects?, 'ibeam')).to be true
      expect(described_class.send(:should_check_orbital_projects?, 'modular_structural_panel_base')).to be true
      expect(described_class.send(:should_check_orbital_projects?, 'structural_panel')).to be true
      expect(described_class.send(:should_check_orbital_projects?, 'support_beam')).to be true
    end

    it 'returns true for materials containing panel or beam' do
      expect(described_class.send(:should_check_orbital_projects?, 'large_panel')).to be true
      expect(described_class.send(:should_check_orbital_projects?, 'heavy_beam')).to be true
      expect(described_class.send(:should_check_orbital_projects?, 'composite_beam_assembly')).to be true
    end

    it 'returns false for non-orbital materials' do
      expect(described_class.send(:should_check_orbital_projects?, 'food')).to be false
      expect(described_class.send(:should_check_orbital_projects?, 'water')).to be false
      expect(described_class.send(:should_check_orbital_projects?, 'oxygen')).to be false
    end
  end
end