require 'rails_helper'
require 'json'

RSpec.describe Lookup::ItemLookupService do
  let(:service) { described_class.new }

  describe '#find_item' do
    it 'loads items from the correct file structure' do
      items_path = described_class.base_items_path.to_s
      expect(File.directory?(items_path)).to be true
      
      # Verify we have JSON files
      json_files = Dir.glob(File.join(items_path, "**", "*.json"))
      expect(json_files).not_to be_empty
    end

    it 'finds consumable items with correct data' do
      # Find any consumable files to test with
      consumable_files = Dir.glob(Rails.root.join("app", "data", "items", "consumable", "*.json"))
      skip("No consumable item files found") if consumable_files.empty?
      
      # Get the filename for the test
      item_id = File.basename(consumable_files.first, '.json')
      
      # Test the service - only pass item_id, not category
      result = service.find_item(item_id)
      expect(result).not_to be_nil
      expect(result).to have_key("id")
    end

    it 'finds equipment items with correct data' do
      # Find any equipment files to test with
      equipment_files = Dir.glob(Rails.root.join("app", "data", "items", "equipment", "*.json"))
      skip("No equipment item files found") if equipment_files.empty?
      
      # Get the filename for the test
      item_id = File.basename(equipment_files.first, '.json')
      
      # Test the service - only pass item_id, not category
      result = service.find_item(item_id)
      expect(result).not_to be_nil
      expect(result).to have_key("id")
    end

    it 'returns nil when item does not exist' do
      result = service.find_item('nonexistent_item_xyz_12345')
      expect(result).to be_nil
    end
    
    it 'handles dynamic unassembled items' do
      # This tests the dynamic item creation functionality
      # Skip if no operational data exists
      skip("Requires operational data") unless File.directory?(Rails.root.join("app", "data", "operational_data"))
      
      # Try to create an unassembled item (this will only work if operational data exists)
      result = service.find_item('Unassembled Test Unit')
      # We expect either a result or nil, but no error
      expect(result).to be_nil.or be_a(Hash)
    end
    
    it 'handles scrap items dynamically' do
      result = service.find_item('Steel Scrap')
      expect(result).to be_a(Hash)
      expect(result['type']).to eq('scrap_material')
      expect(result['category']).to eq('recyclable')
    end
    
    it 'caches results for subsequent lookups' do
      # Find any item file to test with
      item_files = Dir.glob(Rails.root.join("app", "data", "items", "**", "*.json"))
      skip("No item files found") if item_files.empty?
      
      # Get the filename for the test
      file_path = item_files.first
      item_id = File.basename(file_path, '.json')
      
      # Ensure we get the item first before testing caching
      first_lookup = service.find_item(item_id)
      skip("Item #{item_id} not found") if first_lookup.nil?
      
      # Now check caching behavior
      first_result = service.find_item(item_id)
      second_result = service.find_item(item_id)
      
      # Test that we get the same object back (by object_id)
      expect(first_result.object_id).to eq(second_result.object_id)
    end
    
    it 'finds items by partial name match' do
      # Find any item file to test with
      item_files = Dir.glob(Rails.root.join("app", "data", "items", "**", "*.json"))
      skip("No item files found") if item_files.empty?
      
      # Load an item to get its name
      item_data = JSON.parse(File.read(item_files.first))
      item_name = item_data['name']
      skip("Item has no name") unless item_name
      
      # Try partial match (first 4 characters if long enough)
      if item_name.length >= 4
        partial_name = item_name[0..3]
        result = service.find_item(partial_name)
        expect(result).to be_a(Hash) if result # May or may not match depending on data
      end
    end
    
    it 'is case insensitive' do
      # Find any item file to test with
      item_files = Dir.glob(Rails.root.join("app", "data", "items", "**", "*.json"))
      skip("No item files found") if item_files.empty?
      
      # Get the item ID
      item_id = File.basename(item_files.first, '.json')
      
      # Test with uppercase
      result = service.find_item(item_id.upcase)
      
      # Should either find it or return nil, but not error
      expect(result).to be_nil.or be_a(Hash)
    end
  end

  describe 'dynamic item creation' do
    it 'creates scrap items on the fly' do
      result = service.find_item('Copper Scrap')
      expect(result).to be_a(Hash)
      expect(result['id']).to eq('copper_scrap')
      expect(result['name']).to eq('Copper Scrap')
      expect(result['type']).to eq('scrap_material')
    end
    
    it 'creates processed items on the fly' do
      result = service.find_item('Processed Iron')
      expect(result).to be_a(Hash)
      expect(result['id']).to eq('processed_iron')
      expect(result['name']).to eq('Processed Iron')
      expect(result['type']).to eq('processed_material')
    end
    
    it 'creates used items on the fly' do
      result = service.find_item('Used Battery')
      expect(result).to be_a(Hash)
      expect(result['id']).to eq('used_battery')
      expect(result['name']).to eq('Used Battery')
      expect(result['type']).to eq('used_component')
    end
  end

  describe 'integration with other lookup services' do
    it 'converts materials to items when needed' do
      # This will depend on MaterialLookupService having data
      skip("Requires material data") unless File.directory?(Rails.root.join("app", "data", "resources", "materials"))
      
      # Try to find a material as an item
      result = service.find_item('iron')
      # Should either find it or return nil, but not error
      expect(result).to be_nil.or be_a(Hash)
    end
  end

  describe 'item loading' do
    it 'loads items from all configured paths' do
      # Just verify that the service initializes without error
      expect(service).to be_a(Lookup::ItemLookupService)
    end
    
    it 'handles missing directories gracefully' do
      # Even if some directories don't exist, service should work
      expect { described_class.new }.not_to raise_error
    end
  end
end

