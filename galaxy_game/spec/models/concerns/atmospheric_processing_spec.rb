# spec/models/concerns/atmospheric_processing_spec.rb
require 'rails_helper'

RSpec.describe AtmosphericProcessing, type: :model do
  # Create test classes that include the concern
  let(:test_unit_class) do
    Class.new do
      include ActiveModel::Model
      include AtmosphericProcessing
      
      attr_accessor :operational_data, :attachable
      
      def respond_to?(method_name, include_private = false)
        return true if [:save!, :consume_energy].include?(method_name)
        super
      end
      
      def save!
        true
      end
      
      def consume_energy(amount)
        true
      end
    end
  end
  
  let(:test_module_class) do
    Class.new do
      include ActiveModel::Model
      include AtmosphericProcessing
      
      attr_accessor :operational_data, :attachable
      
      def respond_to?(method_name, include_private = false)
        return true if [:save!, :consume_energy].include?(method_name)
        super
      end
      
      def save!
        true
      end
      
      def consume_energy(amount)
        true
      end
    end
  end
  
  # Mock atmosphere for testing
  let(:mock_atmosphere) do
    double('Atmosphere',
      has_sufficient_gas?: true,
      remove_gas: true,
      add_gas: true,
      filter_contaminants: 5.0
    )
  end
  
  let(:mock_attachable) do
    double('Attachable', atmosphere: mock_atmosphere)
  end

  describe "when included in a unit (new template format)" do
    let(:unit) { test_unit_class.new }
    
    before do
      unit.attachable = mock_attachable
    end
    
    context "with atmospheric processing capabilities" do
      before do
        unit.operational_data = {
          "processing_capabilities" => {
            "atmospheric_processing" => {
              "enabled" => true,
              "types" => ["co2_to_oxygen", "gas_conversion"],
              "efficiency" => 0.95
            }
          },
          "input_resources" => [
            { "id" => "CO₂", "amount" => 40.0, "unit" => "kg" }
          ],
          "output_resources" => [
            { "id" => "oxygen", "amount" => 30.0, "unit" => "kg" }
          ],
          "consumables" => {
            "energy" => 18.0
          }
        }
      end
      
      describe "#can_process_atmosphere?" do
        it "returns true when atmospheric processing is enabled" do
          expect(unit.can_process_atmosphere?).to be true
        end
        
        it "returns false when atmospheric processing is disabled" do
          unit.operational_data["processing_capabilities"]["atmospheric_processing"]["enabled"] = false
          expect(unit.can_process_atmosphere?).to be false
        end
        
        it "returns false when processing_capabilities is missing" do
          unit.operational_data.delete("processing_capabilities")
          # ✅ Also remove atmospheric input/output resources
          unit.operational_data.delete("input_resources")
          unit.operational_data.delete("output_resources")
          
          expect(unit.can_process_atmosphere?).to be false
        end
      end
      
      describe "#atmospheric_capabilities" do
        it "returns capabilities based on processing types" do
          capabilities = unit.atmospheric_capabilities
          
          expect(capabilities[:co2_to_o2]).to be true
          expect(capabilities[:gas_conversion]).to be true
          # ✅ FIX: Check the value, not key existence
          expect(capabilities[:co2_scrubbing]).to be false
          expect(capabilities[:air_filtration]).to be false
          expect(capabilities[:co2_venting]).to be false
        end
        
        it "returns empty hash when can't process atmosphere" do
          unit.operational_data["processing_capabilities"]["atmospheric_processing"]["enabled"] = false
          expect(unit.atmospheric_capabilities).to eq({})
        end
      end
      
      describe "#max_processing_rate" do
        it "returns rate for CO₂ input" do
          expect(unit.max_processing_rate('CO₂')).to eq(40.0)
        end
        
        it "returns rate for oxygen output" do
          expect(unit.max_processing_rate('oxygen')).to eq(30.0)
        end
        
        it "returns 0 for unknown substance" do
          expect(unit.max_processing_rate('nitrogen')).to eq(0)
        end
      end
      
      describe "#process_atmosphere!" do
        context "CO2 to oxygen conversion" do
          it "processes CO2 to oxygen successfully" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 40.0).and_return(true)
            expect(mock_atmosphere).to receive(:remove_gas).with('CO2', 40.0)
            expect(mock_atmosphere).to receive(:add_gas).with('O2', 30.0)
            expect(unit).to receive(:consume_energy).with(18.0)
            
            result = unit.process_atmosphere!(:co2_to_o2_conversion)
            expect(result).to be true
          end
          
          it "fails when insufficient CO2 available" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 40.0).and_return(false)
            expect(mock_atmosphere).not_to receive(:remove_gas)
            expect(mock_atmosphere).not_to receive(:add_gas)
            
            result = unit.process_atmosphere!(:co2_to_o2_conversion)
            expect(result).to be false
          end
          
          it "fails when no atmosphere available" do
            unit.attachable = double('Attachable', atmosphere: nil)
            
            result = unit.process_atmosphere!(:co2_to_o2_conversion)
            expect(result).to be false
          end
        end
        
        it "returns false for unsupported processing type" do
          result = unit.process_atmosphere!(:unsupported_process)
          expect(result).to be false
        end
      end
    end
    
    context "without atmospheric processing capabilities" do
      before do
        unit.operational_data = {
          "processing_capabilities" => {
            "geosphere_processing" => {
              "enabled" => true,
              "types" => ["mineral_extraction"]
            }
          }
        }
      end
      
      it "cannot process atmosphere" do
        expect(unit.can_process_atmosphere?).to be false
      end
      
      it "returns empty atmospheric capabilities" do
        expect(unit.atmospheric_capabilities).to eq({})
      end
      
      it "fails to process atmosphere" do
        result = unit.process_atmosphere!(:co2_to_o2_conversion)
        expect(result).to be false
      end
    end
  end

  describe "when included in a module (existing JSON format)" do
    let(:module_obj) { test_module_class.new }
    
    before do
      module_obj.attachable = mock_attachable
    end
    
    context "CO2 scrubber module" do
      before do
        module_obj.operational_data = {
          "name" => "CO2 Scrubber Module",
          "input_resources" => [
            { "id" => "air", "amount" => 100, "unit" => "m³" }
          ],
          "output_resources" => [
            { "id" => "stored_co2", "amount" => 2.5, "unit" => "kg" }
          ],
          "consumables" => {
            "energy" => 5.0
          },
          "operational_data" => {
            "cartridge_max_co2" => 25,
            "current_cartridge_level" => 10
          }
        }
      end
      
      describe "#can_process_atmosphere?" do
        it "returns true when has atmospheric input/output resources" do
          expect(module_obj.can_process_atmosphere?).to be true
        end
        
        it "returns false when no atmospheric resources" do
          module_obj.operational_data["input_resources"] = [
            { "id" => "metal_ore", "amount" => 50, "unit" => "kg" }
          ]
          module_obj.operational_data["output_resources"] = [
            { "id" => "processed_metal", "amount" => 45, "unit" => "kg" }
          ]
          expect(module_obj.can_process_atmosphere?).to be false
        end
      end
      
      describe "#atmospheric_capabilities" do
        it "returns capabilities based on resource flow" do
          capabilities = module_obj.atmospheric_capabilities
          
          expect(capabilities[:co2_scrubbing]).to be true
          expect(capabilities[:air_filtration]).to be false
          expect(capabilities[:co2_venting]).to be false
        end
      end
      
      describe "#process_atmosphere!" do
        context "CO2 scrubbing" do
          it "scrubs CO2 from atmosphere successfully" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 2.5).and_return(true)
            expect(mock_atmosphere).to receive(:remove_gas).with('CO2', 2.5)
            expect(module_obj).to receive(:consume_energy).with(5.0)
            
            result = module_obj.process_atmosphere!(:co2_scrubbing)
            expect(result).to be true
            
            # Check cartridge level increased
            expect(module_obj.operational_data["operational_data"]["current_cartridge_level"]).to eq(12.5)
          end
          
          it "fails when cartridge is full" do
            module_obj.operational_data["operational_data"]["current_cartridge_level"] = 25
            
            result = module_obj.process_atmosphere!(:co2_scrubbing)
            expect(result).to be false
          end
          
          it "fails when insufficient CO2 in atmosphere" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 2.5).and_return(false)
            expect(mock_atmosphere).not_to receive(:remove_gas)
            
            result = module_obj.process_atmosphere!(:co2_scrubbing)
            expect(result).to be false
          end
        end
      end
    end
    
    context "air filtration module" do
      before do
        module_obj.operational_data = {
          "name" => "Air Filtration System",
          "input_resources" => [
            { "id" => "unfiltered_air", "amount" => 200, "unit" => "m³" }
          ],
          "output_resources" => [
            { "id" => "filtered_air", "amount" => 200, "unit" => "m³" }
          ],
          "operational_data" => {
            "filter_efficiency" => 0.99
          }
        }
      end
      
      describe "#atmospheric_capabilities" do
        it "identifies air filtration capability" do
          capabilities = module_obj.atmospheric_capabilities
          
          expect(capabilities[:air_filtration]).to be true
          expect(capabilities[:co2_scrubbing]).to be false
        end
      end
      
      describe "#process_atmosphere!" do
        context "air filtration" do
          it "filters air successfully" do
            allow(mock_atmosphere).to receive(:filter_contaminants).with(0.99).and_return(5.0)
            
            result = module_obj.process_atmosphere!(:air_filtration)
            expect(result).to be true
          end
          
          it "fails when no contaminants removed" do
            allow(mock_atmosphere).to receive(:filter_contaminants).with(0.99).and_return(0)
            
            result = module_obj.process_atmosphere!(:air_filtration)
            expect(result).to be false
          end
        end
      end
    end
    
    context "CO2 venting module" do
      before do
        module_obj.operational_data = {
          "name" => "CO2 Venting System",
          "input_resources" => [
            { "id" => "CO₂", "amount" => 10, "unit" => "kg" }
          ],
          "output_resources" => [
            { "id" => "vented_CO₂", "amount" => 10, "unit" => "kg" }
          ],
          "operational_modes" => {
            "space" => {
              "output_resources" => [
                { "id" => "vented_CO₂", "amount" => 10, "unit" => "kg" }
              ]
            },
            "atmosphere" => {
              "output_resources" => [
                { "id" => "vented_CO₂", "amount" => 8, "unit" => "kg" }
              ]
            }
          }
        }
      end
      
      describe "#atmospheric_capabilities" do
        it "identifies CO2 venting capability" do
          capabilities = module_obj.atmospheric_capabilities
          
          expect(capabilities[:co2_venting]).to be true
        end
      end
      
      describe "#process_atmosphere!" do
        context "CO2 venting" do
          it "vents CO2 to space successfully" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 10).and_return(true)
            expect(mock_atmosphere).to receive(:remove_gas).with('CO2', 10)
            
            result = module_obj.process_atmosphere!(:co2_venting, mode: 'space')
            expect(result).to be true
          end
          
          it "vents CO2 to atmosphere with different rate" do
            allow(mock_atmosphere).to receive(:has_sufficient_gas?).with('CO2', 8).and_return(true)
            expect(mock_atmosphere).to receive(:remove_gas).with('CO2', 8)
            
            result = module_obj.process_atmosphere!(:co2_venting, mode: 'atmosphere')
            expect(result).to be true
          end
          
          it "fails when operational mode doesn't exist" do
            result = module_obj.process_atmosphere!(:co2_venting, mode: 'underwater')
            expect(result).to be false
          end
        end
      end
    end
  end

  describe "error handling" do
    let(:unit) { test_unit_class.new }
    
    it "handles missing operational_data gracefully" do
      unit.operational_data = nil
      
      expect(unit.can_process_atmosphere?).to be false
      expect(unit.atmospheric_capabilities).to eq({})
      expect(unit.max_processing_rate('CO₂')).to eq(0)
      expect(unit.process_atmosphere!(:co2_to_o2_conversion)).to be false
    end
    
    it "handles malformed operational_data gracefully" do
      unit.operational_data = { "invalid" => "data" }
      
      expect(unit.can_process_atmosphere?).to be false
      expect(unit.atmospheric_capabilities).to eq({})
    end
    
    it "handles missing attachable gracefully" do
      unit.operational_data = {
        "processing_capabilities" => {
          "atmospheric_processing" => { "enabled" => true }
        }
      }
      unit.attachable = nil
      
      expect(unit.process_atmosphere!(:co2_to_o2_conversion)).to be false
    end
  end

  describe "private helper methods" do
    let(:unit) { test_unit_class.new }
    
    describe "#has_processing_capabilities?" do
      it "returns true when atmospheric processing enabled" do
        unit.operational_data = {
          "processing_capabilities" => {
            "atmospheric_processing" => { "enabled" => true }
          }
        }
        expect(unit.send(:has_processing_capabilities?)).to be true
      end
      
      it "returns false when atmospheric processing disabled" do
        unit.operational_data = {
          "processing_capabilities" => {
            "atmospheric_processing" => { "enabled" => false }
          }
        }
        expect(unit.send(:has_processing_capabilities?)).to be false
      end
    end
    
    describe "#has_atmospheric_operations?" do
      it "returns true when has atmospheric resources" do
        unit.operational_data = {
          "input_resources" => [
            { "id" => "air", "amount" => 100 }
          ]
        }
        expect(unit.send(:has_atmospheric_operations?)).to be true
      end
      
      it "returns false when no atmospheric resources" do
        unit.operational_data = {
          "input_resources" => [
            { "id" => "metal_ore", "amount" => 50 }
          ]
        }
        expect(unit.send(:has_atmospheric_operations?)).to be false
      end
    end
    
    describe "#has_resource_flow?" do
      before do
        unit.operational_data = {
          "input_resources" => [
            { "id" => "air", "amount" => 100 }
          ],
          "output_resources" => [
            { "id" => "stored_co2", "amount" => 2.5 }
          ]
        }
      end
      
      it "returns true when both input and output exist" do
        expect(unit.send(:has_resource_flow?, 'air', 'stored_co2')).to be true
      end
      
      it "returns false when input missing" do
        expect(unit.send(:has_resource_flow?, 'nitrogen', 'stored_co2')).to be false
      end
      
      it "returns false when output missing" do
        expect(unit.send(:has_resource_flow?, 'air', 'oxygen')).to be false
      end
    end
  end
end