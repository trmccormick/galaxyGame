require 'rails_helper'

RSpec.describe ConstructionJob, type: :model do
  # Basic factories for testing
  let(:mars) { create(:terrestrial_planet, :mars) }
  let(:location) { create(:celestial_location, name: "Test Location", celestial_body: mars) }
  let(:player) { create(:player) }
  let(:settlement) { create(:settlement, name: "Test Settlement", location: location, owner: player) }
  let(:crater_dome) { create(:crater_dome, :with_dimensions, name: "Test Dome", settlement: settlement) }
  
  describe "validations and attributes" do
    it "is valid with required attributes" do
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: :crater_dome_construction,
        status: :scheduled,
        settlement: settlement
      )
      expect(job).to be_valid
    end
    
    it "requires a jobable" do
      job = ConstructionJob.new(job_type: :crater_dome_construction, status: :scheduled, settlement: settlement)
      expect(job).not_to be_valid
      expect(job.errors[:jobable]).to include("must exist")
    end
    
    it "accepts a valid job_type" do
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: :crater_dome_construction,
        status: :scheduled,
        settlement: settlement
      )
      expect(job).to be_valid
      
      job.job_type = :skylight_cover
      expect(job).to be_valid
      
      job.job_type = :access_point_conversion
      expect(job).to be_valid
    end
    
    it "accepts a valid status" do
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: :crater_dome_construction,
        status: :scheduled,
        settlement: settlement
      )
      expect(job).to be_valid
      
      job.status = :materials_pending
      expect(job).to be_valid
      
      job.status = :in_progress
      expect(job).to be_valid
      
      job.status = :completed
      expect(job).to be_valid
    end
    
    it "stores target_values as JSON" do
      job = ConstructionJob.create!(
        jobable: crater_dome,
        job_type: :crater_dome_construction,
        status: :scheduled,
        settlement: settlement,  # Add the settlement to fix the NOT NULL constraint
        target_values: { 
          layer_type: 'primary',
          owner_id: player.id,
          owner_type: player.class.name
        }
      )
      
      # Reload from DB to ensure it was saved properly
      job.reload
      
      expect(job.target_values).to be_a(Hash)
      expect(job.target_values['layer_type']).to eq('primary')
      expect(job.target_values['owner_id']).to eq(player.id)
    end
  end
  
  describe "associations" do
    let!(:job) { 
      create(:construction_job, 
        jobable: crater_dome, 
        job_type: :crater_dome_construction, 
        status: :materials_pending,
        settlement: settlement
      ) 
    }
    
    # Check the MaterialRequest model to find the correct attribute names
    it "has many material_requests" do
      # Create a material request
      # We need to use the correct attribute names - likely material_name instead of material_type
      material_request = job.material_requests.create!(
        # Use an expect/allow pattern to discover the right attribute names
        material_name: "Steel",  # Try material_name instead of material_type
        quantity_requested: 100,
        status: 'pending'
      )
      
      expect(job.material_requests).to include(material_request)
    end
    
    it "has many equipment_requests" do
      # Create an equipment request
      equipment_request = job.equipment_requests.create!(
        equipment_type: "excavator",
        quantity_requested: 2,
        priority: 'normal',  # Changed from 'medium' to 'normal'
        status: 'pending'
      )
      
      expect(job.equipment_requests).to include(equipment_request)
    end
    
    it "belongs to a jobable" do
      expect(job.jobable).to eq(crater_dome)
    end
    
    it "belongs to a settlement" do
      expect(job.settlement).to eq(settlement)
    end
  end
  
  describe "enum functionality" do
    let!(:job) { 
      create(:construction_job, 
        jobable: crater_dome, 
        job_type: :crater_dome_construction, 
        status: :materials_pending,
        settlement: settlement
      ) 
    }
    
    it "correctly stores and retrieves job_type as an enum" do
      # First ensure we have a valid job
      job.update!(job_type: :crater_dome_construction)
      job.reload
      expect(job.job_type).to eq("crater_dome_construction")
      
      # Test setting an integer directly
      # Note: In Rails 6+, update_column bypasses callbacks that may be normalizing the enum
      # So let's use update! instead
      job.update!(job_type: 1)  # This should map to skylight_cover
      job.reload
      expect(job.job_type).to eq("skylight_cover")
      
      # Test setting via symbol
      job.update!(job_type: :habitat_expansion)
      job.reload
      expect(job.job_type).to eq("habitat_expansion")
      
      # Test setting via string
      job.update!(job_type: "access_point_conversion")
      job.reload
      expect(job.job_type).to eq("access_point_conversion")
    end
    
    it "correctly stores and retrieves status as an enum" do
      # First ensure we have a valid status
      job.update!(status: :materials_pending)
      job.reload
      expect(job.status).to eq("materials_pending")
      
      # Test setting an integer directly
      job.update!(status: 4)  # This should map to in_progress
      job.reload
      expect(job.status).to eq("in_progress")
      
      # Test setting via symbol
      job.update!(status: :completed)
      job.reload
      expect(job.status).to eq("completed")
      
      # Test setting via string
      job.update!(status: "failed")
      job.reload
      expect(job.status).to eq("failed")
    end
  end
  
  describe "convenience methods" do
    let!(:job) { 
      create(:construction_job, 
        jobable: crater_dome, 
        job_type: :crater_dome_construction, 
        status: :materials_pending,
        settlement: settlement
      ) 
    }
    
    describe "#materials_gathered?" do
      it "returns true when all material requests are fulfilled" do
        request1 = job.material_requests.create!(
          material_name: "Steel",
          quantity_requested: 100,
          status: "fulfilled_by_player"
        )

        request2 = job.material_requests.create!(
          material_name: "Glass",
          quantity_requested: 50,
          status: "fulfilled_by_player"
        )

        expect(job.materials_gathered?).to be true
      end
      
      it "returns false when some material requests are pending" do
        # Create mixed status material requests with correct attribute names
        job.material_requests.create!(
          material_name: "Steel",  # Try material_name instead of material_type
          quantity_requested: 100,
          status: :fulfilled_by_player
        )
        
        job.material_requests.create!(
          material_name: "Glass",  # Try material_name instead of material_type
          quantity_requested: 50,
          status: 'pending'
        )
        
        expect(job.materials_gathered?).to be false
      end
    end
    
    describe "#equipment_gathered?" do
      # This test should pass since it doesn't create any equipment requests
      it "returns true when no equipment requests exist" do
        expect(job.equipment_requests.count).to eq(0)
        expect(job.equipment_gathered?).to be true
      end
      
      it "returns true when all equipment requests are fulfilled" do
        request = job.equipment_requests.create!(
          equipment_type: "excavator",
          quantity_requested: 2,
          priority: 'normal',  # Changed from 'medium' to 'normal'
          status: :fulfilled   # Now this will work with string enums
        )
        
        expect(job.equipment_gathered?).to be true
      end
      
      it "returns false when some equipment requests are pending" do
        job.equipment_requests.create!(
          equipment_type: "excavator",
          quantity_requested: 2,
          priority: 'normal',  # Changed from 'medium' to 'normal'
          status: 'pending'
        )
        
        expect(job.equipment_gathered?).to be false
      end
    end
    
    describe "#infer_settlement" do
      it "returns the jobable's settlement if available" do
        expect(job.infer_settlement).to eq(settlement)
      end
      
      it "returns the jobable if it is a Settlement" do
        settlement_job = create(:construction_job, jobable: settlement, job_type: :habitat_expansion, settlement: settlement)
        expect(settlement_job.infer_settlement).to eq(settlement)
      end
      
      it "finds a settlement by location if available" do
        # Create a structure with explicit location
        structure = create(:crater_dome, :with_dimensions)
        structure.update!(location: location, settlement: nil)
        
        # Create job with explicit settlement
        structure_job = create(:construction_job, 
          jobable: structure, 
          job_type: :structure_upgrade,
          settlement: settlement
        )
        
        # Debug info - use the correct association
        puts "Structure location: #{structure.location.id}"
        puts "Settlement location: #{settlement.location.id}"
        puts "All settlements at location #{location.id}:"
        Settlement::BaseSettlement.where(location: location).each do |s|
          puts "  - Settlement #{s.id}: #{s.name}"
        end
        
        # Now stub out the settlement association for testing infer_settlement
        allow(structure_job).to receive(:settlement).and_return(nil)
        
        # Test infer_settlement
        found_settlement = structure_job.infer_settlement
        
        # Fix: Compare the essential attributes instead of object equality
        expect(found_settlement.id).to eq(settlement.id)
        expect(found_settlement.name).to eq(settlement.name)
        expect(found_settlement.location).to eq(settlement.location)
      end
    end
  end
  
  # The scopes tests should be fine as long as we fix the settlement_id NOT NULL constraint
  
  # Add this debugging test to see what columns exist:
  it "debug - shows actual database columns" do
    puts "\n=== MaterialRequest columns ==="
    MaterialRequest.columns.each do |col|
      puts "  #{col.name}: #{col.type} (#{col.sql_type})"
    end
    
    puts "\n=== EquipmentRequest columns ==="
    EquipmentRequest.columns.each do |col|
      puts "  #{col.name}: #{col.type} (#{col.sql_type})"
    end
    
    puts "\n=== Settlement columns ==="
    Settlement::BaseSettlement.columns.each do |col|
      puts "  #{col.name}: #{col.type} (#{col.sql_type})"
    end
  end
end