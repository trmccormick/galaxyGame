# spec/services/ai_manager/service_orchestrator_spec.rb
require 'rails_helper'

RSpec.describe AIManager::ServiceOrchestrator, type: :service do
  let(:settlement) { create(:base_settlement) }
  let(:shared_context) { AIManager::SharedContext.new(settlement: settlement) }
  let(:service_coordinator) { AIManager::ServiceCoordinator.new(shared_context) }
  let(:service_orchestrator) { AIManager::ServiceOrchestrator.new(shared_context, service_coordinator) }

  describe '#initialize' do
    it 'initializes with shared context and service coordinator' do
      expect(service_orchestrator.shared_context).to eq(shared_context)
      expect(service_orchestrator.service_coordinator).to eq(service_coordinator)
    end

    it 'registers as a shared context listener' do
      expect(shared_context.instance_variable_get(:@listeners)).to include(service_orchestrator)
    end

    it 'initializes service states' do
      states = service_orchestrator.service_states
      expect(states.keys).to include(:task_execution_engine, :resource_acquisition_service, :scout_logic)
      expect(states[:task_execution_engine][:state]).to eq(:idle)
    end

    it 'initializes service priorities' do
      priorities = service_orchestrator.service_priorities
      expect(priorities[:task_execution_engine]).to eq(:high)
      expect(priorities[:resource_acquisition_service]).to eq(:high)
      expect(priorities[:scout_logic]).to eq(:medium)
    end
  end

  describe '#handle_event' do
    it 'updates service state when mission starts' do
      service_orchestrator.handle_event(:mission_started)

      state = service_orchestrator.get_service_state(:task_execution_engine)
      expect(state[:state]).to eq(:active)
    end

    it 'updates service state when resource acquisition completes' do
      service_orchestrator.handle_event(:resource_acquisition_completed)

      state = service_orchestrator.get_service_state(:resource_acquisition_service)
      expect(state[:state]).to eq(:idle)
    end

    it 'updates service state when scouting starts' do
      service_orchestrator.handle_event(:scouting_started)

      state = service_orchestrator.get_service_state(:scout_logic)
      expect(state[:state]).to eq(:active)
    end
  end

  describe '#orchestrate_services' do
    it 'updates service health' do
      expect(service_orchestrator).to receive(:update_service_health)
      service_orchestrator.orchestrate_services
    end

    it 'balances service loads' do
      expect(service_orchestrator).to receive(:balance_service_loads)
      service_orchestrator.orchestrate_services
    end

    it 'optimizes service priorities' do
      expect(service_orchestrator).to receive(:optimize_service_priorities)
      service_orchestrator.orchestrate_services
    end

    it 'coordinates service operations' do
      expect(service_orchestrator).to receive(:coordinate_service_operations)
      service_orchestrator.orchestrate_services
    end
  end

  describe '#execute_coordinated_operation' do
    context 'resource_acquisition_with_scouting' do
      let(:params) {
        {
          settlement: settlement,
          material: 'Iron',
          quantity: 100,
          scout_system: { id: 'test_system' }
        }
      }

      it 'executes resource acquisition with scouting when services are available' do
        allow(service_orchestrator).to receive(:service_available?).and_return(true)
        allow(service_coordinator).to receive(:scout_system).and_return(true)
        allow(service_coordinator).to receive(:acquire_resource).and_return(true)

        result = service_orchestrator.execute_coordinated_operation(:resource_acquisition_with_scouting, params)
        expect(result).to be true
      end

      it 'skips scouting if not requested' do
        params_without_scouting = params.except(:scout_system)
        allow(service_orchestrator).to receive(:service_available?).and_return(true)
        allow(service_coordinator).to receive(:acquire_resource).and_return(true)

        expect(service_coordinator).not_to receive(:scout_system)
        service_orchestrator.execute_coordinated_operation(:resource_acquisition_with_scouting, params_without_scouting)
      end

      it 'returns false if resource acquisition service is not available' do
        allow(service_orchestrator).to receive(:service_available?).with(:resource_acquisition_service).and_return(false)

        result = service_orchestrator.execute_coordinated_operation(:resource_acquisition_with_scouting, params)
        expect(result).to be false
      end
    end

    context 'mission_with_resource_support' do
      let(:mission_data) { { 'identifier' => 'test_mission' } }
      let(:required_resources) { [{ material: 'Steel', quantity: 50, settlement: settlement }] }
      let(:params) {
        {
          mission_data: mission_data,
          required_resources: required_resources
        }
      }

      it 'executes mission after acquiring required resources' do
        allow(service_coordinator).to receive(:check_resource_availability).and_return(0) # Not enough resources
        allow(service_coordinator).to receive(:acquire_resource).and_return(true)
        allow(service_orchestrator).to receive(:service_available?).and_return(true)
        allow(service_coordinator).to receive(:start_mission).and_return(true)

        result = service_orchestrator.execute_coordinated_operation(:mission_with_resource_support, params)
        expect(result).to be true
      end

      it 'fails if resource acquisition fails' do
        allow(service_coordinator).to receive(:check_resource_availability).and_return(0)
        allow(service_coordinator).to receive(:acquire_resource).and_return(false)
        allow(service_orchestrator).to receive(:service_available?).and_return(true)

        result = service_orchestrator.execute_coordinated_operation(:mission_with_resource_support, params)
        expect(result).to be false
      end

      it 'returns false if task execution engine is not available' do
        allow(service_orchestrator).to receive(:service_available?).with(:task_execution_engine).and_return(false)

        result = service_orchestrator.execute_coordinated_operation(:mission_with_resource_support, params)
        expect(result).to be false
      end
    end

    context 'scouting_with_expansion_planning' do
      let(:system_data) { { id: 'test_system' } }
      let(:params) {
        {
          system_data: system_data,
          settlement: settlement
        }
      }

      it 'executes scouting with expansion analysis when service is available' do
        scouting_result = { terraformable_bodies: ['body1'], resource_rich_bodies: [] }
        allow(service_orchestrator).to receive(:service_available?).and_return(true)
        allow(service_coordinator).to receive(:scout_system).and_return(scouting_result)

        result = service_orchestrator.execute_coordinated_operation(:scouting_with_expansion_planning, params)
        expect(result).to eq(scouting_result)
      end

      it 'analyzes expansion opportunities from scouting results' do
        scouting_result = { terraformable_bodies: ['body1'], resource_rich_bodies: ['body2'] }
        allow(service_orchestrator).to receive(:service_available?).and_return(true)
        allow(service_coordinator).to receive(:scout_system).and_return(scouting_result)

        expect(service_orchestrator).to receive(:analyze_expansion_opportunities).and_call_original
        service_orchestrator.execute_coordinated_operation(:scouting_with_expansion_planning, params)
      end

      it 'returns false if scout logic service is not available' do
        allow(service_orchestrator).to receive(:service_available?).and_return(false)

        result = service_orchestrator.execute_coordinated_operation(:scouting_with_expansion_planning, params)
        expect(result).to be false
      end
    end

    context 'unknown operation type' do
      it 'logs warning and returns false for unknown operation' do
        allow(Rails.logger).to receive(:warn)

        result = service_orchestrator.execute_coordinated_operation(:unknown_operation)
        expect(result).to be false
        expect(Rails.logger).to have_received(:warn).with('[ServiceOrchestrator] Unknown operation type: unknown_operation')
      end
    end
  end

  describe '#orchestration_status' do
    it 'returns comprehensive orchestration status' do
      status = service_orchestrator.orchestration_status

      expect(status).to have_key(:service_states)
      expect(status).to have_key(:service_priorities)
      expect(status).to have_key(:active_operations)
      expect(status).to have_key(:service_health)
    end

    it 'includes service health summary' do
      status = service_orchestrator.orchestration_status

      health = status[:service_health]
      expect(health).to have_key(:healthy_services)
      expect(health).to have_key(:total_services)
      expect(health).to have_key(:health_percentage)
    end
  end

  describe '#update_service_priorities' do
    it 'updates service priorities' do
      new_priorities = { task_execution_engine: :critical, scout_logic: :low }

      service_orchestrator.update_service_priorities(new_priorities)

      expect(service_orchestrator.get_service_priority(:task_execution_engine)).to eq(:critical)
      expect(service_orchestrator.get_service_priority(:scout_logic)).to eq(:low)
    end
  end

  describe '#service_available?' do
    it 'returns true for idle services' do
      expect(service_orchestrator.service_available?(:task_execution_engine)).to be true
    end

    it 'returns false for overloaded services' do
      service_orchestrator.update_service_state(:task_execution_engine, :overloaded)

      expect(service_orchestrator.service_available?(:task_execution_engine)).to be false
    end

    it 'returns false for failed services' do
      service_orchestrator.update_service_state(:task_execution_engine, :failed)

      expect(service_orchestrator.service_available?(:task_execution_engine)).to be false
    end
  end

  describe 'private methods' do
    describe '#update_service_health' do
      it 'marks stale services' do
        # Set last updated to more than 5 minutes ago
        service_orchestrator.instance_variable_get(:@service_states)[:task_execution_engine][:last_updated] = 10.minutes.ago

        service_orchestrator.send(:update_service_health)

        state = service_orchestrator.get_service_state(:task_execution_engine)
        expect(state[:state]).to eq(:stale)
      end

      it 'marks overloaded services' do
        # Set active operations to more than 5
        service_orchestrator.instance_variable_get(:@service_states)[:task_execution_engine][:active_operations] = 10

        service_orchestrator.send(:update_service_health)

        state = service_orchestrator.get_service_state(:task_execution_engine)
        expect(state[:state]).to eq(:overloaded)
      end
    end

    describe '#balance_service_loads' do
      it 'reduces priority of overloaded services' do
        service_orchestrator.update_service_state(:task_execution_engine, :overloaded)

        service_orchestrator.send(:balance_service_loads)

        expect(service_orchestrator.get_service_priority(:task_execution_engine)).to eq(:low)
      end

      it 'increases priority of idle services' do
        service_orchestrator.update_service_state(:scout_logic, :idle)
        service_orchestrator.update_service_priorities({ scout_logic: :low }) # Set to low first

        service_orchestrator.send(:balance_service_loads)

        expect(service_orchestrator.get_service_priority(:scout_logic)).to eq(:high)
      end
    end

    describe '#optimize_service_priorities' do
      it 'increases task execution priority when mission queue is long' do
        allow(shared_context).to receive(:mission_queue).and_return(Array.new(6, {})) # 6 missions

        service_orchestrator.send(:optimize_service_priorities)

        expect(service_orchestrator.get_service_priority(:task_execution_engine)).to eq(:critical)
      end

      it 'increases resource acquisition priority when many requests pending' do
        pending_requests = Array.new(11) { { status: :pending } } # 11 pending requests
        allow(shared_context).to receive(:resource_requests).and_return(pending_requests)

        service_orchestrator.send(:optimize_service_priorities)

        expect(service_orchestrator.get_service_priority(:resource_acquisition_service)).to eq(:critical)
      end

      it 'increases scouting priority when strategic position is high' do
        allow(shared_context).to receive(:economic_state).and_return({ strategic_position: 0.9 })

        service_orchestrator.send(:optimize_service_priorities)

        expect(service_orchestrator.get_service_priority(:scout_logic)).to eq(:high)
      end
    end

    describe '#analyze_expansion_opportunities' do
      it 'identifies terraformable bodies as high priority opportunities' do
        scouting_result = { terraformable_bodies: ['body1'], resource_rich_bodies: [] }

        opportunities = service_orchestrator.send(:analyze_expansion_opportunities, scouting_result, settlement)

        expect(opportunities.size).to eq(1)
        expect(opportunities.first[:type]).to eq(:terraforming)
        expect(opportunities.first[:priority]).to eq(:high)
      end

      it 'identifies resource-rich bodies as medium priority opportunities' do
        scouting_result = { terraformable_bodies: [], resource_rich_bodies: ['body1'] }

        opportunities = service_orchestrator.send(:analyze_expansion_opportunities, scouting_result, settlement)

        expect(opportunities.size).to eq(1)
        expect(opportunities.first[:type]).to eq(:resource_extraction)
        expect(opportunities.first[:priority]).to eq(:medium)
      end

      it 'returns multiple opportunities when both types are present' do
        scouting_result = {
          terraformable_bodies: ['body1'],
          resource_rich_bodies: ['body2']
        }

        opportunities = service_orchestrator.send(:analyze_expansion_opportunities, scouting_result, settlement)

        expect(opportunities.size).to eq(2)
        types = opportunities.map { |o| o[:type] }
        expect(types).to include(:terraforming, :resource_extraction)
      end
    end
  end
end