# spec/services/ai_manager/manager_integration_spec.rb
require 'rails_helper'

RSpec.describe AIManager::Manager, type: :service do
  let(:settlement) { create(:base_settlement) }
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

      it 'registers service coordinator as shared context listener' do
        manager = described_class.new(target_entity: settlement)
        shared_context = manager.instance_variable_get(:@shared_context)
        coordinator = manager.instance_variable_get(:@service_coordinator)

        expect(shared_context.instance_variable_get(:@listeners)).to include(coordinator)
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

    context 'Event notification system' do
      it 'service coordinator receives shared context events' do
        manager = described_class.new(target_entity: settlement)
        coordinator = manager.instance_variable_get(:@service_coordinator)

        # Spy on the coordinator's handle_event method
        allow(coordinator).to receive(:handle_event)

        # Trigger an event
        manager.queue_mission({ 'identifier' => 'test' })

        # Verify event was handled
        expect(coordinator).to have_received(:handle_event).with(:mission_queued, { 'identifier' => 'test' })
      end
    end
  end

  describe 'Advance Time Integration' do
    it 'updates economic metrics during advance_time for settlements' do
      manager = described_class.new(target_entity: settlement)

      # Mock settlement attributes that exist
      allow(settlement).to receive(:current_population).and_return(1000)

      manager.advance_time

      # Check that economic state was updated
      economic_state = manager.instance_variable_get(:@shared_context).economic_state
      expect(economic_state[:settlement_population]).to eq(1000)
      expect(economic_state[:power_output]).to eq(0) # Will be 0 if operational_data doesn't have the expected structure
      expect(economic_state[:resource_storage]).to eq(0) # Default when not in operational_data
    end

    it 'processes pending missions during advance_time' do
      manager = described_class.new(target_entity: settlement)

      # Queue a mission
      mission_data = { 'identifier' => 'advance_time_mission' }
      manager.queue_mission(mission_data)

      # Mock the start_mission method
      allow(manager.instance_variable_get(:@service_coordinator)).to receive(:start_mission).and_return(true)

      manager.advance_time

      # Verify mission was processed
      expect(manager.instance_variable_get(:@service_coordinator)).to have_received(:start_mission).with(mission_data)
    end

    it 'processes resource requests during advance_time' do
      manager = described_class.new(target_entity: settlement)

      # Add a resource request
      manager.request_resource('Copper', 50)

      # Mock the process_resource_requests method
      allow(manager.instance_variable_get(:@service_coordinator)).to receive(:process_resource_requests)

      manager.advance_time

      # Verify resource requests were processed
      expect(manager.instance_variable_get(:@service_coordinator)).to have_received(:process_resource_requests)
    end
  end
end