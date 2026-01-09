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
           name: "Raw Regolith",
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

  before(:each) do
    # First stub a default response for any item lookup
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .and_return(nil)

    # Then stub specific items
    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Battery Pack')
      .and_return({
        'id' => 'battery_pack',
        'type' => 'consumable',
        'name' => 'Battery Pack',
        'category' => 'consumable',
        'storage' => { 'method' => 'bulk_storage' },
        'weight' => { 'amount' => 5, 'unit' => 'kg' }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Large Plastic Crate')
      .and_return({
        'id' => 'large_plastic_crate',
        'type' => 'container',
        'name' => 'Large Plastic Crate',
        'category' => 'container',
        'capacity_kg' => 100,
        'storage' => { 'method' => 'container' }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Lunar Regolith')
      .and_return({
        'id' => 'lunar_regolith',
        'type' => 'raw_material',
        'name' => 'Lunar Regolith',
        'category' => 'geological',
        'storage' => { 'method' => 'bulk_storage' }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Regolith')
      .and_return({
        'id' => 'regolith',
        'type' => 'raw_material',
        'name' => 'Regolith',
        'category' => 'geological',
        'storage' => { 'method' => 'bulk_storage' }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Raw Regolith')
      .and_return({
        'id' => 'raw_regolith',
        'type' => 'raw_material',
        'name' => 'Raw Regolith',
        'category' => 'geological',
        'classification' => { 'category' => 'raw', 'subcategory' => 'geological', 'type' => 'soil' },
        'storage' => { 'method' => 'bulk_storage' }
      })

    allow_any_instance_of(Lookup::ItemLookupService)
      .to receive(:find_item)
      .with('Processed Regolith')
      .and_return({
        'id' => 'processed_regolith',
        'type' => 'processed_material',
        'name' => 'Processed Regolith',
        'category' => 'material',
        'storage' => { 'method' => 'bulk_storage' }
      })
  end

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
    it 'loads properties from item lookup service with category' do
      expect(item.properties).to include(
        "name" => "Battery Pack",
        "category" => "consumable"
      )
    end

    it 'handles processed materials' do
      processed = create(:item, 
        name: "Processed Regolith",
        material_type: :processed_material,
        metadata: {
          'composition' => {
            'oxides' => { 'SiO2' => 45.0 }
          }
        }
      )
      
      expect(processed.properties).to include(
        "name" => "Processed Regolith",
        "category" => "material"
      )
      expect(processed.metadata['composition']).to include('oxides')
    end

    it 'loads material properties for raw materials' do
      raw_material.reload
      expect(raw_material.material_properties).to include(
        "classification" => {"category" => "raw", "subcategory" => "geological", "type" => "soil"},
        "name" => "Raw Regolith",
        "id" => "raw_regolith"
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

  describe 'regolith handling' do
    let!(:luna) do
      # Create Luna - the factory should set identifier to "LUNA-01"
      create(:large_moon, :luna)
    end

    let(:regolith) do
      # Regolith item - metadata uses identifier, not name
      create(:item,
        name: "Regolith",
        material_type: :raw_material,
        storage_method: "bulk_storage",
        inventory: inventory,
        metadata: {
          'source_body' => luna.identifier  # Use identifier, not name
        }
      )
    end

    it 'gets composition from celestial body geosphere' do
      luna.reload
      
      # Verify Luna was created with correct identifier
      expect(luna.identifier).to eq('LUNA-01')
      
      # Verify the body can be found by identifier
      found_body = CelestialBodies::CelestialBody.find_by(identifier: luna.identifier)
      expect(found_body).to eq(luna)
      
      # Check that regolith gets composition from Luna's geosphere
      expect(regolith.material_properties["composition"]).to eq({
        "Silicon" => 45.0,
        "Oxygen" => 35.0,
        "Aluminum" => 10.0,
        "Titanium" => 5.0
      })
    end

    it 'includes source body in properties' do
      expect(regolith.material_properties["source"]).to eq("Luna")
    end
  end
end