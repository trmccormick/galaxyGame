require 'rails_helper'

RSpec.describe Lookup::CraftLookupService do
  let(:service) { described_class.new }

  describe '#find_craft' do
    it 'loads crafts from the correct file structure' do
      crafts_path = Rails.root.join("app", "data", "crafts")
      expect(File.directory?(crafts_path)).to be true
      
      # Check that key directories exist
      expect(File.directory?(crafts_path.join("transport"))).to be true
      expect(File.directory?(crafts_path.join("deployable"))).to be true
      expect(File.directory?(crafts_path.join("surface"))).to be true
      
      # Check for craft JSON files deeper in the structure
      json_files = Dir.glob(File.join(crafts_path, "*", "*", "*.json"))
      expect(json_files).not_to be_empty
    end
    
    it 'loads JSON files with correct format' do
      # Need to look deeper in directory structure for JSON files
      craft_files = Dir.glob(Rails.root.join("app", "data", "crafts", "*", "*", "*.json"))
      
      # Skip if no craft files found
      if craft_files.empty?
        skip("No craft JSON files found to test")
      end
      
      # Inspect the first file
      test_file = craft_files.first
      puts "Testing with file: #{test_file}"
      
      # Extract directory structure info
      sub_type_dir = File.basename(File.dirname(test_file))
      craft_type_dir = File.basename(File.dirname(File.dirname(test_file)))
      
      # Read the file content to get the craft name
      json_data = JSON.parse(File.read(test_file))
      craft_name = json_data["name"]
      
      puts "Craft name from JSON: #{craft_name}"
      puts "Craft type dir: #{craft_type_dir}"
      puts "Sub type dir: #{sub_type_dir}"
      
      # Test using the real service and real data
      result = service.find_craft(craft_name, craft_type_dir, sub_type_dir)
      
      # Verify we got back the expected data
      expect(result).to include("name")
      expect(result["name"]).to eq(craft_name)
    end
    
    it 'validates input parameters' do
      expect { service.find_craft('', 'transport') }
        .to raise_error(ArgumentError, 'Invalid craft name')
        
      expect { service.find_craft('Starship', 'invalid_type') }
        .to raise_error(ArgumentError, /Invalid craft type/)
    end
    
    it 'returns nil for nonexistent crafts' do
      expect(service.find_craft('nonexistent_craft', 'transport')).to be_nil
    end
    
    it 'uses cached results for subsequent lookups' do
      # Need to look deeper in directory structure for JSON files
      craft_files = Dir.glob(Rails.root.join("app", "data", "crafts", "*", "*", "*.json"))
      
      # Skip if no craft files found
      if craft_files.empty?
        skip("No craft JSON files found to test caching")
      end
      
      # Get a real craft name and type
      test_file = craft_files.first
      json_data = JSON.parse(File.read(test_file))
      craft_name = json_data["name"]
      craft_type_dir = File.basename(File.dirname(File.dirname(test_file)))
      sub_type_dir = File.basename(File.dirname(test_file))
      
      # Test the caching behavior - the load_json_file method should only be called once
      expect(File).to receive(:read).with(anything).once.and_call_original
      
      # First call should load from file
      first_result = service.find_craft(craft_name, craft_type_dir, sub_type_dir)
      
      # Second call should use cache and not call File.read again
      second_result = service.find_craft(craft_name, craft_type_dir, sub_type_dir)
      
      # Both should return equivalent data
      expect(second_result).to eq(first_result)
    end
  end
end