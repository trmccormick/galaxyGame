# app/services/ai_manager/priority_arbitrator.rb
module AIManager
  class PriorityArbitrator
    attr_reader :active_conflicts

    def initialize
      @active_conflicts = []
      @priority_levels = {
        critical: 4,
        high: 3,
        medium: 2,
        low: 1
      }
    end

    # Arbitrate competing resource requests
    def arbitrate_requests(requests)
      return requests if requests.size <= 1

      # Group requests by resource
      requests_by_resource = group_requests_by_resource(requests)

      # Arbitrate each resource separately
      arbitrated_requests = []

      requests_by_resource.each do |resource, resource_requests|
        arbitrated = arbitrate_resource_requests(resource, resource_requests)
        arbitrated_requests.concat(arbitrated)
      end

      arbitrated_requests
    end

    # Escalate priority for crisis situations
    def escalate_crisis(settlement_id, crisis_resources)
      Rails.logger.warn "[PriorityArbitrator] Escalating crisis for settlement #{settlement_id}: #{crisis_resources}"

      # Mark crisis resources as critical priority
      @active_conflicts << {
        type: :crisis,
        settlement_id: settlement_id,
        resources: crisis_resources,
        escalated_at: Time.current,
        resolution_deadline: Time.current + 1.hour
      }
    end

    # Resolve a specific conflict
    def resolve_conflict(conflict_id, resolution)
      conflict = @active_conflicts.find { |c| c[:id] == conflict_id }
      return false unless conflict

      # Apply resolution
      apply_conflict_resolution(conflict, resolution)

      # Remove resolved conflict
      @active_conflicts.delete(conflict)

      Rails.logger.info "[PriorityArbitrator] Resolved conflict #{conflict_id}"
      true
    end

    # Get current priority level for a settlement
    def settlement_priority_level(settlement_id)
      # Check for active crises
      crisis_conflicts = @active_conflicts.select do |conflict|
        conflict[:type] == :crisis && conflict[:settlement_id] == settlement_id
      end

      return :critical if crisis_conflicts.any?

      # Check settlement health and other factors
      # This would integrate with settlement manager
      :medium # Default
    end

    # Check if a request can be granted
    def can_grant_request?(request, system_state)
      resource = request[:resource]
      quantity = request[:quantity]

      # Check system availability
      available = system_state.total_resources[resource] || 0

      # Apply priority-based availability adjustment
      priority = request[:priority]
      adjusted_available = adjust_availability_by_priority(available, priority)

      quantity <= adjusted_available
    end

    private

    # Group requests by resource type
    def group_requests_by_resource(requests)
      grouped = {}

      requests.each do |request|
        resource = request[:resource]
        grouped[resource] ||= []
        grouped[resource] << request
      end

      grouped
    end

    # Arbitrate requests for a specific resource
    def arbitrate_resource_requests(resource, requests)
      return requests if requests.size <= 1

      # Sort by priority and settlement priority level
      sorted_requests = requests.sort_by do |request|
        [
          -priority_value(request[:priority]),
          -priority_value(settlement_priority_level(request[:settlement_id]))
        ]
      end

      # Apply arbitration rules
      arbitrated = apply_arbitration_rules(sorted_requests, resource)

      # Record conflicts if any
      record_conflicts_if_needed(arbitrated, resource)

      arbitrated
    end

    # Apply arbitration rules to resolve conflicts
    def apply_arbitration_rules(requests, resource)
      arbitrated = []
      total_allocated = 0

      requests.each do |request|
        # Check if this request conflicts with higher priority requests
        conflict_detected = check_for_conflicts(request, arbitrated)

        if conflict_detected
          # Apply conflict resolution
          resolved_request = resolve_request_conflict(request, arbitrated, resource)
          arbitrated << resolved_request if resolved_request
        else
          # No conflict, grant the request
          arbitrated << request
        end
      end

      arbitrated
    end

    # Check if a request conflicts with existing arbitrated requests
    def check_for_conflicts(request, arbitrated_requests)
      # Check for resource availability conflicts
      total_requested = arbitrated_requests.sum { |r| r[:quantity] }
      total_requested + request[:quantity] > get_system_resource_limit(request[:resource])
    end

    # Resolve a conflict for a specific request
    def resolve_request_conflict(request, arbitrated_requests, resource)
      # Different resolution strategies based on conflict type

      # Strategy 1: Reduce quantity for lower priority requests
      if request[:priority] == :low || request[:priority] == :medium
        reduced_quantity = calculate_reduced_quantity(request, arbitrated_requests, resource)

        if reduced_quantity > 0
          return request.merge(quantity: reduced_quantity, arbitrated: true)
        end
      end

      # Strategy 2: Delay lower priority requests
      if can_delay_request?(request)
        return request.merge(delayed: true, arbitrated: true)
      end

      # Strategy 3: Deny the request
      nil
    end

    # Calculate reduced quantity for a request
    def calculate_reduced_quantity(request, arbitrated_requests, resource)
      total_allocated = arbitrated_requests.sum { |r| r[:quantity] }
      system_limit = get_system_resource_limit(resource)
      remaining = system_limit - total_allocated

      # Allocate fair share of remaining
      fair_share = remaining / 2.0 # Assume this is the second request

      [request[:quantity], fair_share].min.round
    end

    # Check if a request can be delayed
    def can_delay_request?(request)
      # Critical requests cannot be delayed
      request[:priority] != :critical
    end

    # Record conflicts for monitoring
    def record_conflicts_if_needed(arbitrated_requests, resource)
      over_allocated = check_over_allocation(arbitrated_requests, resource)

      if over_allocated
        @active_conflicts << {
          id: generate_conflict_id,
          type: :resource_over_allocation,
          resource: resource,
          requests: arbitrated_requests.map { |r| r[:settlement_id] },
          created_at: Time.current,
          severity: :medium
        }
      end
    end

    # Apply conflict resolution
    def apply_conflict_resolution(conflict, resolution)
      case resolution[:action]
      when :reallocate
        # Re-run arbitration with new constraints
        Rails.logger.info "[PriorityArbitrator] Reallocating resources for conflict resolution"
      when :escalate
        # Escalate to higher authority (system orchestrator)
        Rails.logger.warn "[PriorityArbitrator] Escalating conflict to system orchestrator"
      when :delay
        # Delay conflicting requests
        Rails.logger.info "[PriorityArbitrator] Delaying conflicting requests"
      end
    end

    # Helper methods

    def priority_value(priority)
      @priority_levels[priority] || 0
    end

    def get_system_resource_limit(resource)
      # This would be configurable and based on system capacity
      case resource.to_sym
      when :energy then 1000
      when :minerals then 800
      when :food then 600
      when :water then 700
      when :steel then 400
      when :electronics then 200
      else 500
      end
    end

    def check_over_allocation(requests, resource)
      total_requested = requests.sum { |r| r[:quantity] }
      limit = get_system_resource_limit(resource)

      total_requested > limit
    end

    def adjust_availability_by_priority(available, priority)
      # Higher priority gets access to more of the available resources
      multiplier = case priority
                   when :critical then 1.0
                   when :high then 0.9
                   when :medium then 0.7
                   when :low then 0.5
                   else 0.6
                   end

      available * multiplier
    end

    def generate_conflict_id
      "conflict_#{Time.current.to_i}_#{rand(1000)}"
    end
  end
end