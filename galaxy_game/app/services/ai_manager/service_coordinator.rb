# app/services/ai_manager/service_coordinator.rb
module AIManager
  class ServiceCoordinator
    attr_reader :shared_context, :task_engine, :resource_service, :scout_logic

    def initialize(shared_context)
      @shared_context = shared_context
      @task_engine = nil
      @resource_service = ResourceAcquisitionService
      @scout_logic = nil
      @shared_context.add_listener(self)
    end

    # Event handler for shared context notifications
    def handle_event(event_type, data = {})
      case event_type
      when :mission_queued
        handle_mission_queued(data)
      when :resource_requested
        handle_resource_requested(data)
      when :scouting_completed
        handle_scouting_completed(data)
      end
    end

    # Mission coordination
    def start_mission(mission_data)
      return false unless mission_data['identifier']

      begin
        @task_engine = TaskExecutionEngine.new(mission_data['identifier'])
        @shared_context.register_active_mission(mission_data['identifier'], @task_engine)

        # Start the mission execution
        result = @task_engine.start
        Rails.logger.info "[ServiceCoordinator] Started mission #{mission_data['identifier']}: #{result}"

        true
      rescue => e
        Rails.logger.error "[ServiceCoordinator] Failed to start mission #{mission_data['identifier']}: #{e.message}"
        false
      end
    end

    def advance_mission(mission_id)
      mission = @shared_context.get_active_mission(mission_id)
      return false unless mission

      begin
        result = mission[:engine].execute_next_task
        Rails.logger.info "[ServiceCoordinator] Advanced mission #{mission_id}: #{result}"

        # Check if mission is complete
        if mission[:engine].instance_variable_get(:@current_task_index) >= mission[:engine].instance_variable_get(:@task_list).length
          @shared_context.unregister_active_mission(mission_id)
        end

        result
      rescue => e
        Rails.logger.error "[ServiceCoordinator] Failed to advance mission #{mission_id}: #{e.message}"
        false
      end
    end

    def get_mission_status(mission_id)
      mission = @shared_context.get_active_mission(mission_id)
      return nil unless mission

      {
        mission_id: mission_id,
        current_task_index: mission[:engine].instance_variable_get(:@current_task_index),
        total_tasks: mission[:engine].instance_variable_get(:@task_list).length,
        produced_materials: mission[:engine].instance_variable_get(:@produced_materials),
        consumed_materials: mission[:engine].instance_variable_get(:@consumed_materials),
        started_at: mission[:started_at]
      }
    end

    # Resource coordination
    def acquire_resource(material, quantity, settlement = nil)
      settlement ||= @shared_context.settlement
      return false unless settlement

      begin
        result = @resource_service.order_acquisition(settlement, material, quantity)
        Rails.logger.info "[ServiceCoordinator] Ordered acquisition: #{material} x#{quantity} for #{settlement.name}"

        # Track the request in shared context
        @shared_context.request_resource(material, quantity, :high)

        result
      rescue => e
        Rails.logger.error "[ServiceCoordinator] Failed to acquire resource #{material}: #{e.message}"
        false
      end
    end

    def check_resource_availability(material, settlement = nil)
      settlement ||= @shared_context.settlement
      return 0 unless settlement

      @resource_service.is_local_resource?(material) ?
        settlement.inventory.current_storage_of(material) : 0
    end

    # Scouting coordination
    def scout_system(system_data = nil)
      system_data ||= @shared_context.system_data
      return false unless system_data

      begin
        @scout_logic = ScoutLogic.new(system_data)
        analysis = @scout_logic.analyze_system_patterns

        # Store results in shared context
        system_id = system_data[:id] || system_data['id'] || 'unknown_system'
        @shared_context.store_scouting_result(system_id, analysis)

        Rails.logger.info "[ServiceCoordinator] Completed scouting for system #{system_id}"
        analysis
      rescue => e
        Rails.logger.error "[ServiceCoordinator] Failed to scout system: #{e.message}"
        false
      end
    end

    def get_scouting_results(system_id = nil)
      if system_id
        @shared_context.get_scouting_result(system_id)
      else
        @shared_context.scouting_results
      end
    end

    # Economic coordination
    def update_economic_metrics(settlement = nil)
      settlement ||= @shared_context.settlement
      return unless settlement

      # Update various economic metrics in shared context
      @shared_context.update_economic_state(:settlement_population, settlement.current_population)
      @shared_context.update_economic_state(:power_output, settlement.operational_data.dig('generated', 'energy_kwh', 'current_output') || 0)
      @shared_context.update_economic_state(:resource_storage, settlement.operational_data.dig('resource_management', 'storage_capacity') || 0)

      Rails.logger.info "[ServiceCoordinator] Updated economic metrics for #{settlement.name}"
    end

    # Batch operations
    def process_pending_missions
      while (mission_data = @shared_context.dequeue_mission)
        start_mission(mission_data)
      end
    end

    def process_resource_requests
      @shared_context.resource_requests.each do |request|
        next unless request[:status] == :pending

        if check_resource_availability(request[:material]) >= request[:quantity]
          acquire_resource(request[:material], request[:quantity], @shared_context.settlement)
          @shared_context.fulfill_resource_request(request, :coordinator)
        end
      end
    end

    private

    def handle_mission_queued(mission_data)
      Rails.logger.info "[ServiceCoordinator] Mission queued: #{mission_data['identifier']}"
      # Could trigger immediate processing or scheduling
    end

    def handle_resource_requested(request)
      Rails.logger.info "[ServiceCoordinator] Resource requested: #{request[:material]} x#{request[:quantity]}"
      # Could trigger acquisition logic
    end

    def handle_scouting_completed(data)
      Rails.logger.info "[ServiceCoordinator] Scouting completed for system #{data[:system_id]}"
      # Could trigger follow-up actions based on scouting results
    end
  end
end