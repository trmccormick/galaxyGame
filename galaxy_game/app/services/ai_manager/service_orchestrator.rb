# app/services/ai_manager/service_orchestrator.rb
require_relative 'task_execution_engine'
require_relative 'resource_acquisition_service'
require_relative 'scout_logic'

module AIManager
  class ServiceOrchestrator
    attr_reader :shared_context, :service_coordinator, :service_states, :service_priorities

    def initialize(shared_context, service_coordinator)
      @shared_context = shared_context
      @service_coordinator = service_coordinator
      @service_states = {}
      @service_priorities = initialize_service_priorities

      @shared_context.add_listener(self)
      initialize_service_states
    end

    # Event handler for shared context notifications
    def handle_event(event_type, data = {})
      case event_type
      when :mission_started
        update_service_state(:task_execution_engine, :active)
      when :mission_completed
        update_service_state(:task_execution_engine, :idle)
      when :resource_acquisition_started
        update_service_state(:resource_acquisition_service, :active)
      when :resource_acquisition_completed
        update_service_state(:resource_acquisition_service, :idle)
      when :scouting_started
        update_service_state(:scout_logic, :active)
      when :scouting_completed
        update_service_state(:scout_logic, :idle)
      end
    end

    # === SERVICE ORCHESTRATION METHODS ===

    # Main orchestration method - coordinates service execution and priorities
    def orchestrate_services
      Rails.logger.info "[ServiceOrchestrator] Beginning service orchestration"

      # Update service states and health
      update_service_health

      # Balance service loads
      balance_service_loads

      # Optimize service priorities based on system state
      optimize_service_priorities

      # Coordinate interdependent service operations
      coordinate_service_operations

      Rails.logger.info "[ServiceOrchestrator] Service orchestration completed"
    end

    # Execute a coordinated service operation
    def execute_coordinated_operation(operation_type, params = {})
      case operation_type
      when :resource_acquisition_with_scouting
        execute_resource_acquisition_with_scouting(params)
      when :mission_with_resource_support
        execute_mission_with_resource_support(params)
      when :scouting_with_expansion_planning
        execute_scouting_with_expansion_planning(params)
      else
        Rails.logger.warn "[ServiceOrchestrator] Unknown operation type: #{operation_type}"
        false
      end
    end

    # Get service orchestration status
    def orchestration_status
      {
        service_states: @service_states,
        service_priorities: @service_priorities,
        active_operations: active_operations_count,
        service_health: service_health_summary
      }
    end

    # === SERVICE STATE MANAGEMENT ===

    # Update the state of a specific service
    def update_service_state(service_name, state)
      @service_states[service_name] = {
        state: state,
        last_updated: Time.current,
        active_operations: @service_states[service_name]&.dig(:active_operations) || 0
      }
    end

    # Get the current state of a service
    def get_service_state(service_name)
      @service_states[service_name] || { state: :unknown, last_updated: nil, active_operations: 0 }
    end

    # Check if a service is available for new operations
    def service_available?(service_name)
      state = get_service_state(service_name)
      state[:state] != :overloaded && state[:state] != :failed
    end

    # === SERVICE PRIORITY MANAGEMENT ===

    # Update service priorities based on system needs
    def update_service_priorities(new_priorities)
      @service_priorities.merge!(new_priorities)
      Rails.logger.info "[ServiceOrchestrator] Updated service priorities: #{@service_priorities}"
    end

    # Get priority for a specific service
    def get_service_priority(service_name)
      @service_priorities[service_name] || :normal
    end

    # === COORDINATED OPERATIONS ===

    # Execute resource acquisition with scouting support
    def execute_resource_acquisition_with_scouting(params)
      settlement = params[:settlement]
      material = params[:material]
      quantity = params[:quantity]
      scout_system = params[:scout_system]

      Rails.logger.info "[ServiceOrchestrator] Executing coordinated resource acquisition with scouting"

      # First, scout the system if requested
      if scout_system && service_available?(:scout_logic)
        scouting_result = @service_coordinator.scout_system(scout_system)
        if scouting_result
          Rails.logger.info "[ServiceOrchestrator] Scouting completed, proceeding with resource acquisition"
        end
      end

      # Then acquire the resource
      if service_available?(:resource_acquisition_service)
        result = @service_coordinator.acquire_resource(material, quantity, settlement)
        Rails.logger.info "[ServiceOrchestrator] Resource acquisition #{result ? 'successful' : 'failed'}"
        result
      else
        Rails.logger.warn "[ServiceOrchestrator] Resource acquisition service not available"
        false
      end
    end

    # Execute mission with resource support
    def execute_mission_with_resource_support(params)
      mission_data = params[:mission_data]
      required_resources = params[:required_resources] || []

      Rails.logger.info "[ServiceOrchestrator] Executing coordinated mission with resource support"

      # Check and acquire required resources first
      resource_check_passed = true
      required_resources.each do |resource|
        material = resource[:material]
        quantity = resource[:quantity]
        settlement = resource[:settlement]

        if @service_coordinator.check_resource_availability(material, settlement) < quantity
          Rails.logger.info "[ServiceOrchestrator] Acquiring required resource: #{material} x#{quantity}"
          unless @service_coordinator.acquire_resource(material, quantity, settlement)
            resource_check_passed = false
            break
          end
        end
      end

      if resource_check_passed && service_available?(:task_execution_engine)
        result = @service_coordinator.start_mission(mission_data)
        Rails.logger.info "[ServiceOrchestrator] Mission execution #{result ? 'started' : 'failed'}"
        result
      else
        Rails.logger.warn "[ServiceOrchestrator] Mission prerequisites not met or task engine unavailable"
        false
      end
    end

    # Execute scouting with expansion planning
    def execute_scouting_with_expansion_planning(params)
      system_data = params[:system_data]
      settlement = params[:settlement]

      Rails.logger.info "[ServiceOrchestrator] Executing coordinated scouting with expansion planning"

      if service_available?(:scout_logic)
        # Perform scouting
        scouting_result = @service_coordinator.scout_system(system_data)

        if scouting_result
          # Analyze scouting results for expansion opportunities
          expansion_opportunities = analyze_expansion_opportunities(scouting_result, settlement)

          if expansion_opportunities.any?
            Rails.logger.info "[ServiceOrchestrator] Found #{expansion_opportunities.size} expansion opportunities"
            # Could trigger expansion planning here
          end

          scouting_result
        else
          false
        end
      else
        Rails.logger.warn "[ServiceOrchestrator] Scout logic service not available"
        false
      end
    end

    private

    # Initialize service priorities
    def initialize_service_priorities
      {
        task_execution_engine: :high,
        resource_acquisition_service: :high,
        scout_logic: :medium
      }
    end

    # Initialize service states
    def initialize_service_states
      @service_states = {
        task_execution_engine: { state: :idle, last_updated: Time.current, active_operations: 0 },
        resource_acquisition_service: { state: :idle, last_updated: Time.current, active_operations: 0 },
        scout_logic: { state: :idle, last_updated: Time.current, active_operations: 0 }
      }
    end

    # Update overall service health
    def update_service_health
      @service_states.each do |service_name, state|
        # Check for stale services (no updates in last 5 minutes)
        if state[:last_updated] && state[:last_updated] < 5.minutes.ago
          update_service_state(service_name, :stale)
        end

        # Check for overloaded services (too many active operations)
        if state[:active_operations] > 5
          update_service_state(service_name, :overloaded)
        end
      end
    end

    # Balance loads across services
    def balance_service_loads
      # Identify overloaded services
      overloaded_services = @service_states.select { |_, state| state[:state] == :overloaded }

      overloaded_services.each do |service_name, _|
        Rails.logger.warn "[ServiceOrchestrator] Service #{service_name} is overloaded, reducing priority"
        @service_priorities[service_name] = :low
      end

      # Identify underutilized services
      idle_services = @service_states.select { |_, state| state[:state] == :idle }

      idle_services.each do |service_name, _|
        Rails.logger.info "[ServiceOrchestrator] Service #{service_name} is idle, increasing priority"
        @service_priorities[service_name] = :high
      end
    end

    # Optimize service priorities based on system state
    def optimize_service_priorities
      # Get current system state from shared context
      economic_state = @shared_context.economic_state
      mission_queue_length = @shared_context.mission_queue.length
      resource_requests_count = @shared_context.resource_requests.select { |r| r[:status] == :pending }.size

      # Adjust priorities based on system needs
      if mission_queue_length > 5
        @service_priorities[:task_execution_engine] = :critical
      elsif mission_queue_length > 2
        @service_priorities[:task_execution_engine] = :high
      end

      if resource_requests_count > 10
        @service_priorities[:resource_acquisition_service] = :critical
      elsif resource_requests_count > 5
        @service_priorities[:resource_acquisition_service] = :high
      end

      if economic_state[:strategic_position] && economic_state[:strategic_position] > 0.8
        @service_priorities[:scout_logic] = :high
      end
    end

    # Coordinate operations between services
    def coordinate_service_operations
      # Ensure resource acquisition supports active missions
      active_missions = @shared_context.active_missions
      if active_missions.any?
        Rails.logger.info "[ServiceOrchestrator] Coordinating resources for #{active_missions.size} active missions"
        # Logic to ensure missions have required resources
      end

      # Ensure scouting supports expansion planning
      scouting_results = @shared_context.scouting_results
      if scouting_results.any?
        Rails.logger.info "[ServiceOrchestrator] Analyzing #{scouting_results.size} scouting results for coordination"
        # Logic to coordinate scouting with other services
      end
    end

    # Analyze expansion opportunities from scouting results
    def analyze_expansion_opportunities(scouting_result, settlement)
      opportunities = []

      # Check for terraformable bodies
      if scouting_result[:terraformable_bodies]&.any?
        opportunities << {
          type: :terraforming,
          bodies: scouting_result[:terraformable_bodies],
          priority: :high
        }
      end

      # Check for resource-rich bodies
      if scouting_result[:resource_rich_bodies]&.any?
        opportunities << {
          type: :resource_extraction,
          bodies: scouting_result[:resource_rich_bodies],
          priority: :medium
        }
      end

      opportunities
    end

    # Get count of active operations
    def active_operations_count
      @service_states.values.sum { |state| state[:active_operations] }
    end

    # Get service health summary
    def service_health_summary
      healthy = @service_states.count { |_, state| state[:state] == :idle || state[:state] == :active }
      total = @service_states.size

      {
        healthy_services: healthy,
        total_services: total,
        health_percentage: (healthy.to_f / total * 100).round(1)
      }
    end
  end
end