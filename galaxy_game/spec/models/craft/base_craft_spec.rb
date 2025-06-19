require 'rails_helper'

RSpec.describe Craft::BaseCraft, type: :model do
  # ✅ FIX: Use the large_moon factory with luna trait
  let!(:celestial_body) { create(:large_moon, :luna) }
  
  let!(:location) { 
    create(:celestial_location, 
           name: "Shackleton Crater Base", 
           coordinates: "89.90°S 0.00°E",
           celestial_body: celestial_body) 
  }

  # Modify the craft setup in the spec
  let!(:craft) do
    c = create(:base_craft)  # Create a basic craft without the trait
    
    # Set the location using our new method
    c.celestial_location = location
    c.current_location = "Shackleton Crater Base"  # Explicitly set this
    
    # Set up recommended units directly in operational_data
    c.operational_data = c.operational_data.merge({
      'recommended_units' => [
        {'id' => 'raptor_engine', 'count' => 6},
        {'id' => 'lox_tank', 'count' => 1},
        {'id' => 'methane_tank', 'count' => 1},
        {'id' => 'storage_unit', 'count' => 1},
        {'id' => 'starship_habitat_unit', 'count' => 1},
        {'id' => 'waste_management_unit', 'count' => 1},
        {'id' => 'co2_oxygen_production_unit', 'count' => 1},
        {'id' => 'water_recycling_unit', 'count' => 1},
        {'id' => 'retractable_landing_legs', 'count' => 1}
      ]
    })
    c.save!
    
    # Mock the unit lookup service to return test data
    allow_any_instance_of(Lookup::UnitLookupService).to receive(:find_unit)
      .and_return({
        'name' => 'Test Unit',
        'mass' => 100,
        'power_required' => 10
      })
      
    # Call build_units_and_modules after all the setup is done
    c.build_units_and_modules
    
    # Force reload to ensure we get the latest data
    c.reload
    
    # Return the craft
    c
  end
  
  let(:inventory) { craft.inventory }
  
  # Use the real lookup service instead of a mock
  let(:craft_lookup_service) { Lookup::CraftLookupService.new }
  let(:unit_lookup_service) { Lookup::UnitLookupService.new }

  # Make sure we have access to the test data files
  before do
    # Instead of trying to stub lookup_paths, mock the actual lookup methods
    allow_any_instance_of(Lookup::CraftLookupService).to receive(:find_craft)
      .with('Starship (Lunar Variant)', 'transport')
      .and_return({
        'name' => 'Starship (Lunar Variant)',
        'craft_type' => 'transport',
        'recommended_units' => [
          {'id' => 'raptor_engine', 'count' => 6},
          {'id' => 'lox_tank', 'count' => 1},
          {'id' => 'methane_tank', 'count' => 1},
          {'id' => 'storage_unit', 'count' => 1},
          {'id' => 'starship_habitat_unit', 'count' => 1},
          {'id' => 'waste_management_unit', 'count' => 1},
          {'id' => 'co2_oxygen_production_unit', 'count' => 1},
          {'id' => 'water_recycling_unit', 'count' => 1},
          {'id' => 'retractable_landing_legs', 'count' => 1}
        ]
      })
    
    # Also mock unit lookups
    allow_any_instance_of(Lookup::UnitLookupService).to receive(:find_unit)
      .and_return({
        'name' => 'Test Unit',
        'mass' => 100,
        'power_required' => 10
      })
  end

  describe 'associations' do
    it { is_expected.to have_one(:spatial_location) }
    it { is_expected.to have_one(:celestial_location) }
    it { is_expected.to belong_to(:owner) }
    it { should have_one(:atmosphere).with_foreign_key(:craft_id).dependent(:destroy) }
  end

  describe 'location handling' do
    it 'can access location through helper method' do
      expect(craft.location).to eq(location)
    end

    it 'can switch between spatial and celestial locations' do
      # Start with celestial location
      expect(craft.celestial_location).to be_present
      expect(craft.spatial_location).to be_nil
      
      # Switch to spatial location
      spatial_loc = create(:spatial_location)
      craft.set_location(spatial_loc)
      craft.reload
      
      expect(craft.spatial_location).to be_present
      expect(craft.celestial_location).to be_nil
      expect(craft.location).to eq(spatial_loc)
    end
  end

  describe 'initialization' do
    it 'initializes with the correct name' do
      expect(craft.name).to start_with "Starship"
    end

    it 'initializes with the correct craft_name' do
      expect(craft.craft_name).to eq('Starship (Lunar Variant)')
    end

    it 'initializes with the correct craft_type' do
      expect(craft.craft_type).to eq('transport')
    end

    it 'initializes with the correct location' do
      expect(craft.current_location).to eq('Shackleton Crater Base')
    end    

    it 'creates recommended units using the real unit data' do
      craft.base_units.reload
      
      # Count based on items in the mocked JSON data (9 different types, total of 14 units)
      expect(craft.base_units.count).to eq(14)  
      expect(craft.base_units.where(unit_type: 'raptor_engine').count).to eq(6)
      expect(craft.base_units.where(unit_type: 'lox_tank').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'methane_tank').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'storage_unit').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'starship_habitat_unit').count).to eq(1)
      # etc.
    end
  end

  describe 'loading craft info' do
    it 'loads the correct craft data from the lookup service' do
      # Create a new craft directly to test the load_craft_info method
      new_craft = Craft::BaseCraft.new(
        name: 'Test Craft', 
        craft_name: 'Starship (Lunar Variant)', 
        craft_type: 'transport',
        owner: create(:player)
      )
      
      # Force validation which triggers load_craft_info
      new_craft.valid?
      
      # Check that the operational_data was populated
      expect(new_craft.operational_data).to be_present
      expect(new_craft.operational_data['name']).to eq('Starship (Lunar Variant)')
      expect(new_craft.operational_data['craft_type']). to eq('transport')
      expect(new_craft.operational_data['recommended_units']).to be_present
    end
  end

  describe 'player construction' do
    let(:player) { create(:player) }
    
    # Update the player_craft let block
    let(:player_craft) do
      # Create a craft with the player_constructed trait
      craft = create(:base_craft, :player_constructed)
      craft.reload  # Force reload to ensure the flag is loaded
      craft
    end
    
    it 'starts with no units' do
      expect(player_craft.base_units.count).to eq(0)
    end
    
    it 'allows installing units' do
      # Create a standalone unit
      unit = create(:base_unit, unit_type: 'cargo_bay', owner: player)
      
      # Install it in the craft
      result = player_craft.install_unit(unit)
      expect(result).to be true
      
      # Verify the unit is now attached to the craft
      unit.reload
      expect(unit.attachable).to eq(player_craft)
      expect(player_craft.base_units.count).to eq(1)
    end
    
    it 'allows uninstalling units' do
      # Create a craft with a unit
      unit = create(:base_unit, unit_type: 'cargo_bay', owner: player)
      player_craft.install_unit(unit)
      
      # Uninstall the unit
      result = player_craft.uninstall_unit(unit)
      expect(result).to be true
      
      # Verify the unit is detached
      unit.reload
      expect(unit.attachable).to be_nil
      expect(player_craft.base_units.count).to eq(0)
    end
  end

  describe 'variant configuration' do
    let(:variant_manager) { instance_double(Craft::VariantManager) }
    let(:standard_variant) do
      {
        'id' => 'starship',
        'name' => 'Starship (Standard)',
        'operational_status' => {
          'status' => 'offline',
          'variant_configuration' => 'starship_standard'
        },
        'recommended_units' => [
          {'id' => 'raptor_engine', 'count' => 6}
        ]
      }
    end
    
    let(:lunar_variant) do
      {
        'id' => 'starship',
        'name' => 'Starship (Lunar Variant)',
        'operational_status' => {
          'status' => 'offline',
          'variant_configuration' => 'starship_lunar'
        },
        'recommended_units' => [
          {'id' => 'raptor_engine', 'count' => 6},
          {'id' => 'life_support_unit', 'count' => 2}
        ]
      }
    end
    
    before do
      allow(Craft::VariantManager).to receive(:new).and_return(variant_manager)
      allow(variant_manager).to receive(:available_variants).and_return(['starship_standard', 'starship_lunar'])
      allow(variant_manager).to receive(:get_variant).with('starship_standard').and_return(standard_variant)
      allow(variant_manager).to receive(:get_variant).with('starship_lunar').and_return(lunar_variant)
      allow(variant_manager).to receive(:get_variant).with(nil).and_return(standard_variant)
    end
    
    it 'loads a variant configuration' do
      test_craft = create(:base_craft, craft_type: 'transport/spaceships/starship')
      
      expect(test_craft.load_variant_configuration('starship_lunar')).to be true
      expect(test_craft.operational_data).to eq(lunar_variant)
    end
    
    it 'changes between variants' do
      test_craft = create(:base_craft, craft_type: 'transport/spaceships/starship')
      
      # First load lunar variant
      test_craft.load_variant_configuration('starship_lunar')
      expect(test_craft.operational_data['name']).to eq('Starship (Lunar Variant)')
      
      # Then switch to standard variant
      expect(test_craft.change_variant('starship_standard')).to be true
      expect(test_craft.operational_data['name']).to eq('Starship (Standard)')
    end
    
    it 'provides a list of available variants' do
      test_craft = create(:base_craft, craft_type: 'transport/spaceships/starship')
      expect(test_craft.available_variants).to contain_exactly('starship_standard', 'starship_lunar')
    end
    
    it 'handles missing variants gracefully' do
      test_craft = create(:base_craft, craft_type: 'transport/spaceships/starship')
      
      allow(variant_manager).to receive(:get_variant).with('non_existent').and_return(nil)
      
      expect(test_craft.load_variant_configuration('non_existent')).to be false
      # Original operational data should remain unchanged
      expect(test_craft.operational_data).not_to be_nil
    end
  end

  describe "atmosphere creation" do
    let(:craft) { create(:base_craft, craft_name: "Explorer", craft_type: "science") }
    
    it "creates an atmosphere after creation" do
      expect(craft.atmosphere).to be_present
      expect(craft.atmosphere.craft_id).to eq(craft.id)
      expect(craft.atmosphere.environment_type).to eq('artificial')
    end
  end
end