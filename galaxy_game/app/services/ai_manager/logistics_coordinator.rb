# app/services/ai_manager/logistics_coordinator.rb
module AIManager
  class LogisticsCoordinator
    attr_reader :active_transfers

    def initialize(shared_context)
      @shared_context = shared_context
      @active_transfers = []
      @transport_capacity = initialize_transport_capacity
    end

    # Optimize and schedule transfers
    def optimize_transfers(needed_transfers, system_state)
      return [] if needed_transfers.empty?

      # Group transfers by route for optimization
      route_groups = group_transfers_by_route(needed_transfers)

      # Optimize each route
      optimized_transfers = []

      route_groups.each do |route, transfers|
        optimized = optimize_route_transfers(route, transfers, system_state)
        optimized_transfers.concat(optimized)
      end

      optimized_transfers
    end

    # Schedule transfers for execution
    def schedule_transfers(transfers)
      transfers.each do |transfer|
        schedule_transfer(transfer)
      end

      Rails.logger.info "[LogisticsCoordinator] Scheduled #{transfers.size} transfers"
    end

    # Get transfer status
    def transfer_status(transfer_id)
      transfer = @active_transfers.find { |t| t[:id] == transfer_id }
      return nil unless transfer

      {
        id: transfer[:id],
        status: transfer[:status],
        progress: transfer[:progress] || 0,
        estimated_completion: transfer[:estimated_completion],
        source: transfer[:source_settlement].name,
        target: transfer[:target_settlement].name,
        resource: transfer[:resource],
        quantity: transfer[:quantity]
      }
    end

    # Cancel a transfer
    def cancel_transfer(transfer_id)
      transfer = @active_transfers.find { |t| t[:id] == transfer_id }
      return false unless transfer

      # Release reserved resources
      source_manager = find_settlement_manager(transfer[:source_settlement])
      source_manager&.release_resources(transfer[:resource], transfer[:quantity])

      @active_transfers.delete(transfer)
      Rails.logger.info "[LogisticsCoordinator] Cancelled transfer #{transfer_id}"

      true
    end

    # Get logistics efficiency metrics
    def logistics_metrics
      total_transfers = @active_transfers.size
      completed_transfers = @active_transfers.count { |t| t[:status] == :completed }
      delayed_transfers = @active_transfers.count { |t| t[:status] == :delayed }

      {
        total_active_transfers: total_transfers,
        completion_rate: total_transfers > 0 ? completed_transfers / total_transfers.to_f : 0,
        delay_rate: total_transfers > 0 ? delayed_transfers / total_transfers.to_f : 0,
        average_transport_cost: calculate_average_transport_cost,
        capacity_utilization: calculate_capacity_utilization
      }
    end

    private

    # Initialize transport capacity (ships, routes, etc.)
    def initialize_transport_capacity
      # This would be based on available spacecraft and routes
      {
        mars_luna_capacity: 500,  # Units per transfer
        earth_mars_capacity: 300,
        luna_earth_capacity: 200,
        transfer_time_mars_luna: 2.hours,
        transfer_time_earth_mars: 6.months, # Simplified
        max_concurrent_transfers: 5
      }
    end

    # Group transfers by route for optimization
    def group_transfers_by_route(transfers)
      grouped = {}

      transfers.each do |transfer|
        route_key = generate_route_key(transfer)
        grouped[route_key] ||= []
        grouped[route_key] << transfer
      end

      grouped
    end

    # Optimize transfers for a specific route
    def optimize_route_transfers(route, transfers, system_state)
      # Combine compatible transfers
      combined_transfers = combine_compatible_transfers(transfers)

      # Optimize timing to minimize costs and delays
      timed_transfers = optimize_transfer_timing(combined_transfers, route)

      # Check capacity constraints
      capacity_constrained = apply_capacity_constraints(timed_transfers, route)

      capacity_constrained
    end

    # Combine compatible transfers to reduce shipping costs
    def combine_compatible_transfers(transfers)
      combined = []

      # Group by source and target settlements
      transfer_groups = transfers.group_by do |t|
        [t[:source_settlement].id, t[:target_settlement].id]
      end

      transfer_groups.each do |route_key, route_transfers|
        # Combine resources from same route
        combined_resources = combine_route_resources(route_transfers)

        # Create combined transfer
        combined << {
          id: generate_transfer_id,
          source_settlement: route_transfers.first[:source_settlement],
          target_settlement: route_transfers.first[:target_settlement],
          resources: combined_resources,
          total_quantity: combined_resources.values.sum,
          priority: highest_priority(route_transfers),
          transport_cost: calculate_combined_transport_cost(route_transfers),
          estimated_duration: calculate_transfer_duration(route_key)
        }
      end

      combined
    end

    # Optimize timing of transfers
    def optimize_transfer_timing(transfers, route)
      # Schedule transfers to avoid congestion and minimize costs
      scheduled = []

      transfers.each do |transfer|
        optimal_time = find_optimal_transfer_time(transfer, scheduled, route)
        scheduled_transfer = transfer.merge(scheduled_time: optimal_time)
        scheduled << scheduled_transfer
      end

      scheduled
    end

    # Apply capacity constraints
    def apply_capacity_constraints(transfers, route)
      constrained = []
      route_capacity = get_route_capacity(route)

      transfers.each do |transfer|
        if transfer[:total_quantity] <= route_capacity
          constrained << transfer
        else
          # Split large transfers
          split_transfers = split_large_transfer(transfer, route_capacity)
          constrained.concat(split_transfers)
        end
      end

      constrained
    end

    # Schedule a single transfer
    def schedule_transfer(transfer)
      # Reserve resources at source
      source_manager = find_settlement_manager(transfer[:source_settlement])
      if source_manager&.reserve_resources(transfer[:resource], transfer[:quantity])
        # Create active transfer record
        active_transfer = transfer.merge(
          status: :scheduled,
          scheduled_at: Time.current,
          estimated_completion: Time.current + transfer[:estimated_duration],
          progress: 0
        )

        @active_transfers << active_transfer

        Rails.logger.info "[LogisticsCoordinator] Scheduled transfer #{transfer[:id]} from #{transfer[:source_settlement].name} to #{transfer[:target_settlement].name}"
      else
        Rails.logger.error "[LogisticsCoordinator] Failed to reserve resources for transfer #{transfer[:id]}"
      end
    end

    # Helper methods

    def generate_route_key(transfer)
      "#{transfer[:source_settlement].id}_#{transfer[:target_settlement].id}"
    end

    def combine_route_resources(transfers)
      combined = {}

      transfers.each do |transfer|
        resource = transfer[:resource]
        quantity = transfer[:quantity]

        combined[resource] ||= 0
        combined[resource] += quantity
      end

      combined
    end

    def highest_priority(transfers)
      priorities = transfers.map { |t| t[:priority] }
      priority_values = priorities.map { |p| priority_value(p) }

      priority_values.max == 4 ? :critical :
      priority_values.max == 3 ? :high :
      priority_values.max == 2 ? :medium : :low
    end

    def calculate_combined_transport_cost(transfers)
      # Base cost plus per-unit cost
      base_cost = 50
      per_unit_cost = 0.1

      total_quantity = transfers.sum { |t| t[:quantity] }
      total_cost = base_cost + (total_quantity * per_unit_cost)

      # Apply route multiplier
      route_multiplier = calculate_route_multiplier(transfers.first)
      (total_cost * route_multiplier).round
    end

    def calculate_transfer_duration(route_key)
      # Simplified duration calculation
      case route_key
      when /mars.*luna|luna.*mars/ then 2.hours
      when /earth.*mars|mars.*earth/ then 6.months
      else 1.month
      end
    end

    def find_optimal_transfer_time(transfer, scheduled_transfers, route)
      # Find time that avoids conflicts and minimizes costs
      base_time = Time.current

      # Check for route congestion
      route_transfers = scheduled_transfers.select do |t|
        generate_route_key(t) == route
      end

      if route_transfers.size >= @transport_capacity[:max_concurrent_transfers]
        # Delay to next available slot
        latest_completion = route_transfers.map { |t| t[:estimated_completion] }.max
        base_time = latest_completion + 1.hour
      end

      base_time
    end

    def get_route_capacity(route)
      # Get capacity for specific route
      case route
      when /mars.*luna|luna.*mars/ then @transport_capacity[:mars_luna_capacity]
      when /earth.*mars|mars.*earth/ then @transport_capacity[:earth_mars_capacity]
      else 200
      end
    end

    def split_large_transfer(transfer, max_capacity)
      # Split transfer into smaller chunks
      total_quantity = transfer[:total_quantity]
      num_chunks = (total_quantity / max_capacity.to_f).ceil

      chunks = []
      quantity_per_chunk = (total_quantity / num_chunks.to_f).round

      num_chunks.times do |i|
        chunk_quantity = [quantity_per_chunk, total_quantity - (i * quantity_per_chunk)].min

        chunk = transfer.merge(
          id: "#{transfer[:id]}_chunk_#{i + 1}",
          total_quantity: chunk_quantity,
          resources: scale_resources(transfer[:resources], chunk_quantity, total_quantity)
        )

        chunks << chunk
      end

      chunks
    end

    def scale_resources(resources, chunk_quantity, total_quantity)
      ratio = chunk_quantity / total_quantity.to_f

      scaled = {}
      resources.each do |resource, quantity|
        scaled[resource] = (quantity * ratio).round
      end

      scaled
    end

    def calculate_route_multiplier(transfer)
      # Different routes have different cost multipliers
      source_body = transfer[:source_settlement].location&.celestial_body
      target_body = transfer[:target_settlement].location&.celestial_body

      if source_body == target_body
        1.0  # Same body
      elsif (source_body.is_a?(Planet) && target_body.is_a?(Moon) && target_body.planet == source_body) ||
            (source_body.is_a?(Moon) && target_body.is_a?(Planet) && source_body.planet == target_body)
        1.2  # Planet-moon transfer
      else
        2.0  # Inter-body transfer
      end
    end

    def priority_value(priority)
      case priority
      when :critical then 4
      when :high then 3
      when :medium then 2
      when :low then 1
      else 0
      end
    end

    def find_settlement_manager(settlement)
      # This would need to be implemented to find the settlement manager
      # For now, return nil
      nil
    end

    def generate_transfer_id
      "transfer_#{Time.current.to_i}_#{rand(10000)}"
    end

    def calculate_average_transport_cost
      return 0 if @active_transfers.empty?

      total_cost = @active_transfers.sum { |t| t[:transport_cost] || 0 }
      total_cost / @active_transfers.size.to_f
    end

    def calculate_capacity_utilization
      # Calculate how much of available capacity is being used
      active_quantity = @active_transfers.sum { |t| t[:total_quantity] || 0 }
      max_capacity = @transport_capacity.values.select { |v| v.is_a?(Numeric) }.sum

      max_capacity > 0 ? active_quantity / max_capacity.to_f : 0
    end
  end
end