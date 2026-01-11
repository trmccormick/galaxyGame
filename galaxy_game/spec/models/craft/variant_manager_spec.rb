require 'rails_helper'

RSpec.describe Craft::VariantManager do
  let(:fixture_base_path) { Rails.root.join('spec', 'fixtures', 'data', 'operational_data', 'crafts') }
  
  before do
    # Set up test fixtures directory
    fixture_path = fixture_base_path.join('space', 'spacecraft')
    FileUtils.mkdir_p(fixture_path.join('variants'))
    
    # Create base heavy_lift_transport data file
    File.write(fixture_path.join('heavy_lift_transport_data.json'), {
      "id": "heavy_lift_transport",
      "name": "Heavy Lift Transport",
      "category": "transport",
      "subcategory": "spaceship",
      "operational_status": {
        "status": "offline",
        "condition": 100
      },
      "systems": {
        "propulsion": { "status": "offline" },
        "life_support": { "status": "offline" }
      }
    }.to_json)
    
    # Create standard variant file
    File.write(fixture_path.join('variants', 'heavy_lift_transport_standard_data.json'), {
      "id": "heavy_lift_transport_standard",
      "base_craft": "heavy_lift_transport",
      "description": "Standard interplanetary transport vessel",
      "recommended_units": [
        { "id": "methane_engine", "count": 6, "required": true }
      ],
      "system_overrides": {
        "life_support": { "capacity": "standard" }
      }
    }.to_json)
    
    # Create lunar variant file
    File.write(fixture_path.join('variants', 'heavy_lift_transport_lunar_data.json'), {
      "id": "heavy_lift_transport_lunar",
      "base_craft": "heavy_lift_transport",
      "name": "Heavy Lift Transport (Lunar Variant)",
      "description": "Specialized variant for lunar operations",
      "recommended_units": [
        { "id": "methane_engine", "count": 6, "required": true },
        { "id": "life_support_unit", "count": 2, "required": true }
      ],
      "system_overrides": {
        "life_support": { "capacity": "enhanced" }
      }
    }.to_json)
    
    # Stub the BASE_PATH constant to use our fixture path
    stub_const("Craft::VariantManager::BASE_PATH", fixture_base_path)
  end
  
  after do
    FileUtils.rm_rf(Rails.root.join('spec', 'fixtures', 'data'))
  end
  
  let(:variant_manager) { described_class.new('space/spacecraft/heavy_lift_transport') }
  
  describe '#initialize' do
    it 'loads base data and variants' do
      expect(variant_manager.instance_variable_get(:@base_data)).to be_present
      expect(variant_manager.instance_variable_get(:@variants)).to be_present
    end
    
    it 'handles non-existent craft types gracefully' do
      invalid_manager = described_class.new('space/non_existent')
      expect(invalid_manager.instance_variable_get(:@base_data)).to eq({})
      expect(invalid_manager.instance_variable_get(:@variants)).to eq({})
    end
  end
  
  describe '#available_variants' do
    it 'returns a list of available variant IDs' do
      expect(variant_manager.available_variants).to contain_exactly('heavy_lift_transport_standard', 'heavy_lift_transport_lunar')
    end
    
    it 'returns an empty array when no variants exist' do
      no_variants_path = fixture_base_path.join('space', 'landers')
      FileUtils.mkdir_p(no_variants_path)
      
      File.write(no_variants_path.join('basic_lander_data.json'), {
        "id": "basic_lander",
        "name": "Basic Lander"
      }.to_json)
      
      no_variant_manager = described_class.new('space/landers/basic_lander')
      expect(no_variant_manager.available_variants).to be_empty
    end
  end
  
  describe '#get_variant' do
    it 'returns nil for non-existent variant' do
      expect(variant_manager.get_variant('non_existent')).to be_nil
    end
    
    it 'merges base data with standard variant data' do
      merged_data = variant_manager.get_variant('heavy_lift_transport_standard')
      
      expect(merged_data['id']).to eq('heavy_lift_transport')
      expect(merged_data['category']).to eq('transport')
      expect(merged_data['description']).to eq('Standard interplanetary transport vessel')
      expect(merged_data['recommended_units']).to include(hash_including('id' => 'methane_engine'))
      expect(merged_data['systems']['life_support']['capacity']).to eq('standard')
      expect(merged_data['operational_status']['variant_configuration']).to eq('heavy_lift_transport_standard')
    end
    
    it 'merges base data with lunar variant data' do
      merged_data = variant_manager.get_variant('heavy_lift_transport_lunar')
      
      expect(merged_data['name']).to eq('Heavy Lift Transport (Lunar Variant)')
      expect(merged_data['recommended_units']).to include(
        hash_including('id' => 'methane_engine'),
        hash_including('id' => 'life_support_unit')
      )
      expect(merged_data['systems']['life_support']['capacity']).to eq('enhanced')
    end
    
    it 'properly merges nested hashes' do
      complex_path = fixture_base_path.join('space', 'spacecraft')
      
      base_data = JSON.parse(File.read(complex_path.join('heavy_lift_transport_data.json')))
      base_data['resource_management'] = {
        'consumables' => {
          'fuel' => { 'capacity' => 1000, 'current' => 0 }
        }
      }
      File.write(complex_path.join('heavy_lift_transport_data.json'), base_data.to_json)
      
      variant_data = JSON.parse(File.read(complex_path.join('variants', 'heavy_lift_transport_standard_data.json')))
      variant_data['resource_management'] = {
        'consumables' => {
          'fuel' => { 'capacity' => 2000 },
          'oxygen' => { 'capacity' => 500 }
        }
      }
      File.write(complex_path.join('variants', 'heavy_lift_transport_standard_data.json'), variant_data.to_json)
      
      reloaded_manager = described_class.new('space/spacecraft/heavy_lift_transport')
      merged_data = reloaded_manager.get_variant('heavy_lift_transport_standard')
      
      expect(merged_data['resource_management']['consumables']['fuel']['capacity']).to eq(2000)
      expect(merged_data['resource_management']['consumables']['fuel']['current']).to eq(0)
      expect(merged_data['resource_management']['consumables']['oxygen']['capacity']).to eq(500)
    end
  end
end