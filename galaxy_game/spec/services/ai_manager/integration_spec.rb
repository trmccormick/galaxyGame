# spec/services/ai_manager/integration_spec.rb
require 'rails_helper'

RSpec.describe 'AIManager Integration', type: :service do
  let(:settlement) { create(:base_settlement) }
  let(:system_data) { { id: 'test_system', planets: [], stars: [] } }

  describe 'Service-to-Service Communication Framework' do
    let(:shared_context) { AIManager::SharedContext.new(settlement: settlement) }
    let(:coordinator) { AIManager::ServiceCoordinator.new(shared_context) }

    context 'Shared Context Event System' do
      it 'notifies listeners of events' do
        listener = double('listener')
        expect(listener).to receive(:handle_event).with(:test_event, { data: 'value' })

        shared_context.add_listener(listener)
        shared_context.notify_listeners(:test_event, { data: 'value' })
      end

      it 'manages listener registration' do
        listener = double('listener')
        shared_context.add_listener(listener)
        expect(shared_context.instance_variable_get(:@listeners)).to include(listener)

        shared_context.remove_listener(listener)
        expect(shared_context.instance_variable_get(:@listeners)).not_to include(listener)
      end
    end

    context 'Mission Queue Management' do
      it 'queues and dequeues missions' do
        mission_data = { 'identifier' => 'test_mission' }
        shared_context.queue_mission(mission_data)

        expect(shared_context.mission_queue.length).to eq(1)
        dequeued = shared_context.dequeue_mission
        expect(dequeued).to eq(mission_data)
        expect(shared_context.mission_queue).to be_empty
      end

      it 'notifies listeners when missions are queued/dequeued' do
        listener = double('listener')
        expect(listener).to receive(:handle_event).with(:mission_queued, { 'id' => 'test' })
        expect(listener).to receive(:handle_event).with(:mission_dequeued, { 'id' => 'test' })

        shared_context.add_listener(listener)
        shared_context.queue_mission({ 'id' => 'test' })
        shared_context.dequeue_mission
      end
    end

    context 'Resource Request Management' do
      it 'tracks resource requests' do
        request = shared_context.request_resource('Steel', 100, :high)

        expect(shared_context.resource_requests.length).to eq(1)
        expect(request[:material]).to eq('Steel')
        expect(request[:quantity]).to eq(100)
        expect(request[:priority]).to eq(:high)
        expect(request[:status]).to eq(:pending)
      end

      it 'fulfills resource requests' do
        request = shared_context.request_resource('Copper', 50)
        shared_context.fulfill_resource_request(request, :test_source)

        expect(request[:status]).to eq(:fulfilled)
        expect(request[:source]).to eq(:test_source)
        expect(request[:fulfilled_at]).to be_present
      end
    end

    context 'Scouting Results Management' do
      it 'stores and retrieves scouting results' do
        results = { 'target_body' => 'mars', 'terraformable' => true }
        shared_context.store_scouting_result('mars_system', results)

        retrieved = shared_context.get_scouting_result('mars_system')
        expect(retrieved['target_body']).to eq('mars')
        expect(retrieved['terraformable']).to eq(true)
        expect(retrieved[:timestamp]).to be_present
      end
    end

    context 'Active Mission Tracking' do
      it 'registers and unregisters active missions' do
        engine = double('engine')
        shared_context.register_active_mission('mission_001', engine)

        expect(shared_context.active_missions.length).to eq(1)
        mission = shared_context.get_active_mission('mission_001')
        expect(mission[:id]).to eq('mission_001')
        expect(mission[:engine]).to eq(engine)

        shared_context.unregister_active_mission('mission_001')
        expect(shared_context.active_missions).to be_empty
      end
    end

    context 'Economic State Management' do
      it 'updates and retrieves economic state' do
        shared_context.update_economic_state(:population, 1000)
        shared_context.update_economic_state(:power, 50.5)

        expect(shared_context.get_economic_state(:population)).to eq(1000)
        expect(shared_context.get_economic_state(:power)).to eq(50.5)
      end
    end
  end

  describe 'Service Coordinator Functionality' do
    let(:shared_context) { AIManager::SharedContext.new(settlement: settlement) }
    let(:coordinator) { AIManager::ServiceCoordinator.new(shared_context) }

    context 'Mission Coordination' do
      before do
        # Create minimal mission files
        mission_dir = Rails.root.join('app', 'data', 'missions', 'coord_test_mission')
        FileUtils.mkdir_p(mission_dir)
        File.write(mission_dir.join('task_list.json'), '[]')
        File.write(mission_dir.join('manifest.json'), '{}')
      end

      after do
        FileUtils.rm_rf(Rails.root.join('app', 'data', 'missions', 'coord_test_mission'))
      end

      it 'starts missions through TaskExecutionEngine' do
        mission_data = { 'identifier' => 'coord_test_mission' }
        result = coordinator.start_mission(mission_data)

        expect(result).to be true
        expect(coordinator.instance_variable_get(:@task_engine)).to be_a(AIManager::TaskExecutionEngine)
        expect(shared_context.active_missions.length).to eq(1)
      end

      it 'provides mission status information' do
        mission_data = { 'identifier' => 'coord_test_mission' }
        coordinator.start_mission(mission_data)

        status = coordinator.get_mission_status('coord_test_mission')
        expect(status).to be_a(Hash)
        expect(status[:mission_id]).to eq('coord_test_mission')
        expect(status).to have_key(:current_task_index)
        expect(status).to have_key(:total_tasks)
      end
    end

    context 'Resource Coordination' do
      it 'coordinates resource acquisition' do
        allow(AIManager::ResourceAcquisitionService).to receive(:order_acquisition).and_return(true)

        result = coordinator.acquire_resource('Aluminum', 200, settlement)
        expect(result).to be true

        expect(shared_context.resource_requests.length).to eq(1)
        expect(shared_context.resource_requests.first[:material]).to eq('Aluminum')
      end

      it 'checks resource availability' do
        allow(settlement).to receive_message_chain(:inventory, :current_storage_of).and_return(75)

        availability = coordinator.check_resource_availability('Titanium', settlement)
        expect(availability).to eq(75)
      end
    end

    context 'Scouting Coordination' do
      it 'coordinates system scouting' do
        result = coordinator.scout_system(system_data)
        expect(result).to be_a(Hash)
        expect(result).to have_key(:primary_characteristic)

        expect(shared_context.scouting_results).to have_key('test_system')
      end

      it 'retrieves scouting results' do
        coordinator.scout_system(system_data)
        results = coordinator.get_scouting_results('test_system')

        expect(results).to be_a(Hash)
        expect(results).to have_key(:primary_characteristic)
      end
    end

    context 'Batch Processing' do
      it 'processes pending missions' do
        mission_data = { 'identifier' => 'batch_mission' }
        shared_context.queue_mission(mission_data)

        allow(coordinator).to receive(:start_mission).and_return(true)
        coordinator.process_pending_missions

        expect(coordinator).to have_received(:start_mission).with(mission_data)
      end

      it 'processes resource requests' do
        shared_context.request_resource('Gold', 10)
        allow(coordinator).to receive(:acquire_resource).and_return(true)

        # Mock availability check
        allow(coordinator).to receive(:check_resource_availability).and_return(15)

        coordinator.process_resource_requests

        expect(coordinator).to have_received(:acquire_resource).with('Gold', 10, settlement)
      end
    end
  end

  describe 'End-to-End Service Integration' do
    let(:manager) { AIManager::Manager.new(target_entity: settlement) }

    it 'provides unified interface to all AI services' do
      # Test that manager exposes all service methods
      expect(manager).to respond_to(:start_mission)
      expect(manager).to respond_to(:advance_mission)
      expect(manager).to respond_to(:get_mission_status)
      expect(manager).to respond_to(:acquire_resource)
      expect(manager).to respond_to(:check_resource_availability)
      expect(manager).to respond_to(:scout_system)
      expect(manager).to respond_to(:get_scouting_results)
      expect(manager).to respond_to(:queue_mission)
      expect(manager).to respond_to(:request_resource)
    end

    it 'maintains shared state across services' do
      # Queue a mission
      manager.queue_mission({ 'identifier' => 'integration_test' })

      # Request a resource
      manager.request_resource('Platinum', 25, :critical)

      # Check shared context
      shared_context = manager.instance_variable_get(:@shared_context)
      expect(shared_context.mission_queue.length).to eq(1)
      expect(shared_context.resource_requests.length).to eq(1)
      expect(shared_context.resource_requests.first[:priority]).to eq(:critical)
    end

    it 'coordinates services through shared context events' do
      coordinator = manager.instance_variable_get(:@service_coordinator)

      # Spy on event handling
      allow(coordinator).to receive(:handle_event)

      # Trigger events through manager
      manager.queue_mission({ 'type' => 'test' })
      manager.request_resource('Silver', 5)

      # Verify events were handled
      expect(coordinator).to have_received(:handle_event).with(:mission_queued, { 'type' => 'test' })
      expect(coordinator).to have_received(:handle_event).with(:resource_requested, anything)
    end
  end
end
