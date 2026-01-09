require 'rails_helper'

# Add this helper method at the top of your spec file
def ensure_complete_structure(structure)
  # Initialize systems if they don't exist
  structure.operational_data["systems"] ||= {}
  structure.operational_data["systems"]["power_distribution"] ||= {"status" => "offline", "efficiency_percent" => 0}
  
  # Initialize resource management structure if it doesn't exist
  structure.operational_data["resource_management"] ||= {}
  structure.operational_data["resource_management"]["consumables"] ||= {}
  structure.operational_data["resource_management"]["consumables"]["energy_kwh"] ||= {"rate" => 0, "current_usage" => 0}
  
  # Initialize active_module_effects if it doesn't exist
  structure.operational_data["active_module_effects"] ||= []
  
  structure.save!
end

RSpec.describe HasModules, type: :concern do
  # Use a real model that includes the concern
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, owner: player) }
  let(:structure) { create(:base_structure, settlement: settlement, owner: player) }
  
  let(:efficiency_module) do
    build(:base_module, module_type: "efficiency_optimizer", name: "Test Efficiency Module").tap do |mod|
      mod.operational_data = {
        "name" => "Efficiency Optimizer",
        "effects" => [
          {
            "type" => "efficiency_boost",
            "target_system" => "power_distribution",
            "value" => 15
          }
        ]
      }
      # Don't set attachable here to avoid auto-application
      mod.save!
    end
  end
  
  let(:power_module) do
    build(:base_module, module_type: "power_reducer", name: "Power Consumption Reducer").tap do |mod|
      mod.operational_data = {
        "name" => "Power Consumption Reducer",
        "effects" => [
          {
            "type" => "power_consumption_reduction",
            "value" => 10
          }
        ]
      }
      mod.attachable = structure
      mod.save!
    end
  end
  
  describe "#add_module_effect" do
    it "applies efficiency boost effect" do
      # Create a new structure for this test only
      fresh_structure = create(:base_structure, settlement: settlement, owner: player)
      
      # Set up a test module with exactly 15% boost
      test_module = build(:base_module, module_type: "test_efficiency", name: "Test Module").tap do |mod|
        mod.operational_data = {
          "name" => "Test Module",
          "effects" => [
            {
              "type" => "efficiency_boost",
              "target_system" => "power_distribution",
              "value" => 15  # Explicitly set to 15
            }
          ]
        }
        # Don't set attachable during creation to avoid auto-application
        mod.save!
      end
      
      # Initialize the data structure
      fresh_structure.operational_data['connection_systems'] ||= {}
      fresh_structure.operational_data['connection_systems']['power_distribution'] = {"status" => "online", "efficiency" => 80}
      fresh_structure.operational_data['active_module_effects'] = []
      fresh_structure.save!
      
      # Apply the effect
      result = fresh_structure.add_module_effect(test_module)
      
      # Verify exactly what we expect
      expect(result).to be true
      expect(fresh_structure.operational_data["connection_systems"]["power_distribution"]["efficiency"]).to eq(95)
    end
    
    it "applies power consumption reduction effect" do
      # Ensure we have a complete structure
      ensure_complete_structure(structure)
      
      # Set initial power consumption
      structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["rate"] = 2500
      structure.save!
      
      # Apply the module effect
      result = structure.add_module_effect(power_module)
      
      # Verify the effect was applied
      expect(result).to be true
      expect(structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["rate"]).to eq(2250)
      expect(structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["original_rate"]).to eq(2500)
    end
  end
  
  describe "#remove_module_effect" do
    it "removes efficiency boost effect" do
      # Create a fresh structure for this test
      fresh_structure = create(:base_structure, settlement: settlement, owner: player)
      ensure_complete_structure(fresh_structure)
      
      # Set initial efficiency
      fresh_structure.operational_data['connection_systems']['power_distribution']['efficiency'] = 80
      
      # Create a fresh module for this test
      test_module = build(:base_module, module_type: "efficiency_optimizer", name: "Test Efficiency Module").tap do |mod|
        mod.operational_data = {
          "name" => "Efficiency Optimizer",
          "effects" => [
            {
              "type" => "efficiency_boost",
              "target_system" => "power_distribution",
              "value" => 15
            }
          ]
        }
        mod.save!
      end
      
      # Add the effect
      fresh_structure.add_module_effect(test_module)
      
      # Verify it was applied
      expect(fresh_structure.operational_data["connection_systems"]["power_distribution"]["efficiency"]).to eq(95)
      
      # Then remove it
      result = fresh_structure.remove_module_effect(test_module)
      
      # Verify the effect was removed
      expect(result).to be true
      expect(fresh_structure.operational_data["connection_systems"]["power_distribution"]["efficiency"]).to eq(80)
      expect(fresh_structure.operational_data["connection_systems"]["power_distribution"]["original_efficiency"]).to be_nil
      expect(fresh_structure.operational_data["active_module_effects"]).to be_empty
    end
    
    it "removes power consumption reduction effect" do
      # Ensure we have a complete structure
      ensure_complete_structure(structure)
      
      # Set initial power consumption
      structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["rate"] = 2500
      
      # Apply the effect
      structure.add_module_effect(power_module)
      
      # Then remove it
      result = structure.remove_module_effect(power_module)
      
      # Verify the effect was removed
      expect(result).to be true
      expect(structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["rate"]).to eq(2500)
      expect(structure.operational_data["resource_management"]["consumables"]["energy_kwh"]["original_rate"]).to be_nil
    end
  end
end