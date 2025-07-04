# spec/services/unit_module_assembly_service_spec.rb
# spec/services/unit_module_assembly_service_spec.rb

require 'rails_helper'

RSpec.describe UnitModuleAssemblyService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, owner: player) }
  
  # Use the settlement's inventory
  let(:inventory) { settlement.inventory }
  
  # Create a craft with operational data that includes recommended fit
  let(:craft) do
    create(:base_craft, 
      owner: settlement,
      operational_data: {
        'recommended_fit' => {
          'units' => [
            { 'id' => 'basic_engine', 'count' => 2, 'port_type' => 'engine_port' },
            { 'id' => 'life_support', 'count' => 1, 'port_type' => 'habitat_port' }
          ],
          'modules' => [
            { 'id' => 'efficiency_module', 'count' => 1 }
          ],
          'rigs' => [
            { 'id' => 'cargo_expander', 'count' => 1 }
          ]
        },
        'custom_port_configurations' => [
          { 'item_id' => 'landing_gear', 'count' => 1, 'port_type' => 'landing_gear_mount' }
        ]
      }
    )
  end
  
  before do
    # Make sure the settlement has adequate storage capacity
    allow(settlement).to receive(:surface_storage?).and_return(true)
    
    # Add items to inventory - explicitly set the player as owner for each item
    inventory.add_item('basic_engine', 2, player)
    inventory.add_item('life_support', 1, player)
    inventory.add_item('efficiency_module', 1, player)
    inventory.add_item('cargo_expander', 1, player)
    inventory.add_item('landing_gear', 1, player)
  end
  
  describe '.build_units_and_modules' do
    it 'creates units from the recommended fit' do
      # The count should be by(4) - 2 engines + 1 life support + 1 landing gear
      expect {
        UnitModuleAssemblyService.build_units_and_modules(
          target: craft, 
          settlement_inventory: inventory
        )
      }.to change { craft.base_units.count }.by(4) # 2 engines + 1 life support + 1 landing gear
      
      # Verify specific units were created
      expect(craft.base_units.where(unit_type: 'basic_engine').count).to eq(2)
      expect(craft.base_units.where(unit_type: 'life_support').count).to eq(1)
      expect(craft.base_units.where(unit_type: 'landing_gear').count).to eq(1)
      
      # Verify the components' owner is set to the settlement
      expect(craft.base_units.first.owner).to eq(settlement)
      
      # Verify items were removed from inventory
      expect(inventory.items.find_by(name: 'basic_engine')).to be_nil
      expect(inventory.items.find_by(name: 'life_support')).to be_nil
      expect(inventory.items.find_by(name: 'landing_gear')).to be_nil
    end
    
    it 'creates modules from the recommended fit' do
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft, 
        settlement_inventory: inventory
      )
      
      expect(result.modules.count).to eq(1)
      expect(result.modules.first.module_type).to eq('efficiency_module')
      expect(inventory.items.find_by(name: 'efficiency_module')).to be_nil
    end
    
    it 'creates rigs from the recommended fit' do
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft, 
        settlement_inventory: inventory
      )
      
      expect(result.rigs.count).to eq(1)
      expect(result.rigs.first.rig_type).to eq('cargo_expander')
      expect(inventory.items.find_by(name: 'cargo_expander')).to be_nil
    end
    
    it 'processes custom port configurations' do
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft, 
        settlement_inventory: inventory
      )
      
      # Verify landing gear was created with special port
      landing_gear = result.base_units.find_by(unit_type: 'landing_gear')
      expect(landing_gear).to be_present
      expect(inventory.items.find_by(name: 'landing_gear')).to be_nil
    end
    
    it 'handles missing inventory items gracefully' do
      # Remove an item from inventory
      inventory.remove_item('basic_engine', 1, player)
      
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft, 
        settlement_inventory: inventory
      )
      
      # Should only create one engine instead of two
      expect(result.base_units.where(unit_type: 'basic_engine').count).to eq(1)
      expect(inventory.items.find_by(name: 'basic_engine')).to be_nil
    end
    
    it 'handles missing recommended fit data gracefully' do
      # For this test, we need to stub the model validation
      # since empty operational_data is not allowed by validation
      craft_without_fit = build(:base_craft, owner: settlement)
      allow(craft_without_fit).to receive(:operational_data).and_return({})
      allow(craft_without_fit).to receive(:persisted?).and_return(true)
      allow(craft_without_fit).to receive(:id).and_return(999)
      allow(craft_without_fit).to receive(:base_units).and_return([])
      allow(craft_without_fit).to receive(:modules).and_return([])
      allow(craft_without_fit).to receive(:rigs).and_return([])
      
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft_without_fit, 
        settlement_inventory: inventory
      )
      
      # Should return the craft without creating any components
      expect(result).to eq(craft_without_fit)
      expect(result.base_units.count).to eq(0)
      expect(result.modules.count).to eq(0)
      expect(result.rigs.count).to eq(0)
      
      # Inventory should remain unchanged
      expect(inventory.items.count).to eq(5)
    end
    
    it 'assigns correct port names to components' do
      result = UnitModuleAssemblyService.build_units_and_modules(
        target: craft, 
        settlement_inventory: inventory
      )
      
      # First engine should have port_name "engine_port_1"
      engines = result.base_units.where(unit_type: 'basic_engine').order(:id)
      expect(engines.first.operational_data['port']).to eq('engine_port_1')
      expect(engines.second.operational_data['port']).to eq('engine_port_2')
      
      # Life support should have port_name "habitat_port_1"
      life_support = result.base_units.find_by(unit_type: 'life_support')
      expect(life_support.operational_data['port']).to eq('habitat_port_1')
      
      # Module should have port_name "module_slot_1"
      module_item = result.modules.first
      expect(module_item.operational_data['port']).to eq('module_slot_1')
      
      # Rig should have port_name "rig_mount_1"
      rig = result.rigs.first
      expect(rig.operational_data['port']).to eq('rig_mount_1')
    end
  end
end