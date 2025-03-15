require 'rails_helper'

RSpec.describe Item, type: :model do
  let(:base_craft) { create(:base_craft) }
  let(:inventory) { create(:inventory, inventoryable: base_craft) }
  
  let(:item) { 
    create(:item, 
           name: "Battery Pack",
           storage_method: "bulk_storage", 
           inventory: inventory) 
  }
  
  let(:container) { 
    create(:item, 
           name: "Large Plastic Crate", 
           storage_method: "container",
           inventory: inventory) 
  }
  
  let(:raw_material) {
    create(:item,
           name: "Lunar Regolith",  # Changed to match our JSON file
           storage_method: "bulk_storage",
           material_type: :raw_material,
           inventory: inventory)
  }

  let(:contained_item) { 
    create(:item, 
           name: "Battery Pack",
           storage_method: "bulk_storage",
           inventory: inventory) 
  }

  describe 'associations' do
    it { is_expected.to belong_to(:inventory).optional }
    it { is_expected.to belong_to(:container).class_name('Item').optional }
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to belong_to(:storage_unit).optional }
    it { is_expected.to have_many(:contained_items).class_name('Item').dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:storage_method) }
  end

  describe 'lookup service integration' do
    it 'loads properties from item lookup service' do
      expect(item.properties).to include(
        "id" => "battery_pack",
        "type" => "consumable",
        "name" => "Battery Pack",
        "description" => "A rechargeable battery pack for portable devices."
      )
    end

    it 'loads material properties for raw materials' do
      raw_material.reload
      expect(raw_material.material_properties).to include(
        "type" => "raw_material",
        "name" => "Lunar Regolith",
        "category" => "geological"
      )
    end
  end

  describe '#container operations' do
    let(:small_item) { 
      create(:item, 
             name: "Battery Pack", 
             amount: 1,  # Single battery pack
             storage_method: "bulk_storage",
             inventory: inventory) 
    }

    it 'identifies containers correctly' do
      expect(container).to be_container
      expect(item).not_to be_container
    end

    it 'adds items to containers' do
      expect {
        container.add_item(small_item)
      }.to change { container.contained_items.count }.by(1)
    end

    it 'removes items from containers' do
      container.add_item(small_item)
      container.reload
      
      expect {
        container.remove_item(small_item)
      }.to change { container.contained_items.count }.by(-1)
      
      expect(small_item.reload.inventory).to eq(container.inventory)
    end

    it 'enforces weight capacity limits' do
      # Container capacity is 100kg, battery pack is 5kg
      # So 21 battery packs = 105kg should exceed capacity
      heavy_item = create(:item, 
                         name: "Battery Pack", 
                         amount: 21,
                         storage_method: "bulk_storage",
                         inventory: inventory)
      expect {
        container.add_item(heavy_item)
      }.to raise_error(RuntimeError, "Cannot add item: Exceeds container weight capacity.")
    end
  end

  describe '#total_weight' do
    let(:small_item) { 
      create(:item, 
             name: "Battery Pack", 
             amount: 1,
             storage_method: "bulk_storage", 
             inventory: inventory) 
    }

    it 'calculates base weight from properties' do
      item.reload  # Ensure properties are loaded
      expect(item.properties).not_to be_nil
      expect(item.properties).to include(
        "id" => "battery_pack",
        "type" => "consumable",
        "name" => "Battery Pack",
        "weight" => {
          "amount" => 5,
          "unit" => "kg"
        }
      )
      expect(item.total_weight).to eq(5)
    end

    it 'includes contained items in total weight' do
      container.reload
      small_item.reload
      
      # Debug capacity and weights
      # puts "Container properties: #{container.properties.inspect}"
      # puts "Small item weight: #{small_item.total_weight}"
      
      container.add_item(small_item)
      container.reload
      
      # Since the container JSON has capacity_kg but no weight,
      # total weight should just be the contained items' weight
      expect(container.total_weight).to eq(small_item.total_weight)
    end
  end

  describe '#tradeable?' do
    let(:small_item) { 
      create(:item, 
             name: "Battery Pack", 
             amount: 1,
             storage_method: "bulk_storage",
             inventory: inventory) 
    }

    it 'returns true for normal items with positive amount' do
      expect(item).to be_tradeable
    end

    it 'returns false for items with zero amount' do
      item.update!(amount: 0)
      expect(item).not_to be_tradeable
    end

    it 'returns false for containers with items' do
      # First verify we can add the item
      expect { container.add_item(small_item) }.to_not raise_error
      container.reload  # Ensure relationship is loaded
      
      expect(container.contained_items).not_to be_empty
      expect(container).not_to be_tradeable
    end

    it 'returns true for empty containers' do
      expect(container).to be_tradeable
    end
  end
end
