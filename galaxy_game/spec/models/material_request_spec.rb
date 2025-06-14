require 'rails_helper'

RSpec.describe MaterialRequest, type: :model do
  # Basic setup
  let(:player) { create(:player) }
  let(:mars) { create(:terrestrial_planet, :mars) }
  let(:location) { create(:celestial_location, name: "Test Location", celestial_body: mars) }
  let(:settlement) { create(:base_settlement, name: "Test Settlement", location: location, owner: player) }
  let(:crater_dome) { create(:crater_dome, :with_dimensions, name: "Test Dome", settlement: settlement) }
  let(:construction_job) { create(:construction_job, jobable: crater_dome, settlement: settlement) }

  describe "validations" do
    it "is valid with required attributes" do
      material_request = MaterialRequest.new(
        requestable: construction_job,
        material_name: "Steel",
        quantity_requested: 100
      )
      expect(material_request).to be_valid
    end

    it "requires a material_name" do
      material_request = MaterialRequest.new(
        requestable: construction_job,
        quantity_requested: 100
      )
      expect(material_request).not_to be_valid
      expect(material_request.errors[:material_name]).to include("can't be blank")
    end

    it "requires quantity_requested to be present" do
      material_request = MaterialRequest.new(
        requestable: construction_job,
        material_name: "Steel"
      )
      expect(material_request).not_to be_valid
      expect(material_request.errors[:quantity_requested]).to be_present
    end

    it "requires quantity_requested to be greater than 0" do
      material_request = MaterialRequest.new(
        requestable: construction_job,
        material_name: "Steel",
        quantity_requested: 0
      )
      expect(material_request).not_to be_valid
      expect(material_request.errors[:quantity_requested]).to include("must be greater than 0")
    end

    it "requires quantity_requested to be a number" do
      material_request = MaterialRequest.new(
        requestable: construction_job,
        material_name: "Steel",
        quantity_requested: "not_a_number"
      )
      expect(material_request).not_to be_valid
      expect(material_request.errors[:quantity_requested]).to include("is not a number")
    end
  end

  describe "associations" do
    let(:material_request) { create(:material_request, requestable: construction_job) }

    it "belongs to a requestable (polymorphic)" do
      expect(material_request.requestable).to eq(construction_job)
    end

    it "can be associated with different requestable types" do
      # Test with construction job
      job_request = create(:material_request, requestable: construction_job)
      expect(job_request.requestable).to eq(construction_job)
      expect(job_request.requestable_type).to eq("ConstructionJob")

      # You can add more requestable types here as needed
    end
  end

  describe "enums" do
    let(:material_request) { create(:material_request, requestable: construction_job) }

    describe "status enum" do
      it "has correct status values" do
        expect(MaterialRequest.statuses).to eq({
          'pending' => 'pending',
          'partially_fulfilled' => 'partially_fulfilled',
          'fulfilled' => 'fulfilled',
          'canceled' => 'canceled'
        })
      end

      it "defaults to pending status" do
        expect(material_request.status).to eq('pending')
      end

      it "can be set to different statuses" do
        material_request.status = :fulfilled
        material_request.save!
        expect(material_request.reload.status).to eq('fulfilled')
      end

      it "accepts string values for status" do
        material_request.update!(status: 'partially_fulfilled')
        expect(material_request.status).to eq('partially_fulfilled')
      end
    end

    describe "priority enum" do
      it "has correct priority values" do
        expect(MaterialRequest.priorities).to eq({
          'low' => 'low',
          'normal' => 'normal',
          'high' => 'high',
          'critical' => 'critical'
        })
      end

      it "defaults to normal priority" do
        expect(material_request.priority).to eq('normal')
      end

      it "can be set to different priorities" do
        material_request.priority = :high
        material_request.save!
        expect(material_request.reload.priority).to eq('high')
      end

      it "accepts string values for priority" do
        material_request.update!(priority: 'critical')
        expect(material_request.priority).to eq('critical')
      end
    end
  end

  describe "scopes" do
    let!(:pending_request) { create(:material_request, requestable: construction_job, status: :pending) }
    let!(:partial_request) { create(:material_request, requestable: construction_job, status: :partially_fulfilled) }
    let!(:fulfilled_request) { create(:material_request, requestable: construction_job, status: :fulfilled) }
    let!(:canceled_request) { create(:material_request, requestable: construction_job, status: :canceled) }
    let!(:steel_request) { create(:material_request, requestable: construction_job, material_name: "Steel") }
    let!(:glass_request) { create(:material_request, requestable: construction_job, material_name: "Glass") }

    describe ".pending_requests" do
      it "returns pending and partially fulfilled requests" do
        pending_requests = MaterialRequest.pending_requests
        expect(pending_requests).to include(pending_request, partial_request)
        expect(pending_requests).not_to include(fulfilled_request, canceled_request)
      end
    end

    describe ".fulfilled" do
      it "returns only fulfilled requests" do
        fulfilled_requests = MaterialRequest.fulfilled
        expect(fulfilled_requests).to include(fulfilled_request)
        expect(fulfilled_requests).not_to include(pending_request, partial_request, canceled_request)
      end
    end

    describe ".for_material" do
      it "returns requests for a specific material" do
        steel_requests = MaterialRequest.for_material("Steel")
        expect(steel_requests).to include(steel_request)
        expect(steel_requests).not_to include(glass_request)
      end
    end
  end

  describe "delegations" do
    let(:material_request) { create(:material_request, requestable: construction_job) }

    it "delegates settlement to requestable" do
      expect(material_request.settlement).to eq(construction_job.settlement)
    end

    it "handles nil settlement gracefully" do
      # Create a requestable without settlement
      allow(construction_job).to receive(:settlement).and_return(nil)
      expect(material_request.settlement).to be_nil
    end
  end

  describe "instance methods" do
    describe "#quantity_still_needed" do
      it "returns the full quantity when quantity_fulfilled is nil" do
        material_request = create(:material_request, 
          requestable: construction_job,
          quantity_requested: 100,
          quantity_fulfilled: nil
        )
        expect(material_request.quantity_still_needed).to eq(100)
      end

      it "returns the difference when quantity_fulfilled is set" do
        material_request = create(:material_request,
          requestable: construction_job,
          quantity_requested: 100,
          quantity_fulfilled: 30
        )
        expect(material_request.quantity_still_needed).to eq(70)
      end

      it "returns 0 when fully fulfilled" do
        material_request = create(:material_request,
          requestable: construction_job,
          quantity_requested: 100,
          quantity_fulfilled: 100
        )
        expect(material_request.quantity_still_needed).to eq(0)
      end
    end

    describe "#gas_request?" do
      let(:material_request) { create(:material_request, requestable: construction_job) }

      before do
        # Mock the MaterialLookupService
        @lookup_service = instance_double(Lookup::MaterialLookupService)
        allow(Lookup::MaterialLookupService).to receive(:new).and_return(@lookup_service)
      end

      it "returns true when material is a gas" do
        gas_material_data = { "category" => "gas", "name" => "Oxygen" }
        allow(@lookup_service).to receive(:find_material).with(material_request.material_name).and_return(gas_material_data)
        
        expect(material_request.gas_request?).to be true
      end

      it "returns false when material is not a gas" do
        solid_material_data = { "category" => "solid", "name" => "Steel" }
        allow(@lookup_service).to receive(:find_material).with(material_request.material_name).and_return(solid_material_data)
        
        expect(material_request.gas_request?).to be false
      end

      it "returns false when material data is not found" do
        allow(@lookup_service).to receive(:find_material).with(material_request.material_name).and_return(nil)
        
        expect(material_request.gas_request?).to be false
      end

      it "returns false when material data has no category" do
        incomplete_material_data = { "name" => "Unknown Material" }
        allow(@lookup_service).to receive(:find_material).with(material_request.material_name).and_return(incomplete_material_data)
        
        expect(material_request.gas_request?).to be false
      end
    end
  end

  describe "factory" do
    it "creates a valid material request with factory" do
      material_request = create(:material_request, requestable: construction_job)
      expect(material_request).to be_valid
      expect(material_request.requestable).to eq(construction_job)
    end
  end
end