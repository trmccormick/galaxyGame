require 'rails_helper'

RSpec.describe CraterDomeConstructionService, type: :service do
  # Use the terrestrial_planet factory with mars trait
  let!(:mars) { create(:terrestrial_planet, :mars) }
  
  # Use the celestial_location factory 
  let!(:crater_location) { create(:celestial_location, 
    name: "Jezero Crater", 
    coordinates: "18.38°N 77.58°E", 
    celestial_body: mars
  )}
  
  # Create a player
  let!(:player) { create(:player) }
  
  # Create a settlement for the player at the location
  let!(:settlement) { create(:settlement, 
    :independent,
    name: "Jezero Base", 
    location: crater_location,
    owner: player,
    settlement_type: :base,
    current_population: 10
  )}
  
  # Create a crater dome
  let!(:crater_dome) { 
    create(:crater_dome, :with_dimensions, 
      name: "Jezero Dome", 
      dimensions: { diameter: 500, depth: 50 },
      location: crater_location,
      settlement: settlement,
      status: 'planned'
    )
  }
  
  # Initialize the service
  let(:service) { described_class.new(player, crater_dome) }

  # Setup before each test
  before do
    # Ensure inventory exists
    unless settlement.inventory
      settlement.create_inventory!
    end
    
    # Add materials using factory
    create(:item, 
      inventory: settlement.inventory, 
      name: "Steel", 
      amount: 1000,
      material_type: 0,
      owner: settlement
    )
    
    create(:item, 
      inventory: settlement.inventory, 
      name: "Glass", 
      amount: 500,
      material_type: 0,
      owner: settlement
    )
    
    create(:item, 
      inventory: settlement.inventory, 
      name: "Planetary Regolith", 
      amount: 2000,
      material_type: 0,
      owner: settlement
    )
    
    # Fix: Remove all_materials_fulfilled? method from the mock
    class_double("MaterialRequestService", 
      create_material_requests_from_hash: [double("MaterialRequest")]
    ).as_stubbed_const
    
    # Fix: Remove all_equipment_fulfilled? method from the mock
    class_double("EquipmentRequestService", 
      create_equipment_requests: [double("EquipmentRequest")]
    ).as_stubbed_const
    
    # Mock TransactionService
    class_double("TransactionService", 
      process_transaction: true
    ).as_stubbed_const
  end

  describe "#construct" do
    it "creates a construction job successfully" do
      # Explicitly stub the methods we need in the actual service class
      allow_any_instance_of(CraterDomeConstructionService).to receive(:materials_gathered?).and_return(true)
      allow_any_instance_of(CraterDomeConstructionService).to receive(:equipment_gathered?).and_return(true)
      
      result = service.construct
      
      expect(result[:success]).to be true
      expect(result[:message]).to include("Construction job created")
      
      construction_job = result[:construction_job]
      expect(construction_job).to be_present
      expect(construction_job.jobable).to eq(crater_dome)
      expect(construction_job.job_type).to eq('crater_dome_construction')
      expect(construction_job.status).to eq('materials_pending')
    end
    
    context "when entity is different from service provider" do
      let(:service_provider) { create(:organization, organization_type: 'corporation') }
      
      it "processes a payment" do
        # Make sure service provider has an account with sufficient funds
        unless service_provider.account
          create(:account, accountable: service_provider, balance: 100_000)
        end
        
        # Make sure settlement has an account with sufficient funds
        unless settlement.account
          create(:account, accountable: settlement, balance: 100_000)
        end
        
        # Mock the TransactionService more explicitly
        allow(TransactionService).to receive(:process_transaction).with(
          buyer: settlement,
          seller: service_provider,
          amount: anything
        ).and_return(true)
        
        service = described_class.new(player, crater_dome, service_provider)
        
        result = service.construct
        
        # Debug output if the test fails - FIX THE DIG METHOD
        if !result[:success]
          puts "Failure message: #{result[:message]}"
          # CHANGE THIS LINE - don't use dig on ConstructionJob object
          puts "Construction job target_values: #{result[:construction_job]&.target_values}"
        end
        
        # Verify the transaction was processed
        expect(TransactionService).to have_received(:process_transaction)
        expect(result[:success]).to be true
      end
    end
  end

  describe "#start_construction" do
    let!(:construction_job) { 
      # Create job directly to avoid any service issues
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: 'crater_dome_construction',
        status: 'materials_pending',
        settlement: settlement
      )
      
      # Set target values correctly
      job.target_values = { 
        layer_type: 'primary',
        owner_id: player.id,
        owner_type: player.class.name,
        service_provider_id: player.id,
        service_provider_type: player.class.name
      }
      
      job.save!
      job
    }
    
    it "starts the construction process" do
      # Create a new instance of the service for this test
      test_service = described_class.new(player, crater_dome)
      
      # Ensure we've stubbed everything correctly
      allow(test_service).to receive(:is_player_construction?).and_return(true)
      allow(test_service).to receive(:materials_gathered?).and_return(true)
      allow(test_service).to receive(:equipment_gathered?).and_return(true)
      
      # Ensure the construction job is valid
      expect(construction_job.status).to eq('materials_pending')
      
      # Call the method
      result = test_service.start_construction(construction_job)
      
      # Check results
      expect(result).to be true
      expect(construction_job.reload.status).to eq('in_progress')
      expect(crater_dome.reload.status).to eq('under_construction')
    end
  end

  describe "#complete_construction" do
    let!(:construction_job) { 
      # Create an in-progress job
      job = ConstructionJob.new(
        jobable: crater_dome,
        job_type: 'crater_dome_construction',
        status: 'in_progress',  # Must be in_progress
        settlement: settlement
      )
      
      # Set target values correctly
      job.target_values = { 
        layer_type: 'primary',
        owner_id: player.id,
        owner_type: player.class.name,
        service_provider_id: player.id,
        service_provider_type: player.class.name
      }
      
      job.save!
      job
    }
    
    it "completes the construction process" do
      # Force the status to be 'in_progress' in the database
      construction_job.update_column(:status, 'in_progress')
      
      # Update crater dome status to match expected state
      crater_dome.update!(status: 'under_construction')
      
      # Create a new instance of the service for this test
      test_service = described_class.new(player, crater_dome)
      
      # Call the method
      result = test_service.complete_construction(construction_job)
      
      # Debug if test still fails
      puts "Job status before completion: #{construction_job.reload.status}" if result != "Construction complete"
      
      # Check results
      expect(result).to include("Construction complete")
      expect(construction_job.reload.status).to eq('completed')
      expect(crater_dome.reload.status).to eq('primary_layer_complete')
    end
  end
end

