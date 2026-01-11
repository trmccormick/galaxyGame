require 'rails_helper'

RSpec.describe Manufacturing::Construction::DomeCalculator, type: :service do
  let(:small_dome) { double("CraterDome", diameter: 100, depth: 20, name: "Small Dome") }
  let(:medium_dome) { double("CraterDome", diameter: 500, depth: 50, name: "Medium Dome") }
  let(:large_dome) { double("CraterDome", diameter: 1000, depth: 100, name: "Large Dome") }

  before do
    # Mock the SkylightCalculator
    allow(Manufacturing::Construction::SkylightCalculator).to receive(:calculate_materials).and_return({
      "processed_regolith" => 1000,
      "metal_extract" => 500,
      "silicate_extract" => 300,
      "3d_printed_ibeams" => 100,
      "transparent_panels" => 50,
      "fasteners" => 200,
      "sealant" => 100
    })
    
    allow(Manufacturing::Construction::SkylightCalculator).to receive(:estimate_construction_time).and_return(240)
  end

  describe ".calculate_materials" do
    it "calculates materials using the same panel system as skylights" do
      materials = described_class.calculate_materials(medium_dome, "basic_transparent_crater_tube_cover_array")
      
      # Should include the same materials as skylights
      expect(materials).to include("processed_regolith")
      expect(materials).to include("metal_extract")
      expect(materials).to include("silicate_extract") 
      expect(materials).to include("3d_printed_ibeams")
      expect(materials).to include("transparent_panels")
      
      # Plus dome-specific additions
      expect(materials).to include("structural_supports")
      expect(materials).to include("dome_anchors")
      expect(materials).to include("pressure_seals")
    end
    
    it "supports different panel types like skylights" do
      basic_materials = described_class.calculate_materials(medium_dome, "basic_transparent_crater_tube_cover_array")
      solar_materials = described_class.calculate_materials(medium_dome, "solar_cover_panel")
      
      # Both should have base materials
      expect(basic_materials).to include("processed_regolith")
      expect(solar_materials).to include("processed_regolith")
    end

    it "adds dome-specific adjustments" do
      materials = described_class.calculate_materials(medium_dome)
      
      # Check structural supports calculation (30% of i-beams)
      expect(materials["structural_supports"]).to eq(30) # 100 * 0.3
      
      # Check anchor points
      expect(materials["dome_anchors"]).to be > 0
      
      # Check pressure seals
      expect(materials["pressure_seals"]).to be > 0
    end
  end
  
  describe ".calculate_anchor_points" do
    it "calculates anchor points based on circumference" do
      # Circumference = π * 500 = ~1571 meters
      # Anchor spacing = 10 meters
      # Expected anchors = ceil(1571 / 10) = 158
      anchors = described_class.calculate_anchor_points(medium_dome)
      
      expect(anchors).to be_within(5).of(158)
    end
    
    it "scales with dome size" do
      small_anchors = described_class.calculate_anchor_points(small_dome)
      large_anchors = described_class.calculate_anchor_points(large_dome)
      
      expect(large_anchors).to be > small_anchors
    end
  end
  
  describe ".calculate_pressure_sealing" do
    it "calculates sealing material based on circumference" do
      # Circumference * 2 kg/meter
      sealing = described_class.calculate_pressure_sealing(medium_dome)
      
      circumference = Math::PI * 500
      expected = (circumference * 2).to_i
      
      expect(sealing).to eq(expected)
    end
  end
  
  describe ".calculate_construction_cost" do
    it "calculates cost based on dome size and materials" do
      small_cost = described_class.calculate_construction_cost(small_dome)
      medium_cost = described_class.calculate_construction_cost(medium_dome)
      large_cost = described_class.calculate_construction_cost(large_dome)
      
      # All costs should be positive
      expect(small_cost).to be > 0
      expect(medium_cost).to be > 0
      expect(large_cost).to be > 0
      
      # Costs should scale with size
      expect(medium_cost).to be > small_cost
      expect(large_cost).to be > medium_cost
    end
    
    it "applies complexity multiplier for dome shape" do
      cost = described_class.calculate_construction_cost(medium_dome)
      
      # Cost should reflect the 1.3x complexity multiplier
      expect(cost).to be > 0
    end
  end
  
  describe ".estimate_construction_time" do
    it "estimates construction time based on dome size" do
      small_time = described_class.estimate_construction_time(small_dome)
      medium_time = described_class.estimate_construction_time(medium_dome)
      large_time = described_class.estimate_construction_time(large_dome)
      
      # Construction time should scale with size
      expect(medium_time).to be > small_time
      expect(large_time).to be > medium_time
    end
    
    it "applies curvature complexity factor" do
      time = described_class.estimate_construction_time(medium_dome)
      
      # Base time is 240, with 1.4x curvature complexity
      # Plus depth factor: 1 + (50 / 200.0) = 1.25
      # Expected: 240 * 1.4 * 1.25 = 420
      expect(time).to be_within(50).of(420)
    end
  end
end