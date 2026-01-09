require 'rails_helper'

RSpec.describe Structures::HasProcessing, type: :concern do
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include ActiveModel::Model
      include Structures::HasProcessing
      
      attr_accessor :name, :operational_data, :inventory, :base_units, :modules
      
      def initialize(attributes = {})
        super
        @name ||= "Test Structure"
        @operational_data ||= {}
        @base_units ||= []
        @modules ||= []
      end
      
      def operational?
        true
      end
      
      def current_mode
        operational_data.dig('operational_modes', 'current_mode') || 'standby'
      end
    end
  end
  
  let(:structure) { test_class.new }
  let(:inventory) { double("Inventory") }
  let(:processing_unit) do
    double("ProcessingUnit", 
      process_resources: {"refined_material" => 10},
      operational?: true,
      prepare_for_processing: true,
      output_buffer: {"refined_material" => 10},
      clear_output_buffer: true,
      required_resources: {"raw_material" => 20},
      receive_resource: true
    )
  end
  
  before do
    # Setup basic structure data
    structure.operational_data = {
      'operational_modes' => {'current_mode' => 'production'},
      'resource_management' => {
        'consumables' => {'raw_material' => {'rate' => 20}},
        'generated' => {'refined_material' => {'rate' => 10}}
      }
    }
    
    # Setup inventory mock
    structure.inventory = inventory
    allow(inventory).to receive(:get_resource_amount).and_return(30)
    allow(inventory).to receive(:remove_item).and_return(20)
    allow(inventory).to receive(:add_item).and_return(10)
    
    # Setup processing units
    structure.base_units = [processing_unit]
  end
  
  describe "#run_processing_cycle" do
    it "runs a complete processing cycle" do
      expect(structure.run_processing_cycle).to be true
    end
    
    it "returns false if structure cannot process" do
      allow(structure).to receive(:can_process?).and_return(false)
      expect(structure.run_processing_cycle).to be false
    end
  end
  
  describe "#can_process?" do
    it "returns true when structure is operational and in production mode" do
      expect(structure.can_process?).to be true
    end
    
    it "returns false when not in production mode" do
      structure.operational_data['operational_modes']['current_mode'] = 'standby'
      expect(structure.can_process?).to be false
    end
    
    it "returns false when not operational" do
      allow(structure).to receive(:operational?).and_return(false)
      expect(structure.can_process?).to be false
    end
    
    it "returns false when no processing units are available" do
      structure.base_units = []
      expect(structure.can_process?).to be false
    end
  end
  
  describe "#processing_units" do
    it "returns units that can process resources" do
      expect(structure.processing_units).to eq([processing_unit])
    end
    
    it "filters out non-operational units" do
      non_operational_unit = double("NonOperationalUnit", process_resources: nil, operational?: false)
      structure.base_units = [processing_unit, non_operational_unit]
      
      expect(structure.processing_units).to eq([processing_unit])
    end
    
    it "filters out units that cannot process" do
      non_processing_unit = double("NonProcessingUnit", operational?: true)
      structure.base_units = [processing_unit, non_processing_unit]
      
      expect(structure.processing_units).to eq([processing_unit])
    end
  end
  
  describe "#check_resource_levels" do
    it "returns true when all required resources are available" do
      expect(structure.check_resource_levels).to be true
    end
    
    it "returns false when a required resource is insufficient" do
      allow(inventory).to receive(:get_resource_amount).and_return(10) # Less than required
      expect(structure.check_resource_levels).to be false
    end
    
    it "returns false when inventory is nil" do
      structure.inventory = nil
      expect(structure.check_resource_levels).to be false
    end
  end
  
  describe "#delegate_processing_to_units" do
    it "delegates processing to each unit" do
      expect(processing_unit).to receive(:process_resources)
      structure.delegate_processing_to_units
    end
    
    it "provides resources to units" do
      expect(processing_unit).to receive(:receive_resource).with("raw_material", 20)
      structure.delegate_processing_to_units
    end
    
    it "returns a hash of processed resources" do
      result = structure.delegate_processing_to_units
      expect(result).to eq({"refined_material" => 10})
    end
    
    it "returns empty hash when no units can process" do
      structure.base_units = []
      expect(structure.delegate_processing_to_units).to eq({})
    end
  end
  
  describe "#collect_processing_results" do
    it "collects output from processing units" do
      expect(inventory).to receive(:add_item).with("refined_material", 10)
      structure.collect_processing_results
    end
    
    it "clears unit output buffers" do
      expect(processing_unit).to receive(:clear_output_buffer).with("refined_material")
      structure.collect_processing_results
    end
    
    it "returns a hash of collected resources" do
      result = structure.collect_processing_results
      expect(result).to eq({"refined_material" => 10})
    end
    
    it "returns empty hash when no units have output" do
      structure.base_units = []
      expect(structure.collect_processing_results).to eq({})
    end
  end
  
  describe "#apply_structure_bonuses" do
    let(:quality_module) do
      double("QualityModule", 
        operational?: true, 
        module_type: "quality_optimizer",
        operational_data: {'effects' => {'quality_bonus' => 0.2}}
      )
    end
    
    it "applies quality bonuses from modules" do
      structure.modules = [quality_module]
      
      # Expect bonus resources to be added
      expect(inventory).to receive(:get_resource_amount).with("refined_material").and_return(100)
      expect(inventory).to receive(:add_item).with("refined_material", 20) # 100 * 0.2 bonus
      
      structure.apply_structure_bonuses
    end
    
    it "returns false when no modules are present" do
      structure.modules = []
      expect(structure.apply_structure_bonuses).to be false
    end
    
    it "returns false when no quality modules are present" do
      regular_module = double("RegularModule", operational?: true, module_type: "regular_module")
      structure.modules = [regular_module]
      
      expect(structure.apply_structure_bonuses).to be false
    end
  end
end