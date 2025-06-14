require 'rails_helper'

RSpec.describe EquipmentRequest, type: :model do
  # Basic setup
  let(:player) { create(:player) }
  let(:mars) { create(:terrestrial_planet, :mars) }
  let(:location) { create(:celestial_location, name: "Test Location", celestial_body: mars) }
  let(:settlement) { create(:base_settlement, name: "Test Settlement", location: location, owner: player) }
  let(:crater_dome) { create(:crater_dome, :with_dimensions, name: "Test Dome", settlement: settlement) }
  let(:construction_job) { create(:construction_job, jobable: crater_dome, settlement: settlement) }

  describe "validations" do
    it "is valid with required attributes" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        equipment_type: "excavator",
        quantity_requested: 2
      )
      expect(equipment_request).to be_valid
    end

    it "requires an equipment_type" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        quantity_requested: 2
      )
      expect(equipment_request).not_to be_valid
      expect(equipment_request.errors[:equipment_type]).to include("can't be blank")
    end

    it "requires quantity_requested to be present" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        equipment_type: "excavator"
      )
      expect(equipment_request).not_to be_valid
      expect(equipment_request.errors[:quantity_requested]).to be_present
    end

    it "requires quantity_requested to be greater than 0" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        equipment_type: "excavator",
        quantity_requested: 0
      )
      expect(equipment_request).not_to be_valid
      expect(equipment_request.errors[:quantity_requested]).to include("must be greater than 0")
    end

    it "requires quantity_requested to be a number" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        equipment_type: "excavator",
        quantity_requested: "not_a_number"
      )
      expect(equipment_request).not_to be_valid
      expect(equipment_request.errors[:quantity_requested]).to include("is not a number")
    end

    it "allows negative quantity_requested to be invalid" do
      equipment_request = EquipmentRequest.new(
        requestable: construction_job,
        equipment_type: "excavator",
        quantity_requested: -5
      )
      expect(equipment_request).not_to be_valid
      expect(equipment_request.errors[:quantity_requested]).to include("must be greater than 0")
    end
  end

  describe "associations" do
    let(:equipment_request) { create(:equipment_request, requestable: construction_job) }

    it "belongs to a requestable (polymorphic)" do
      expect(equipment_request.requestable).to eq(construction_job)
    end

    it "can be associated with different requestable types" do
      # Test with construction job
      job_request = create(:equipment_request, requestable: construction_job)
      expect(job_request.requestable).to eq(construction_job)
      expect(job_request.requestable_type).to eq("ConstructionJob")

      # You can add more requestable types here as needed
    end
  end

  describe "enums" do
    let(:equipment_request) { create(:equipment_request, requestable: construction_job) }

    describe "status enum" do
      it "has correct status values" do
        expect(EquipmentRequest.statuses).to eq({
          'pending' => 'pending',
          'partially_fulfilled' => 'partially_fulfilled',
          'fulfilled' => 'fulfilled',
          'canceled' => 'canceled'
        })
      end

      it "defaults to pending status" do
        expect(equipment_request.status).to eq('pending')
      end

      it "can be set to different statuses" do
        equipment_request.status = :fulfilled
        equipment_request.save!
        expect(equipment_request.reload.status).to eq('fulfilled')
      end

      it "accepts string values for status" do
        equipment_request.update!(status: 'partially_fulfilled')
        expect(equipment_request.status).to eq('partially_fulfilled')
      end

      it "provides query methods for each status" do
        expect(equipment_request).to be_pending
        expect(equipment_request).not_to be_fulfilled
        
        equipment_request.update!(status: :fulfilled)
        expect(equipment_request).to be_fulfilled
        expect(equipment_request).not_to be_pending
      end
    end

    describe "priority enum" do
      it "has correct priority values" do
        expect(EquipmentRequest.priorities).to eq({
          'low' => 'low',
          'normal' => 'normal',
          'high' => 'high',
          'critical' => 'critical'
        })
      end

      it "defaults to normal priority" do
        expect(equipment_request.priority).to eq('normal')
      end

      it "can be set to different priorities" do
        equipment_request.priority = :high
        equipment_request.save!
        expect(equipment_request.reload.priority).to eq('high')
      end

      it "accepts string values for priority" do
        equipment_request.update!(priority: 'critical')
        expect(equipment_request.priority).to eq('critical')
      end

      it "provides query methods for each priority" do
        expect(equipment_request).to be_normal
        expect(equipment_request).not_to be_high
        
        equipment_request.update!(priority: :critical)
        expect(equipment_request).to be_critical
        expect(equipment_request).not_to be_normal
      end
    end
  end

  describe "scopes" do
    let!(:pending_request) { create(:equipment_request, requestable: construction_job, status: :pending) }
    let!(:partial_request) { create(:equipment_request, requestable: construction_job, status: :partially_fulfilled) }
    let!(:fulfilled_request) { create(:equipment_request, requestable: construction_job, status: :fulfilled) }
    let!(:canceled_request) { create(:equipment_request, requestable: construction_job, status: :canceled) }
    let!(:excavator_request) { create(:equipment_request, requestable: construction_job, equipment_type: "excavator") }
    let!(:crane_request) { create(:equipment_request, requestable: construction_job, equipment_type: "crane") }

    describe ".pending_requests" do
      it "returns pending and partially fulfilled requests" do
        pending_requests = EquipmentRequest.pending_requests
        expect(pending_requests).to include(pending_request, partial_request)
        expect(pending_requests).not_to include(fulfilled_request, canceled_request)
      end
    end

    describe ".fulfilled" do
      it "returns only fulfilled requests" do
        fulfilled_requests = EquipmentRequest.fulfilled
        expect(fulfilled_requests).to include(fulfilled_request)
        expect(fulfilled_requests).not_to include(pending_request, partial_request, canceled_request)
      end
    end

    describe ".for_equipment" do
      it "returns requests for a specific equipment type" do
        excavator_requests = EquipmentRequest.for_equipment("excavator")
        expect(excavator_requests).to include(excavator_request)
        expect(excavator_requests).not_to include(crane_request)
      end

      it "returns empty when no equipment of that type is requested" do
        bulldozer_requests = EquipmentRequest.for_equipment("bulldozer")
        expect(bulldozer_requests).to be_empty
      end
    end
  end

  describe "instance methods" do
    describe "#quantity_still_needed" do
      it "returns the full quantity when quantity_fulfilled is nil" do
        equipment_request = create(:equipment_request, 
          requestable: construction_job,
          quantity_requested: 5,
          quantity_fulfilled: nil
        )
        expect(equipment_request.quantity_still_needed).to eq(5)
      end

      it "returns the difference when quantity_fulfilled is set" do
        equipment_request = create(:equipment_request,
          requestable: construction_job,
          quantity_requested: 10,
          quantity_fulfilled: 3
        )
        expect(equipment_request.quantity_still_needed).to eq(7)
      end

      it "returns 0 when fully fulfilled" do
        equipment_request = create(:equipment_request,
          requestable: construction_job,
          quantity_requested: 2,
          quantity_fulfilled: 2
        )
        expect(equipment_request.quantity_still_needed).to eq(0)
      end

      it "handles quantity_fulfilled being 0" do
        equipment_request = create(:equipment_request,
          requestable: construction_job,
          quantity_requested: 8,
          quantity_fulfilled: 0
        )
        expect(equipment_request.quantity_still_needed).to eq(8)
      end
    end
  end

  describe "factory" do
    it "creates a valid equipment request with factory" do
      equipment_request = create(:equipment_request, requestable: construction_job)
      expect(equipment_request).to be_valid
      expect(equipment_request.requestable).to eq(construction_job)
    end

    it "creates equipment request with specific attributes" do
      equipment_request = create(:equipment_request, 
        requestable: construction_job,
        equipment_type: "crane",
        quantity_requested: 3,
        priority: :high
      )
      expect(equipment_request.equipment_type).to eq("crane")
      expect(equipment_request.quantity_requested).to eq(3)
      expect(equipment_request.priority).to eq("high")
    end
  end

  describe "edge cases and data integrity" do
    it "handles very large quantity requests" do
      equipment_request = create(:equipment_request,
        requestable: construction_job,
        quantity_requested: 999999
      )
      expect(equipment_request).to be_valid
      expect(equipment_request.quantity_still_needed).to eq(999999)
    end

    it "maintains data integrity when updating status" do
      equipment_request = create(:equipment_request, requestable: construction_job)
      original_id = equipment_request.id
      
      equipment_request.update!(status: :fulfilled)
      equipment_request.reload
      
      expect(equipment_request.id).to eq(original_id)
      expect(equipment_request.status).to eq('fulfilled')
    end

    it "handles equipment_type with special characters" do
      equipment_request = create(:equipment_request,
        requestable: construction_job,
        equipment_type: "heavy-duty_excavator_v2.1"
      )
      expect(equipment_request).to be_valid
      expect(equipment_request.equipment_type).to eq("heavy-duty_excavator_v2.1")
    end
  end
end