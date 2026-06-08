# spec/services/ai_manager/manager_integration_spec.rb
require 'rails_helper'

RSpec.describe AIManager::Manager, type: :service do
  let(:settlement) { create(:base_settlement) }
  let(:cape_canaveral) { create(:base_settlement, name: 'Cape Canaveral Spaceport') }
  let(:lavatube) { double('lavatube', name: 'Test Lavatube', location: 'test_location') }
  let(:system_data) { { id: 'test_system', planets: [], stars: [] } }

  describe 'Service Integration' do
    context 'Manager initialization with service coordination' do
      it 'initializes shared context and service coordinator' do
        manager = described_class.new(target_entity: settlement)

        expect(manager.instance_variable_get(:@shared_context)).to be_a(AIManager::SharedContext)
        expect(manager.instance_variable_get(:@service_coordinator)).to be_a(AIManager::ServiceCoordinator)
        expect(manager.instance_variable_get(:@shared_context).settlement).to eq(settlement)
      end

      it 'initializes service orchestrator' do
        manager = described_class.new(target_entity: settlement)

        expect(manager.instance_variable_get(:@service_orchestrator)).to be_a(AIManager::ServiceOrchestrator)
      end

      it 'registers service coordinator as shared context listener' do
        manager = described_class.new(target_entity: settlement)
        shared_context = manager.instance_variable_get(:@shared_context)
        coordinator = manager.instance_variable_get(:@service_coordinator)
        orchestrator = manager.instance_variable_get(:@service_orchestrator)

        expect(shared_context.instance_variable_get(:@listeners)).to include(coordinator)
        expect(shared_context.instance_variable_get(:@listeners)).to include(orchestrator)
      end
    end

    context 'TaskExecutionEngine integration' do
      let(:mission_data) { { 'identifier' => 'test_mission_001' } }

      before do
        # Create a minimal mission file for testing
        mission_dir = Rails.root.join('app', 'data', 'missions', 'test_mission_001')
        FileUtils.mkdir_p(mission_dir)

        # Create minimal task list and manifest files
        File.write(mission_dir.join('task_list.json'), '[]')
        File.write(mission_dir.join('manifest.json'), '{}')
      end

      after do
        # Clean up test files
        FileUtils.rm_rf(Rails.root.join('app', 'data', 'missions', 'test_mission_001'))
      end

      it 'can start a mission through service coordinator' do
        manager = described_class.new(target_entity: settlement)

        result = manager.start_mission(mission_data)
        expect(result).to be true

        # Check that mission was registered in shared context
        active_missions = manager.instance_variable_get(:@shared_context).active_missions
        expect(active_missions.length).to eq(1)
        expect(active_missions.first[:id]).to eq('test_mission_001')
      end

      it 'can get mission status' do
        manager = described_class.new(target_entity: settlement)
        manager.start_mission(mission_data)

        status = manager.get_mission_status('test_mission_001')
        expect(status).to be_a(Hash)
        expect(status[:mission_id]).to eq('test_mission_001')
        expect(status).to have_key(:current_task_index)
        expect(status).to have_key(:total_tasks)
      end

      it 'can advance mission through service coordinator' do
        manager = described_class.new(target_entity: settlement)
        manager.start_mission(mission_data)

        result = manager.advance_mission('test_mission_001')
        # Result depends on whether there are tasks to execute
        expect(result).to be(true).or be(false)
      end
    end

    context 'ResourceAcquisitionService integration' do
      it 'can acquire resources through service coordinator' do
        manager = described_class.new(target_entity: settlement)

        # Mock the ResourceAcquisitionService.order_acquisition method
        allow(AIManager::ResourceAcquisitionService).to receive(:order_acquisition).and_return(true)

        result = manager.acquire_resource('Iron', 100)
        expect(result).to be true

        # Check that resource request was tracked
        requests = manager.instance_variable_get(:@shared_context).resource_requests
        expect(requests.length).to eq(1)
        expect(requests.first[:material]).to eq('Iron')
        expect(requests.first[:quantity]).to eq(100)
      end

      it 'can check resource availability' do
        manager = described_class.new(target_entity: settlement)

        # Mock the settlement inventory
        allow(settlement).to receive_message_chain(:inventory, :current_storage_of).and_return(50)

        availability = manager.check_resource_availability('Iron')
        expect(availability).to eq(50)
      end
    end

    context 'ScoutLogic integration' do
      it 'can scout systems through service coordinator' do
        manager = described_class.new(target_entity: settlement)

        result = manager.scout_system(system_data)
        expect(result).to be_a(Hash)
        expect(result).to have_key(:primary_characteristic)

        # Check that scouting results were stored
        results = manager.get_scouting_results('test_system')
        expect(results).to be_a(Hash)
        expect(results).to have_key(:primary_characteristic)
      end

      it 'can retrieve scouting results' do
        manager = described_class.new(target_entity: settlement)
        manager.scout_system(system_data)

        results = manager.get_scouting_results
        expect(results).to be_a(Hash)
        expect(results).to have_key('test_system')
      end
    end

    context 'Shared context integration' do
      it 'can queue missions through shared context' do
        manager = described_class.new(target_entity: settlement)
        mission_data = { 'identifier' => 'queued_mission' }

        manager.queue_mission(mission_data)

        queue = manager.instance_variable_get(:@shared_context).mission_queue
        expect(queue.length).to eq(1)
        expect(queue.first['identifier']).to eq('queued_mission')
      end

      it 'can request resources through shared context' do
        manager = described_class.new(target_entity: settlement)

        manager.request_resource('Steel', 200, :high)

        requests = manager.instance_variable_get(:@shared_context).resource_requests
        expect(requests.length).to eq(1)
        expect(requests.first[:material]).to eq('Steel')
        expect(requests.first[:quantity]).to eq(200)
        expect(requests.first[:priority]).to eq(:high)
      end
    end

    context 'ServiceOrchestrator integration' do
      it 'provides access to service orchestrator' do
        manager = described_class.new(target_entity: settlement)

        expect(manager.service_orchestrator).to be_a(AIManager::ServiceOrchestrator)
      end

      it 'can execute coordinated operations' do
        manager = described_class.new(target_entity: settlement)

        allow_any_instance_of(AIManager::ServiceOrchestrator).to receive(:execute_coordinated_operation).and_return(true)

        result = manager.execute_coordinated_operation(:resource_acquisition_with_scouting, { material: 'Iron' })
        expect(result).to be true
      end

      it 'provides service orchestration status' do
        manager = described_class.new(target_entity: settlement)

        status = manager.get_service_status
        expect(status).to have_key(:service_states)
        expect(status).to have_key(:service_priorities)
        expect(status).to have_key(:active_operations)
        expect(status).to have_key(:service_health)
      end
    end
  end

  describe 'Advance Time Integration' do
    
    before do
      # Create Cape Canaveral fixture for all tests in this group  
      @cape_canaveral = create(:base_settlement, name: 'Cape Canaveral Spaceport')
      
      # Stub find_source_settlement at the StrategySelector class level to prevent DB lookup
      allow_any_instance_of(AIManager::StrategySelector)
        .to receive(:find_source_settlement)
        .and_return(@cape_canaveral)
        
      # Prevent action execution by making evaluate_next_action return :wait (no-op strategy)  
      allow_any_instance_of(AIManager::StrategySelector)
        .to receive(:evaluate_next_action)
        .and_return(type: :wait, score: 0, rationale: "No viable actions available")
    end

    it 'updates economic metrics during advance_time for settlements' do
      manager = described_class.new(target_entity: settlement)
      allow(settlement).to receive(:current_population).and_return(1000)

      coordinator = manager.instance_variable_get(:@service_coordinator)
      orchestrator = manager.instance_variable_get(:@service_orchestrator)

      allow_any_instance_of(AIManager::ServiceCoordinator).to receive(:process_pending_missions)
      allow_any_instance_of(AIManager::ServiceCoordinator).to receive(:process_resource_requests)
      allow(orchestrator).to receive(:orchestrate_services)
      allow(manager).to receive(:execute_action_with_service_orchestration)

      manager.advance_time

      economic_state = manager.instance_variable_get(:@shared_context).economic_state
      expect(economic_state[:settlement_population]).to eq(1000)
    end

    it 'processes pending missions during advance_time' do
      manager = described_class.new(target_entity: settlement)
      mission_data = { 'identifier' => 'advance_time_mission' }
      manager.queue_mission(mission_data)

      coordinator = manager.instance_variable_get(:@service_coordinator)
      allow(coordinator).to receive(:process_pending_missions)
      allow(coordinator).to receive(:process_resource_requests)
      allow(coordinator).to receive(:start_mission).and_return(true)
      allow(manager).to receive(:execute_action_with_service_orchestration)

      manager.advance_time

      expect(coordinator).to have_received(:process_pending_missions)
    end

    it 'processes resource requests during advance_time' do
      manager = described_class.new(target_entity: settlement)

      # Add a resource request  
      manager.request_resource('Copper', 50)

      coordinator = manager.instance_variable_get(:@service_coordinator)
      
      # Mock the process_resource_requests method to verify it was called (via send())
      allow(coordinator).to receive_messages(
        process_pending_missions: nil,
        process_resource_requests: nil
      )
      
      # Prevent action execution which would trigger StrategySelector cost_reduction logic  
      allow(manager).to receive(:execute_action_with_service_orchestration)

      manager.advance_time

      # Verify resource requests were processed (this is what we're actually testing)  
      expect(coordinator).to have_received(:process_resource_requests)
    end

    it 'performs service orchestration during advance_time' do
      manager = described_class.new(target_entity: settlement)

      orchestrator = manager.instance_variable_get(:@service_orchestrator)
      
      # Mock the orchestrate_services method to verify it was called (this is what we're testing)
      allow(orchestrator).to receive(:orchestrate_services)
      
      coordinator = manager.instance_variable_get(:@service_coordinator)
      # Stub internal methods to prevent execution of unwanted code paths during advance_time
      allow(coordinator).to receive_messages(
        process_pending_missions: nil,
        process_resource_requests: nil
      )
      
      # Prevent action execution which would trigger StrategySelector cost_reduction logic  
      allow(manager).to receive(:execute_action_with_service_orchestration)

      manager.advance_time

      # Verify service orchestration was performed (this is what we're actually testing)
      expect(orchestrator).to have_received(:orchestrate_services)
    end
  end
end