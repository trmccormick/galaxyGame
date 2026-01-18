require 'rails_helper'

RSpec.describe Manufacturing::Construction::DomeService, type: :service do
  let!(:currency) { create(:financial_currency) }
  let!(:mars) { create(:terrestrial_planet, :mars) }
  
  let!(:crater_location) { 
    create(:celestial_location, 
      name: "Jezero Crater", 
      coordinates: "18.38°N 77.58°E", 
      celestial_body: mars
    )
  }
  
  let!(:player) { create(:player) }
  
  let!(:settlement) { 
    create(:settlement, 
      :independent,
      name: "Jezero Base", 
      location: crater_location,
      owner: player,
      settlement_type: :base,
      current_population: 10
    )
  }
  
  let!(:crater_dome) { 
    create(:crater_dome, 
      name: "Jezero Dome", 
      diameter: 500,
      depth: 50,
      location: crater_location,
      settlement: settlement,
      status: 'planned'
    )
  }
  
  let(:service) { described_class.new(player, crater_dome) }
  let(:service_with_panel) { described_class.new(player, crater_dome, nil, "solar_cover_panel") }

  before do
    # Ensure inventory exists
    settlement.create_inventory! unless settlement.inventory
    
    # Add materials
    create(:item, 
      inventory: settlement.inventory, 
      name: "Steel", 
      amount: 1000,
      material_type: 0,
      owner: settlement
    )
    
    # Mock external services
    allow(Manufacturing::Construction::DomeCalculator).to receive(:calculate_materials).and_return({
      "processed_regolith" => 1000,
      "metal_extract" => 500,
      "silicate_extract" => 300,
      "structural_supports" => 50,
      "dome_anchors" => 100,
      "pressure_seals" => 200
    })
    
    allow(Manufacturing::Construction::DomeCalculator).to receive(:calculate_construction_cost).and_return(50000)
    allow(Manufacturing::Construction::DomeCalculator).to receive(:estimate_construction_time).and_return(480)
    
    allow(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash).and_return([double("MaterialRequest")])
    allow(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests).and_return([double("EquipmentRequest")])
    allow(Manufacturing::Construction::ConstructionManager).to receive(:assign_builders).and_return(true)
    allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(false)
    allow(TransactionService).to receive(:process_transaction).and_return(true)
  end

  describe "#initialize" do
    it "initializes with default panel type" do
      expect(service.instance_variable_get(:@panel_type)).to eq("basic_transparent_crater_tube_cover_array")
      expect(service.instance_variable_get(:@entity)).to eq(player)
      expect(service.instance_variable_get(:@crater_dome)).to eq(crater_dome)
      expect(service.instance_variable_get(:@settlement)).to eq(settlement)
    end
    
    it "initializes with custom panel type" do
      expect(service_with_panel.instance_variable_get(:@panel_type)).to eq("solar_cover_panel")
    end
    
    it "defaults service provider to entity" do
      expect(service.instance_variable_get(:@service_provider)).to eq(player)
    end
  end

  describe "#schedule_construction" do
    it "creates a construction job successfully" do
      result = service.schedule_construction
      
      expect(result[:success]).to be true
      expect(result[:message]).to include("Construction job created")
      
      construction_job = result[:construction_job]
      expect(construction_job).to be_present
      expect(construction_job.jobable).to eq(crater_dome)
      expect(construction_job.job_type).to eq('crater_dome_construction')
      expect(construction_job.status).to eq('materials_pending')
      expect(construction_job.target_values['panel_type']).to eq("basic_transparent_crater_tube_cover_array")
    end
    
    it "fails when no settlement found" do
      service.instance_variable_set(:@settlement, nil)
      
      result = service.schedule_construction
      
      expect(result[:success]).to be false
      expect(result[:message]).to include("No valid settlement found")
    end
    
    it "creates material and equipment requests for player construction" do
      expect(Manufacturing::MaterialRequest).to receive(:create_material_requests_from_hash)
      expect(Manufacturing::EquipmentRequest).to receive(:create_equipment_requests)
      
      service.schedule_construction
    end
    
    context "when entity is different from service provider" do
      let(:service_provider) { create(:organization, organization_type: 'corporation') }
      let(:consortium_provider) { create(:organization, organization_type: 'consortium') }
      let(:contracted_service) { described_class.new(player, crater_dome, service_provider) }
      
      before do
        # Ensure accounts exist
        create(:financial_account, accountable: service_provider, balance: 100_000) unless service_provider.account
        create(:financial_account, accountable: settlement, balance: 100_000) unless settlement.account
      end
      
      it "processes payment for contracted construction" do
        expect(TransactionService).to receive(:process_transaction).with(
          buyer: settlement,
          seller: service_provider,
          amount: 50000,
          currency: currency
        )
        result = described_class.new(player, crater_dome, service_provider, nil, currency).schedule_construction
        expect(result[:success]).to be true
      end
      
      it "does not create material requests for contracted construction" do
        expect(Manufacturing::MaterialRequest).not_to receive(:create_material_requests_from_hash)
        
        result = contracted_service.schedule_construction
        
        expect(result[:material_requests]).to eq([])
      end
      
      it "marks materials and equipment as provided by contractor" do
        result = contracted_service.schedule_construction
        
        construction_job = result[:construction_job]
        expect(construction_job.target_values['materials_status']).to eq('provided_by_contractor')
        expect(construction_job.target_values['equipment_status']).to eq('provided_by_contractor')
      end
      
      it "handles payment failure gracefully" do
        allow(TransactionService).to receive(:process_transaction).and_raise(StandardError.new("Insufficient funds"))
        
        result = contracted_service.schedule_construction
        
        expect(result[:success]).to be false
        expect(result[:message]).to include("Payment failed")
      end
    end
  end

  describe "#start_construction" do
    let!(:construction_job) { 
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: 'crater_dome_construction',
        status: 'materials_pending',
        settlement: settlement
      )
      
      job.target_values = { 
        panel_type: 'basic_transparent_crater_tube_cover_array',
        owner_id: player.id,
        owner_type: player.class.name,
        service_provider_id: player.id,
        service_provider_type: player.class.name
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
      expect(crater_dome.reload.status).to eq('under_construction')
      expect(crater_dome.estimated_completion).to be_present
    end
    
    it "fails when materials not ready for player construction" do
      allow(construction_job).to receive(:materials_gathered?).and_return(false)
      
      result = service.start_construction(construction_job)
      
      expect(result).to be false
    end
    
    it "bypasses checks for contracted construction" do
      construction_job.target_values['service_provider_id'] = 999
      construction_job.save!
      
      allow(construction_job).to receive(:materials_gathered?).and_return(false)
      allow(construction_job).to receive(:equipment_gathered?).and_return(false)
      
      result = service.start_construction(construction_job)
      
      expect(result).to be true
    end
  end

  describe "#track_progress" do
    let!(:construction_job) { 
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: 'crater_dome_construction',
        status: 'in_progress',
        settlement: settlement
      )
      
      job.target_values = { 
        panel_type: 'basic_transparent_crater_tube_cover_array',
        layer_type: 'primary'
      }
      
      job.save!
      job
    }
    
    it "completes construction when work is finished" do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      
      result = service.track_progress(construction_job)
      
      expect(result).to be true
      expect(construction_job.reload.status).to eq('completed')
      expect(construction_job.completion_date).to be_present
      expect(crater_dome.reload.status).to eq('primary_layer_complete')
    end
    
    it "returns false when construction not complete" do
      result = service.track_progress(construction_job)
      
      expect(result).to be false
      expect(construction_job.reload.status).to eq('in_progress')
    end
    
    it "sets correct status for different layer types" do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      
      construction_job.target_values['layer_type'] = 'both'
      construction_job.save!
      
      service.track_progress(construction_job)
      
      expect(crater_dome.reload.status).to eq('fully_operational')
    end
    
    it "releases equipment when construction completes" do
      allow(Manufacturing::Construction::ConstructionManager).to receive(:complete?).and_return(true)
      expect(Manufacturing::Construction::EquipmentManager).to receive(:release_equipment).with(construction_job)
      
      service.track_progress(construction_job)
    end
  end

  describe "#complete_construction" do
    let!(:construction_job) { 
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: 'crater_dome_construction',
        status: 'in_progress',
        settlement: settlement
      )
      
      job.target_values = { 
        layer_type: 'secondary'
      }
      
      job.save!
      job
    }
    
    it "completes the construction process" do
      result = service.complete_construction(construction_job)
      
      expect(result).to be true
      expect(construction_job.reload.status).to eq('completed')
      expect(crater_dome.reload.status).to eq('secondary_layer_complete')
    end
  end

  describe "private methods" do
    describe "#determine_completion_status" do
      it "returns correct status for primary layer" do
        status = service.send(:determine_completion_status, 'primary')
        expect(status).to eq('primary_layer_complete')
      end
      
      it "returns correct status for secondary layer" do
        status = service.send(:determine_completion_status, 'secondary')
        expect(status).to eq('secondary_layer_complete')
      end
      
      it "returns correct status for both layers" do
        status = service.send(:determine_completion_status, 'both')
        expect(status).to eq('fully_operational')
      end
      
      it "returns operational for unknown layer types" do
        status = service.send(:determine_completion_status, 'unknown')
        expect(status).to eq('operational')
      end
    end
    
    describe "#is_player_construction?" do
      it "returns true when entity and provider are the same" do
        construction_job = ConstructionJob.new
        construction_job.target_values = {
          owner_id: 1,
          owner_type: 'Player',
          service_provider_id: 1,
          service_provider_type: 'Player'
        }
        
        expect(service.send(:is_player_construction?, construction_job)).to be true
      end
      
      it "returns false when entity and provider are different" do
        construction_job = ConstructionJob.new
        construction_job.target_values = {
          owner_id: 1,
          owner_type: 'Player',
          service_provider_id: 2,
          service_provider_type: 'Organization'
        }
        
        expect(service.send(:is_player_construction?, construction_job)).to be false
      end
    end
  end
end