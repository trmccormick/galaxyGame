require 'rails_helper'

RSpec.describe Structures::BaseStructure, type: :model do
  let(:player) { create(:player) }
  let(:celestial_body) { create(:celestial_body, :luna) }
  let(:settlement) { create(:base_settlement, owner: player) }
  
  # Define a minimal structure directly in the test
  let(:structure) do
    # Create without callbacks to avoid automatic unit building
    structure = build(:base_structure, 
      name: "Test Nuclear Facility",
      structure_name: "nuclear_fuel_reprocessing_facility",
      structure_type: "resource_processing",
      settlement: settlement,
      owner: player
    )
    
    # Set operational data directly
    structure.operational_data = {
      "template" => "structure_operational_data",
      "id" => "nuclear_fuel_reprocessing_facility",
      "name" => "Nuclear Fuel Reprocessing Facility",
      "category" => "structure",
      "subcategory" => "resource_processing",
      "operational_status" => { "status" => "offline", "condition" => 100, "degradation_rate" => 0.05 },
      "resource_management" => {
        "consumables" => {
          "energy_kwh" => {"rate" => 2500.0, "current_usage" => 0},
          "uranium_ore_kg" => {"rate" => 100.0, "current_usage" => 0}
        },
        "generated" => {
          "liquid_uranium_fuel_kg" => {"rate" => 10.0, "current_output" => 0}
        }
      },
      "systems" => {
        "uranium_enrichment" => {"status" => "not_installed", "efficiency_percent" => 0},
        "fuel_liquefaction" => {"status" => "not_installed", "efficiency_percent" => 0},
        "power_distribution" => {"status" => "offline", "efficiency_percent" => 0}
      },
      "unit_slots" => [
        {"type" => "production/refineries", "count" => 4},
        {"type" => "energy", "count" => 2},
        {"type" => "computers", "count" => 1}
      ],
      "module_slots" => [
        {"type" => "power", "count" => 1},
        {"type" => "computer", "count" => 1}
      ],
      "operational_modes" => {
        "current_mode" => "standby",
        "available_modes" => [
          {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
          {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
        ]
      }
    }
    
    # Save and return
    structure.save!
    structure
  end

  # Set up common mocks
  before do
    # Mock the structure lookup service
    allow_any_instance_of(Lookup::StructureLookupService).to receive(:find_structure)
      .with(anything, anything)
      .and_return(structure.operational_data)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(structure).to be_valid
    end

    it "is not valid without a name" do
      structure.name = nil
      expect(structure).not_to be_valid
    end

    it "is not valid without a structure_name" do
      structure.structure_name = nil
      expect(structure).not_to be_valid
    end

    it "is not valid without a structure_type" do
      structure.structure_type = nil
      expect(structure).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a settlement" do
      expect(structure.settlement).to eq(settlement)
    end

    it "belongs to an owner" do
      expect(structure.owner).to eq(player)
    end

    it "has many base_units" do
      # Create unit directly
      unit = build(:base_unit, unit_type: "control_computer", name: "Test Computer", owner: player)
      unit.attachable = structure
      unit.save!
      
      structure.reload
      expect(structure.base_units).to include(unit)
    end

    it "has many modules" do
      # Create module directly without owner attribute
      mod = build(:base_module, 
        module_type: "efficiency_optimizer", 
        name: "Test Module"
        # Remove owner: player
      )
      mod.attachable = structure
      mod.save!
      
      structure.reload
      expect(structure.modules).to include(mod)
    end
  end

  describe "#operational?" do
    let(:power_unit) do
      unit = build(:base_unit, unit_type: "power_generator", name: "Power Generator", owner: player)
      unit.attachable = structure
      unit.save!
      unit
    end
    
    let(:control_unit) do
      unit = build(:base_unit, unit_type: "control_computer", name: "Control Computer", owner: player)
      unit.attachable = structure
      unit.save!
      unit
    end
    
    it "returns false when missing required units" do
      allow(structure).to receive(:has_minimum_required_units?).and_return(false)
      expect(structure.operational?).to be false
    end
    
    it "returns false when power system is offline" do
      # Add the required units 
      power_unit
      control_unit
      
      # Stub the required methods
      allow(structure).to receive(:has_minimum_required_units?).and_return(true)
      allow(structure).to receive(:system_status).with('power_distribution').and_return('offline')
      
      expect(structure.operational?).to be false
    end
    
    it "returns true when all requirements are met" do
      # Add the required units
      power_unit
      control_unit
      
      # Stub the required methods
      allow(structure).to receive(:has_minimum_required_units?).and_return(true)
      allow(structure).to receive(:system_status).with('power_distribution').and_return('online')
      
      expect(structure.operational?).to be true
    end
    
    it "returns false when in maintenance mode" do
      # Add the required units
      power_unit
      control_unit
      
      # Stub the required methods
      allow(structure).to receive(:has_minimum_required_units?).and_return(true)
      allow(structure).to receive(:system_status).with('power_distribution').and_return('online')
      allow(structure).to receive(:current_mode).and_return('maintenance')
      
      expect(structure.operational?).to be false
    end
  end

  describe "unit management" do
    let(:unit_data) do
      {
        "id" => "uranium_enrichment_centrifuge",
        "name" => "Uranium Enrichment Centrifuge",
        "type" => "production/refineries"
      }
    end
    
    before do
      allow_any_instance_of(Lookup::UnitLookupService).to receive(:find_unit)
        .with("uranium_enrichment_centrifuge")
        .and_return(unit_data)
    end
    
    describe "#install_unit" do
      let(:unit) { create(:base_unit, unit_type: "uranium_enrichment_centrifuge", name: "Test Centrifuge", owner: player) }
      
      it "installs a unit if slot is available" do
        allow(structure).to receive(:available_unit_slots).and_return(1)
        expect(structure.install_unit(unit)).to be true
        unit.reload
        expect(unit.attachable).to eq(structure)
      end
      
      it "fails if no slot is available" do
        allow(structure).to receive(:available_unit_slots).and_return(0)
        expect(structure.install_unit(unit)).to be false
        unit.reload
        expect(unit.attachable).not_to eq(structure)
      end
    end
    
    describe "#uninstall_unit" do
      let(:unit) do
        unit = build(:base_unit, unit_type: "uranium_enrichment_centrifuge", name: "Test Centrifuge", owner: player)
        unit.attachable = structure
        unit.save!
        unit
      end
      
      it "removes an installed unit" do
        # Force creation of the unit
        unit
        structure.reload
        
        expect(structure.uninstall_unit(unit)).to be true
        unit.reload
        expect(unit.attachable).to be_nil
      end
      
      it "fails for units not attached to the structure" do
        other_unit = create(:base_unit, unit_type: "uranium_enrichment_centrifuge", name: "Other Centrifuge", owner: player)
        expect(structure.uninstall_unit(other_unit)).to be false
      end
    end
    
    describe "#build_recommended_units" do
      before do
        structure.operational_data["recommended_units"] = [
          {"id" => "uranium_enrichment_centrifuge", "count" => 2, "type" => "production/refineries"}
        ]
        structure.save
        
        # Mock the unit creation to avoid dependency issues
        unit = build(:base_unit, unit_type: "uranium_enrichment_centrifuge", name: "Mocked Unit", owner: player)
        allow(structure.base_units).to receive(:create!).and_return(unit)
      end
      
      it "builds the recommended units" do
        # Expect the create! method to be called twice (for 2 units)
        expect(structure.base_units).to receive(:create!).twice
        structure.build_recommended_units
      end
    end
  end

  describe "module management" do
    let(:module_data) do
      {
        "id" => "efficiency_optimizer",
        "name" => "Efficiency Optimizer",
        "type" => "power"
      }
    end
    
    before do
      allow_any_instance_of(Lookup::ModuleLookupService).to receive(:find_module)
        .with("efficiency_optimizer")
        .and_return(module_data)
    end
    
    describe "#build_recommended_modules" do
      before do
        structure.operational_data["recommended_modules"] = [
          {"id" => "efficiency_optimizer", "count" => 1, "type" => "power"}
        ]
        structure.save
        
        # Mock the module creation without owner attribute
        mod = build(:base_module, 
          module_type: "efficiency_optimizer", 
          name: "Mocked Module"
          # Remove owner: player
        )
        allow(structure.modules).to receive(:create!).and_return(mod)
      end
      
      it "builds the recommended modules" do
        # Expect the create! method to be called once (for 1 module)
        expect(structure.modules).to receive(:create!).once
        structure.build_recommended_modules
      end
    end
  end

  describe "operational mode management" do
    describe "#current_mode" do
      it "returns the current operational mode" do
        expect(structure.current_mode).to eq("standby")
      end
      
      it "returns 'standby' as default if not set" do
        structure.operational_data["operational_modes"].delete("current_mode")
        structure.save
        
        expect(structure.current_mode).to eq("standby")
      end
    end
    
    describe "#set_operational_mode" do
      it "changes the operational mode if valid" do
        allow(structure).to receive(:available_modes).and_return(["standby", "production"])
        expect(structure.set_operational_mode("production")).to be true
        expect(structure.current_mode).to eq("production")
      end
      
      it "fails if mode is invalid" do
        allow(structure).to receive(:available_modes).and_return(["standby", "production"])
        expect(structure.set_operational_mode("invalid_mode")).to be false
        expect(structure.current_mode).to eq("standby")
      end
    end
    
    describe "#available_modes" do
      it "returns all available operational modes" do
        expect(structure.available_modes).to contain_exactly("standby", "production")
      end
      
      it "returns ['standby'] as default if not set" do
        structure.operational_data["operational_modes"].delete("available_modes")
        structure.save
        
        expect(structure.available_modes).to eq(["standby"])
      end
    end
  end

  describe "module effect management" do
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
        mod.attachable = structure
        mod.save!
      end
    end
    
    it "supports adding and removing module effects via HasModules concern" do
      # Set initial efficiency
      structure.operational_data["systems"]["power_distribution"]["efficiency_percent"] = 80
      structure.save!
      
      # Verify module effect is applied
      expect(structure.add_module_effect(efficiency_module)).to be true
      expect(structure.operational_data["systems"]["power_distribution"]["efficiency_percent"]).to be > 80
      
      # Verify module effect is removed
      expect(structure.remove_module_effect(efficiency_module)).to be true
      expect(structure.operational_data["systems"]["power_distribution"]["efficiency_percent"]).to eq(80)
    end
  end
end