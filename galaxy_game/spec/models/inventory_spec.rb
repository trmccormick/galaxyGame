require 'rails_helper'

RSpec.describe Inventory, type: :model do
  let(:celestial_body) { create(:celestial_body, :luna) }
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
      name: "Battery Pack",  # Changed to match our JSON data
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
      before do
        storage_unit
        settlement.reload
        allow(settlement).to receive(:surface_storage?).and_return(false)
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
        allow(inventory).to receive(:capacity_exceeded?).and_return(false)
        # Ensure base storage capability
        allow(settlement).to receive(:base_units).and_return([])
      end

      it 'stores item in inventory' do
        # Debug output
        puts "Inventory before: #{inventory.items.count}"
        
        expect {
          result = inventory.add_item("Battery Pack", 100, player)
          # More debug output
          puts "Add item result: #{result}"
          puts "Inventory after: #{inventory.items.count}"
          puts "Last error: #{inventory.errors.full_messages.join(', ')}" if inventory.errors.any?
        }.to change { inventory.items.count }.by(1)
      end
    end

    context 'when capacity is exceeded' do
      before do 
        allow(inventory).to receive(:capacity_exceeded?).and_return(true)
        # Add surface storage capability to settlement
        allow(settlement).to receive(:surface_storage?).and_return(true)
        allow(settlement).to receive(:surface_storage_capacity).and_return(1000)
        # Use the delegated celestial_body from location
        allow(settlement.location).to receive(:celestial_body).and_return(celestial_body)
      end
      
      it 'uses surface storage' do
        expect(inventory).to receive(:handle_surface_storage)
        inventory.add_item("Battery Pack", 100, player)
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
  end
end