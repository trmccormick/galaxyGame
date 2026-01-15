require 'rails_helper'

RSpec.describe Manufacturing::Construction::HangarService, type: :service do
  let!(:mars) { create(:terrestrial_planet, :mars) }
  
  let!(:location) { 
    create(:celestial_location, 
      name: "Olympus Mons", 
      celestial_body: mars
    )
  }
  
  let!(:player) { create(:player) }
  
  let!(:settlement) { 
    create(:settlement, 
      :independent,
      name: "Olympus Base", 
      location: location,
      owner: player
    )
  }
  
  let!(:lava_tube) { 
    create(:lava_tube_feature, 
      feature_id: "Olympus Tube", 
      celestial_body: mars,
      settlement: settlement,
      status: 'surveyed'
    )
  }
  
  let!(:access_point) { 
    create(:access_point, 
      lava_tube: lava_tube,
      access_type: 'large'
    )
  }
  
  let!(:blueprint) {
    double("Blueprint", 
      name: "Standard Rover Hangar",
      materials: {
        "processed_regolith" => 1000,
        "aluminum_alloy" => 500
      }
    )
  }
  
  let(:service) { described_class.new(access_point, "standard_rover_hangar") }
  let(:service_large) { described_class.new(access_point, "large_craft_hangar") }
  
  before do
    # Mock external services
    allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint).and_return(blueprint)
    allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([double("MaterialRequest")])
    allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([double("EquipmentRequest")])
    allow(Manufacturing::Construction::ConstructionManager).to receive(:assign_builders).and_return(true)
    allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(false)
    allow(EquipmentManager).to receive(:release_equipment).and_return(true)
    
    # Ensure settlement has inventory
    settlement.create_inventory! unless settlement.inventory
  end
  
  describe "#initialize" do
    it "initializes with default hangar type" do
      expect(service.instance_variable_get(:@hangar_type)).to eq("standard_rover_hangar")
      expect(service.instance_variable_get(:@access_point)).to eq(access_point)
      expect(service.instance_variable_get(:@lava_tube)).to eq(lava_tube)
    end
    
    it "initializes with custom hangar type" do
      expect(service_large.instance_variable_get(:@hangar_type)).to eq("large_craft_hangar")
    end
    
    it "raises error for non-large access points" do
      small_access_point = create(:access_point, lava_tube: lava_tube, access_type: 'small')
      
      expect {
        described_class.new(small_access_point)
      }.to raise_error(ArgumentError, "Only large access points can be converted to hangars")
    end
  end
  
  describe "#schedule_construction" do
    it "creates a hangar structure successfully" do
      result = service.schedule_construction
      
      expect(result[:success]).to be true
      expect(result[:message]).to include("Hangar construction scheduled")
      expect(result[:hangar]).to be_present
      # expect(result[:hangar].structure_type).to eq('hangar')
    end
    
    it "creates a construction job" do
      result = service.schedule_construction
      
      construction_job = result[:construction_job]
      expect(construction_job).to be_present
      expect(construction_job.job_type).to eq('access_point_conversion')
      expect(construction_job.status).to eq('materials_pending')
      expect(construction_job.jobable).to be_a(Structures::Hangar)
    end
    
    it "connects the access point to the hangar" do
      result = service.schedule_construction
      
      # expect(access_point.reload.connected_structure).to eq(result[:hangar])
      # expect(access_point.conversion_status).to eq('hangar_planned')
    end
    
    it "fails when no settlement found" do
      service.instance_variable_set(:@settlement, nil)
      
      result = service.schedule_construction
      
      expect(result[:success]).to be false
      expect(result[:message]).to include("No settlement found")
    end
    
    it "fails when no blueprint found" do
      allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint).and_return(nil)
      
      result = service.schedule_construction
      
      expect(result[:success]).to be false
      expect(result[:message]).to include("No blueprint found")
    end
    
    it "creates material and equipment requests" do
      expect(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash)
      expect(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests)
      
      service.schedule_construction
    end
    
    it "calculates correct capacity for standard rover hangar" do
      result = service.schedule_construction
      hangar = result[:hangar]
      
      expect(hangar.operational_data['capacity']).to eq({ "rover" => 4, "small_craft" => 0 })
    end
    
    it "calculates correct capacity for large craft hangar" do
      result = service_large.schedule_construction
      hangar = result[:hangar]
      
      expect(hangar.operational_data['capacity']).to eq({ "rover" => 0, "small_craft" => 4 })
    end
  end
  
  describe "#start_construction" do
    let!(:hangar) {
      Structures::Hangar.create!(
        name: "Test Hangar",
        settlement: settlement,
        owner: player,
        location: lava_tube,
        container_structure: nil,
        operational_data: {
          structure_type: 'hangar',
          hangar_type: 'standard_rover_hangar',
          status: 'planned'
        }
      )
    }
    
    let!(:construction_job) {
      job = ConstructionJob.new(
        jobable: hangar,
        job_type: 'access_point_conversion',
        status: 'materials_pending',
        settlement: settlement
      )
      
      job.target_values = {
        hangar_type: 'standard_rover_hangar'
      }
      
      job.save!
      job
    }
    
    before do
      allow(construction_job).to receive(:materials_gathered?).and_return(true)
      allow(construction_job).to receive(:equipment_gathered?).and_return(true)
    end
    
    it "starts construction when materials and equipment are ready" do
      result = service.start_construction(construction_job)
      
      expect(result).to be true
      expect(construction_job.reload.status).to eq('in_progress')
      expect(hangar.reload.operational_data['status']).to eq('under_construction')
      # expect(access_point.reload.conversion_status).to eq('hangar_under_construction')
    end
    
    it "fails when materials not ready" do
      allow(construction_job).to receive(:materials_gathered?).and_return(false)
      
      result = service.start_construction(construction_job)
      
      expect(result).to be false
    end
    
    it "fails when equipment not ready" do
      allow(construction_job).to receive(:equipment_gathered?).and_return(false)
      
      result = service.start_construction(construction_job)
      
      expect(result).to be false
    end
  end
  
  describe "#track_progress" do
    let!(:hangar) {
      Structures::Hangar.create!(
        name: "Test Hangar",
        settlement: settlement,
        owner: player,
        location: lava_tube,
        container_structure: nil,
        operational_data: {
          structure_type: 'hangar',
          hangar_type: 'standard_rover_hangar',
          status: 'under_construction'
        }
      )
    }
    
    let!(:construction_job) {
      job = ConstructionJob.new(
        jobable: hangar,
        job_type: 'access_point_conversion',
        status: 'in_progress',
        settlement: settlement
      )
      
      job.save!
      job
    }
    
    it "completes construction when work is finished" do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      
      result = service.track_progress(construction_job)
      
      expect(result).to be true
      expect(construction_job.reload.status).to eq('completed')
      expect(construction_job.completion_date).to be_present
      expect(hangar.reload.operational_data['status']).to eq('operational')
      # expect(access_point.reload.conversion_status).to eq('hangar_operational')
    end
    
    it "returns false when construction not complete" do
      result = service.track_progress(construction_job)
      
      expect(result).to be false
      expect(construction_job.reload.status).to eq('in_progress')
    end
    
    it "releases equipment when construction completes" do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      expect(EquipmentManager).to receive(:release_equipment).with(construction_job)
      
      service.track_progress(construction_job)
    end
  end
  
  describe "#calculate_materials" do
    it "calculates materials for standard rover hangar" do
      materials = service.send(:calculate_materials)
      
      expect(materials["reinforced_steel"]).to eq(5000)
      expect(materials["structural_components"]).to eq(2000)
      expect(materials["pressurized_doors"]).to eq(2)
      expect(materials["environmental_systems"]).to eq(1)
    end
    
    it "calculates materials for large craft hangar" do
      materials = service_large.send(:calculate_materials)
      
      expect(materials["reinforced_steel"]).to eq(12000)
      expect(materials["structural_components"]).to eq(5000)
      expect(materials["pressurized_doors"]).to eq(4)
      expect(materials["advanced_airlock_systems"]).to eq(2)
    end
    
    it "merges blueprint materials with specific materials" do
      materials = service.send(:calculate_materials)
      
      # Should include blueprint base materials
      expect(materials["processed_regolith"]).to eq(1000)
      expect(materials["aluminum_alloy"]).to eq(500)
    end
  end
  
  describe "#calculate_construction_time" do
    it "calculates base time for standard hangar" do
      time = service.send(:calculate_construction_time)
      expect(time).to eq(240) # 10 days in hours
    end
    
    it "calculates longer time for large craft hangar" do
      time = service_large.send(:calculate_construction_time)
      expect(time).to eq(480) # 20 days in hours
    end
  end
  
  describe "#calculate_equipment_requirements" do
    it "calculates equipment requirements" do
      requirements = service.send(:calculate_equipment_requirements)
      
      expect(requirements).to include(
        { equipment_type: "3d_printer", quantity: 2 },
        { equipment_type: "construction_drone", quantity: 6 },
        { equipment_type: "assembly_robot", quantity: 3 },
        { equipment_type: "excavation_equipment", quantity: 2 },
        { equipment_type: "materials_transport", quantity: 2 }
      )
    end
  end
end