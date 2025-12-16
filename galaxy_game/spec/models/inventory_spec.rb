require 'rails_helper'

RSpec.describe Inventory, type: :model do
  let!(:celestial_body) { create(:large_moon, :luna) }
  let(:location) { 
    create(:celestial_location, 
      name: "Shackleton Crater Base", 
      coordinates: "89.90°S 0.00°E",
      celestial_body: celestial_body
    ) 
  }
  let(:player) { create(:player, active_location: "Shackleton Crater Base") }
  let(:settlement) { 
    create(:base_settlement, 
      owner: player, 
      location: location
    ) 
  }
  let(:inventory) { settlement.inventory }
  let(:item) { 
    create(:item, 
      name: "Battery Pack",
      amount: 500, 
      storage_method: "bulk_storage",
      inventory: inventory,
      owner: player
    )
  }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(inventory).to be_valid
    end

    it 'requires an inventoryable' do
      inventory.inventoryable = nil
      expect(inventory).not_to be_valid
    end
  end

  describe '#available_capacity' do
    let(:storage_unit) do
      create(:base_unit, :storage,
        owner: settlement,
        attachable: settlement,
        operational_data: {
          'capacity' => 1000,
          'storage' => {
            'general' => 1000
          }
        }
      )
    end

    context 'when surface storage is available' do
      before do
        allow(settlement).to receive(:surface_storage?).and_return(true)
      end

      it 'returns infinity' do
        expect(inventory.available_capacity).to eq(Float::INFINITY)
      end
    end

    context 'when using unit storage' do
      let(:storage_unit) do
        create(:base_unit, :storage,
          owner: settlement,
          attachable: settlement,
          operational_data: {
            'storage' => {
              'type' => 'general',
              'capacity' => 1000,
              'current_level' => 0
            }
          }
        )
      end

      before do
        storage_unit
        settlement.reload
        allow(settlement).to receive(:surface_storage?).and_return(false)
        allow(settlement).to receive(:capacity).and_return(1000)
      end

      it 'returns remaining capacity from units' do
        expect(inventory.available_capacity).to eq(1000)
      end

      it 'subtracts stored items from capacity' do
        create(:item, inventory: inventory, amount: 300)
        expect(inventory.available_capacity).to eq(700)
      end
    end
  end

  describe '#add_item' do
    context 'when capacity is not exceeded' do
      before do
        # Stub can_store? to return true
        allow(inventory).to receive(:can_store?).and_return(true)
        # Stub the method call with the exact argument it receives
        allow(inventory).to receive(:capacity_exceeded?).with(kind_of(Numeric)).and_return(false)
        allow(inventory).to receive(:specialized_storage_required?).and_return(false)
      end

      it 'stores item in inventory' do
        expect {
          inventory.add_item("Battery Pack", 100, player)
        }.to change { inventory.items.count }.by(1)
      end
    end

    context 'when capacity is exceeded' do
      before do
        # Stub can_store? to return true (we want to test the capacity_exceeded path)
        allow(inventory).to receive(:can_store?).and_return(true)
        # Stub with argument matcher
        allow(inventory).to receive(:capacity_exceeded?).with(kind_of(Numeric)).and_return(true)
        allow(settlement).to receive(:surface_storage?).and_return(true)
        allow(settlement).to receive(:surface_storage_capacity).and_return(1000)
        allow(settlement.location).to receive(:celestial_body).and_return(celestial_body)
      end
      
      it 'uses surface storage' do
        expect(inventory).to receive(:handle_surface_storage).with("Battery Pack", 100, player, {})
        inventory.add_item("Battery Pack", 100, player)
      end
    end

    # --- NEW CONTEXTS FOR METADATA ---

    context "when adding a new item with metadata" do
      let(:unit_metadata) { { 'unit_type' => 'inflatable_habitat', 'power_draw' => 100 } }
      before do
        allow(inventory).to receive(:can_store?).and_return(true)
        allow(inventory).to receive(:capacity_exceeded?).with(kind_of(Numeric)).and_return(false)
        allow(inventory).to receive(:specialized_storage_required?).and_return(false)
      end

      it "creates a new item in the inventory with the specified metadata" do
        expect { inventory.add_item("Inflatable Habitat Unit", 1, player, unit_metadata) }
          .to change(inventory.items, :count).by(1)

        added_item = inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: unit_metadata)
        expect(added_item).to be_present
        expect(added_item.amount).to eq(1)
        expect(added_item.metadata).to eq(unit_metadata)
        expect(added_item.owner).to eq(player)
      end
    end

    context "when adding more amount to an existing item with matching metadata" do
      let(:habitat_metadata) { { 'unit_type' => 'inflatable_habitat', 'version' => 'v1.0' } }
      let!(:existing_habitat) {
        create(:item,
          name: "Inflatable Habitat Unit",
          amount: 5,
          inventory: inventory,
          owner: player,
          metadata: habitat_metadata
        )
      }

      before do
        allow(inventory).to receive(:can_store?).and_return(true)
        allow(inventory).to receive(:capacity_exceeded?).with(kind_of(Numeric)).and_return(false)
        allow(inventory).to receive(:specialized_storage_required?).and_return(false)
      end

      it "updates the amount of the specific existing item" do
        expect { inventory.add_item("Inflatable Habitat Unit", 3, player, habitat_metadata) }
          .not_to change(inventory.items, :count)

        existing_habitat.reload
        expect(existing_habitat.amount).to eq(8)
      end
    end

    context "when adding an item that exists but has different metadata" do
      let(:habitat_v1_metadata) { { 'unit_type' => 'inflatable_habitat', 'version' => 'v1.0' } }
      let(:habitat_v2_metadata) { { 'unit_type' => 'inflatable_habitat', 'version' => 'v2.0' } }

      let!(:existing_habitat_v1) {
        create(:item,
          name: "Inflatable Habitat Unit",
          amount: 1,
          inventory: inventory,
          owner: player,
          metadata: habitat_v1_metadata
        )
      }

      before do
        allow(inventory).to receive(:can_store?).and_return(true)
        allow(inventory).to receive(:capacity_exceeded?).with(kind_of(Numeric)).and_return(false)
        allow(inventory).to receive(:specialized_storage_required?).and_return(false)
      end

      it "creates a new item record with different metadata" do
        expect { inventory.add_item("Inflatable Habitat Unit", 1, player, habitat_v2_metadata) }
          .to change(inventory.items, :count).by(1)

        expect(inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: habitat_v1_metadata)).to be_present
        expect(inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: habitat_v2_metadata)).to be_present
        expect(inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: habitat_v1_metadata).amount).to eq(1)
        expect(inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: habitat_v2_metadata).amount).to eq(1)
      end
    end    
  end

  describe '#remove_item' do
    before { item }

    it 'removes items from storage' do
      expect {
        inventory.remove_item("Battery Pack", 100, player)
      }.to change { item.reload.amount }.by(-100)
    end

    context "when removing an item with specific metadata" do
      let(:habitat_metadata) { { 'unit_type' => 'inflatable_habitat' } }
      let!(:inflatable_habitat) {
        create(:item,
          name: "Inflatable Habitat Unit",
          amount: 5,
          inventory: inventory,
          owner: player,
          metadata: habitat_metadata
        )
      }

      it "decreases the amount of the specific item matching metadata" do
        expect(inventory.remove_item("Inflatable Habitat Unit", 2, player, habitat_metadata)).to be true
        inflatable_habitat.reload
        expect(inflatable_habitat.amount).to eq(3)
      end

      it "destroys the specific item if amount becomes zero or less" do
        expect { inventory.remove_item("Inflatable Habitat Unit", 5, player, habitat_metadata) }
          .to change(inventory.items, :count).by(-1)
        expect(inventory.items.find_by(name: "Inflatable Habitat Unit", metadata: habitat_metadata)).to be_nil
      end

      it "returns false if not enough amount of the specific item" do
        expect(inventory.remove_item("Inflatable Habitat Unit", 10, player, habitat_metadata)).to be false
        inflatable_habitat.reload
        expect(inflatable_habitat.amount).to eq(5)
      end

      it "returns false if item with matching name but different metadata not found" do
        other_metadata = { 'unit_type' => 'rigid_habitat' }
        expect(inventory.remove_item("Inflatable Habitat Unit", 1, player, other_metadata)).to be false
        inflatable_habitat.reload
        expect(inflatable_habitat.amount).to eq(5)
      end
    end

    context "when removing an item with matching name but different metadata exists" do
      let(:blueprint_v1_metadata) { { 'version' => 'v1.0', 'revision' => 'A' } }
      let(:blueprint_v2_metadata) { { 'version' => 'v1.3', 'revision' => 'B' } }

      let!(:blueprint_v1) {
        create(:item,
          name: "Inflatable Habitat Unit Blueprint",
          amount: 5,
          inventory: inventory,
          owner: player,
          metadata: blueprint_v1_metadata
        )
      }
      let!(:blueprint_v2) {
        create(:item,
          name: "Inflatable Habitat Unit Blueprint",
          amount: 3,
          inventory: inventory,
          owner: player,
          metadata: blueprint_v2_metadata
        )
      }

      it "only affects the item with the exactly matching metadata" do
        expect(inventory.remove_item("Inflatable Habitat Unit Blueprint", 2, player, blueprint_v1_metadata)).to be true
        blueprint_v1.reload
        blueprint_v2.reload
        expect(blueprint_v1.amount).to eq(3)
        expect(blueprint_v2.amount).to eq(3)
      end
    end    
  end
end