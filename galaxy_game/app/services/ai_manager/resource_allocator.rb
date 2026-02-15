# app/services/ai_manager/resource_allocator.rb
module AIManager
  class ResourceAllocator
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Allocate resources across the system based on arbitrated requests
    def allocate_resources(arbitrated_requests, system_state)
      allocations = []

      # Group requests by resource type
      requests_by_resource = group_requests_by_resource(arbitrated_requests)

      # Allocate each resource type
      requests_by_resource.each do |resource, requests|
        resource_allocations = allocate_resource_type(resource, requests, system_state)
        allocations.concat(resource_allocations)
      end

      allocations
    end

    # Identify potential transfers between settlements
    def identify_transfers(source_manager, target_manager)
      transfers = []

      # Check what target needs and source can provide
      target_needs = identify_settlement_needs(target_manager)
      source_capabilities = identify_settlement_capabilities(source_manager)

      target_needs.each do |need|
        resource = need[:resource]
        quantity_needed = need[:quantity]

        if source_capabilities[resource] && source_capabilities[resource] >= quantity_needed
          transfers << {
            source_settlement: source_manager.settlement,
            target_settlement: target_manager.settlement,
            resource: resource,
            quantity: quantity_needed,
            priority: need[:priority],
            transport_cost: calculate_transport_cost(source_manager.settlement, target_manager.settlement, resource, quantity_needed)
          }
        end
      end

      transfers
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

    # Allocate a specific resource type across settlements
    def allocate_resource_type(resource, requests, system_state)
      allocations = []

      # Sort requests by priority
      sorted_requests = requests.sort_by { |req| -priority_value(req[:priority]) }

      # Get total available system resources
      total_available = system_state.total_resources[resource] || 0

      # Allocate using fair sharing algorithm
      allocated_quantity = 0

      sorted_requests.each do |request|
        break if allocated_quantity >= total_available

        allocation_quantity = calculate_allocation_quantity(request, total_available, allocated_quantity, sorted_requests.size)

        if allocation_quantity > 0
          allocations << {
            settlement_id: request[:settlement_id],
            resource: resource,
            quantity: allocation_quantity,
            priority: request[:priority],
            source: :system_allocation
          }

          allocated_quantity += allocation_quantity
        end
      end

      allocations
    end

    # Calculate how much of a resource to allocate to a settlement
    def calculate_allocation_quantity(request, total_available, already_allocated, total_requests)
      requested_quantity = request[:quantity]
      remaining_available = total_available - already_allocated

      # Base allocation on priority and availability
      priority_multiplier = priority_multiplier(request[:priority])

      # Fair share calculation
      fair_share = remaining_available / [total_requests, 1].max.to_f

      # Allocate up to requested amount, but not more than fair share
      allocation = [requested_quantity * priority_multiplier, fair_share].min

      # Don't allocate more than is available
      [allocation, remaining_available].min.round
    end

    # Identify what a settlement needs
    def identify_settlement_needs(manager)
      needs = []

      # Check resource gaps
      resource_gaps = identify_resource_gaps(manager)

      resource_gaps.each do |gap|
        needs << {
          resource: gap[:resource],
          quantity: gap[:quantity],
          priority: gap[:priority]
        }
      end

      needs
    end

    # Identify what a settlement can provide
    def identify_settlement_capabilities(manager)
      capabilities = {}

      # Check surplus resources
      surplus_resources = identify_surplus_resources(manager)

      surplus_resources.each do |resource, quantity|
        capabilities[resource] = quantity
      end

      capabilities
    end

    # Calculate transport cost between settlements
    def calculate_transport_cost(source_settlement, target_settlement, resource, quantity)
      # Base cost factors
      base_cost = 10

      # Distance factor (simplified - would use actual celestial mechanics)
      distance_factor = calculate_distance_factor(source_settlement, target_settlement)

      # Resource type factor
      resource_factor = resource_transport_factor(resource)

      # Quantity factor
      quantity_factor = [quantity / 100.0, 1.0].min # Diminishing returns for large quantities

      (base_cost * distance_factor * resource_factor * quantity_factor).round
    end

    # Helper methods

    def priority_value(priority)
      case priority
      when :critical then 4
      when :high then 3
      when :medium then 2
      when :low then 1
      else 0
      end
    end

    def priority_multiplier(priority)
      case priority
      when :critical then 1.5
      when :high then 1.2
      when :medium then 1.0
      when :low then 0.8
      else 1.0
      end
    end

    def identify_resource_gaps(manager)
      gaps = []
      optimal_levels = { minerals: 100, energy: 100, food: 100, water: 100, steel: 50, electronics: 30 }

      current_resources = manager.settlement_resources

      optimal_levels.each do |resource, optimal|
        current = current_resources[resource] || 0
        if current < optimal * 0.7 # Below 70% of optimal
          gap_quantity = optimal - current
          priority = current < optimal * 0.3 ? :critical : :high

          gaps << {
            resource: resource,
            quantity: gap_quantity,
            priority: priority
          }
        end
      end

      gaps
    end

    def identify_surplus_resources(manager)
      surplus = {}
      optimal_levels = { minerals: 100, energy: 100, food: 100, water: 100, steel: 50, electronics: 30 }

      current_resources = manager.settlement_resources

      optimal_levels.each do |resource, optimal|
        current = current_resources[resource] || 0
        if current > optimal * 1.2 # Above 120% of optimal
          surplus[resource] = current - optimal
        end
      end

      surplus
    end

    def calculate_distance_factor(source_settlement, target_settlement)
      # Simplified distance calculation
      # In reality, this would use orbital mechanics and celestial positions

      source_body = source_settlement.location&.celestial_body
      target_body = target_settlement.location&.celestial_body

      if source_body == target_body
        # Same celestial body - minimal distance
        1.0
      elsif source_body.is_a?(Planet) && target_body.is_a?(Moon) && target_body.planet == source_body
        # Planet to its moon
        1.2
      elsif source_body.is_a?(Moon) && target_body.is_a?(Planet) && source_body.planet == target_body
        # Moon to its planet
        1.2
      else
        # Different celestial bodies - higher cost
        2.0
      end
    end

    def resource_transport_factor(resource)
      # Different resources have different transport characteristics
      case resource.to_sym
      when :minerals, :steel then 1.0  # Dense, standard transport
      when :energy then 0.8            # Energy is efficient to transport
      when :food, :water then 1.2      # Perishables need special handling
      when :electronics then 1.5       # Fragile and valuable
      else 1.0
      end
    end
  end
end