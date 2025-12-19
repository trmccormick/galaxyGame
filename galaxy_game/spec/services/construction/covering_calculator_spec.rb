require 'rails_helper'

RSpec.describe Construction::CoveringCalculator, type: :service do
  let(:skylight) { double("Skylight", width: 50, length: 100) }
  let(:blueprint) { double("Blueprint", name: "Skylight Array", materials: { "Lunar Aluminum Alloy" => 10, "Basalt Fiber" => 5 }) }

  describe ".calculate_materials" do
    it "calculates required 3D-printed I-beams from regolith" do
      materials = described_class.calculate_materials(skylight, blueprint)
      
      # Verify I-beam calculation (11 x 21 = 231 I-beams for a 50x100 skylight with 5m spacing)
      expect(materials["3d_printed_ibeams"]).to eq(231)
      
      # Verify total regolith needed
      expected_regolith = 231 * 75.0 + 210 * 25.0 # I-beams + panels
      expect(materials["processed_regolith"]).to be_within(1).of(expected_regolith)
      
      # Verify metal extract
      expect(materials["metal_extract"]).to be_within(1).of(231 * 75.0 * 0.4)
      
      # Verify additional blueprint materials are included with scaling
      expect(materials["Lunar Aluminum Alloy"]).to eq(500) # 10 * (5000/100)
      expect(materials["Basalt Fiber"]).to eq(250) # 5 * (5000/100)
    end
  end
  
  describe ".calculate_printer_requirements" do
    it "calculates required 3D printer capacity" do
      requirements = described_class.calculate_printer_requirements(skylight)
      
      # 231 I-beams x 2 hours per beam = 462 hours
      # 462 hours / (24 hours × 7 days) = ~3 printers
      expect(requirements[:printer_count]).to be >= 3
      expect(requirements[:print_hours]).to be_within(10).of(462)
      expect(requirements[:power_required]).to eq(requirements[:printer_count] * 50)
    end
  end
  
  describe ".estimate_construction_time" do
    it "estimates construction time based on skylight size" do
      hours = described_class.estimate_construction_time(skylight)
      
      # Expected calculation:
      # Area: 50 × 100 = 5000 sq meters
      # Base hours: 24
      # Area factor: 5000 / 10 = 500
      # Panel count: ~210 panels
      # Complexity factor: 1 + (210/100) = 3.1
      # Total: (24 + 500) × 3.1 = 1624 hours
      
      expect(hours).to be_within(50).of(1625)
    end
  end
end
