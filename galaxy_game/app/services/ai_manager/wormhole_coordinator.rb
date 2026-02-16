# app/services/ai_manager/wormhole_coordinator.rb
module AIManager
  class WormholeCoordinator
    def initialize(shared_context)
      @shared_context = shared_context
    end

    # Calculate optimal multi-system expansion routes
    def calculate_optimal_routes(current_system, expansion_targets, available_resources)
      Rails.logger.info "[WormholeCoordinator] Calculating optimal routes from #{current_system[:identifier]} to #{expansion_targets.length} targets"

      # Build wormhole network graph
      network_graph = build_wormhole_network_graph(current_system)

      # Calculate route options for each target
      route_options = expansion_targets.map do |target|
        calculate_route_options(current_system, target, network_graph, available_resources)
      end

      # Optimize multi-system coordination
      optimized_routes = optimize_multi_system_routes(route_options, available_resources)

      # Calculate economic benefits
      economic_analysis = calculate_route_economics(optimized_routes, available_resources)

      {
        route_options: route_options,
        optimized_routes: optimized_routes,
        economic_analysis: economic_analysis,
        network_utilization: calculate_network_utilization(optimized_routes, network_graph),
        coordination_plan: generate_coordination_plan(optimized_routes)
      }
    end

    # Coordinate parallel settlement development across systems
    def coordinate_parallel_development(settlement_plans, wormhole_network)
      Rails.logger.info "[WormholeCoordinator] Coordinating parallel development for #{settlement_plans.length} settlements"

      # Analyze interdependencies
      interdependencies = analyze_settlement_interdependencies(settlement_plans, wormhole_network)

      # Optimize development sequencing
      development_sequence = optimize_development_sequence(settlement_plans, interdependencies)

      # Calculate resource sharing opportunities
      resource_sharing = calculate_resource_sharing_opportunities(settlement_plans, wormhole_network)

      # Generate coordination timeline
      coordination_timeline = generate_coordination_timeline(development_sequence, resource_sharing)

      {
        interdependencies: interdependencies,
        development_sequence: development_sequence,
        resource_sharing: resource_sharing,
        coordination_timeline: coordination_timeline,
        parallel_efficiency: calculate_parallel_efficiency(coordination_timeline)
      }
    end

    private

    def build_wormhole_network_graph(current_system)
      # Get all wormhole connections from current system
      wormholes = find_connected_wormholes(current_system)

      graph = { nodes: {}, edges: [] }

      # Add current system as starting node
      graph[:nodes][current_system[:identifier]] = {
        system: current_system,
        wormhole_capacity: current_system[:wormhole_capacity] || 0,
        connected_systems: []
      }

      # Build graph from wormhole connections
      wormholes.each do |wormhole|
        system_a = wormhole.solar_system_a
        system_b = wormhole.solar_system_b

        # Add nodes if not present
        [system_a, system_b].each do |system|
          next if graph[:nodes][system.identifier]

          graph[:nodes][system.identifier] = {
            system: system,
            wormhole_capacity: system.wormhole_capacity || 0,
            connected_systems: []
          }
        end

        # Add edge between systems
        edge = {
          from: system_a.identifier,
          to: system_b.identifier,
          wormhole: wormhole,
          distance: 1, # Direct wormhole connection
          capacity: wormhole.mass_limit,
          stability: wormhole.stability,
          traversable: wormhole.safe_for_travel?,
          cost: calculate_wormhole_traversal_cost(wormhole)
        }

        graph[:edges] << edge

        # Update connected systems
        graph[:nodes][system_a.identifier][:connected_systems] << system_b.identifier
        graph[:nodes][system_b.identifier][:connected_systems] << system_a.identifier
      end

      graph
    end

    def calculate_route_options(start_system, target_system, network_graph, available_resources)
      start_id = start_system[:identifier]
      target_id = target_system[:identifier]

      return { direct: true, routes: [] } if start_id == target_id

      # Find all possible routes using BFS
      routes = find_all_routes(network_graph, start_id, target_id)

      # Evaluate each route
      evaluated_routes = routes.map do |route|
        evaluate_route(route, network_graph, available_resources)
      end

      # Sort by preference score
      evaluated_routes.sort_by { |r| -r[:preference_score] }

      {
        target_system: target_system,
        direct_connection: routes.any? { |r| r.length == 2 }, # Direct wormhole
        route_count: routes.length,
        best_route: evaluated_routes.first,
        alternative_routes: evaluated_routes[1..2] || [], # Top 3 routes
        all_routes: evaluated_routes
      }
    end

    def find_all_routes(graph, start_id, target_id, max_depth = 5)
      routes = []
      visited = Set.new
      queue = [[start_id]]

      while queue.any?
        current_route = queue.shift
        current_node = current_route.last

        next if visited.include?(current_node) && current_route.length > 1
        visited.add(current_node)

        if current_node == target_id
          routes << current_route
          next
        end

        # Stop if route too long
        next if current_route.length >= max_depth

        # Find connected nodes
        connected_nodes = graph[:nodes][current_node][:connected_systems]
        connected_nodes.each do |next_node|
          next if current_route.include?(next_node) # Avoid cycles
          queue << (current_route + [next_node])
        end
      end

      routes
    end

    def evaluate_route(route, graph, available_resources)
      total_distance = route.length - 1
      total_cost = 0
      total_time = 0
      bottlenecks = []
      reliability_score = 1.0

      # Evaluate each hop
      route.each_cons(2) do |from_id, to_id|
        edge = graph[:edges].find { |e| (e[:from] == from_id && e[:to] == to_id) || (e[:from] == to_id && e[:to] == from_id) }

        if edge
          total_cost += edge[:cost]
          total_time += calculate_traversal_time(edge)

          # Check for bottlenecks
          if edge[:capacity] < available_resources[:mass_requirements]
            bottlenecks << { hop: "#{from_id}->#{to_id}", capacity: edge[:capacity], required: available_resources[:mass_requirements] }
          end

          # Adjust reliability
          reliability_score *= edge[:stability] == 'stable' ? 0.95 : 0.7
          reliability_score *= edge[:traversable] ? 1.0 : 0.3
        end
      end

      # Calculate preference score (lower is better)
      preference_score = total_cost * 0.4 + total_time * 0.3 + total_distance * 0.2 + (bottlenecks.any? ? 1000 : 0) + (1 - reliability_score) * 500

      {
        route: route,
        total_distance: total_distance,
        total_cost: total_cost,
        total_time: total_time,
        reliability_score: reliability_score,
        bottlenecks: bottlenecks,
        preference_score: preference_score,
        feasible: bottlenecks.empty? && reliability_score > 0.5
      }
    end

    def optimize_multi_system_routes(route_options, available_resources)
      # Use greedy algorithm to select optimal routes that minimize conflicts
      selected_routes = []
      used_wormholes = Set.new

      # Sort targets by priority (could be based on economic value, strategic importance, etc.)
      prioritized_targets = route_options.sort_by do |option|
        best_route = option[:best_route]
        next 999999 unless best_route && best_route[:feasible]

        # Priority based on route efficiency and target value
        priority_score = best_route[:preference_score] || 1000
        priority_score -= (option[:target_system][:economic_value] || 1000) * 0.1
        priority_score
      end

      prioritized_targets.each do |option|
        best_route = option[:best_route]
        next unless best_route && best_route[:feasible]

        # Check for wormhole conflicts
        route_wormholes = extract_route_wormholes(best_route[:route], route_options.find { |o| o[:target_system] == option[:target_system] })

        conflicts = route_wormholes.any? { |wh| used_wormholes.include?(wh) }
        next if conflicts && !can_schedule_concurrently(route_wormholes, used_wormholes)

        # Select this route
        selected_routes << {
          target: option[:target_system],
          route: best_route,
          wormholes_used: route_wormholes,
          scheduled_time: calculate_route_schedule(best_route, used_wormholes)
        }

        # Mark wormholes as used
        route_wormholes.each { |wh| used_wormholes.add(wh) }
      end

      selected_routes
    end

    def calculate_route_economics(routes, available_resources)
      total_transport_cost = routes.sum { |r| r[:route][:total_cost] }
      total_time_cost = routes.sum { |r| r[:route][:total_time] } * 1000 # Time value in GCC
      setup_cost = routes.length * 50000 # Base setup cost per route

      total_cost = total_transport_cost + total_time_cost + setup_cost

      # Calculate benefits
      economic_benefits = routes.sum do |route|
        target_value = route[:target][:economic_value] || 100000
        accessibility_multiplier = 1.0 / ((route[:route][:total_distance] || 1) + 1)
        target_value * accessibility_multiplier
      end

      roi_years = total_cost > 0 ? total_cost / (economic_benefits * 0.1) : 0

      {
        total_transport_cost: total_transport_cost,
        total_time_cost: total_time_cost,
        setup_cost: setup_cost,
        total_cost: total_cost,
        economic_benefits: economic_benefits,
        net_present_value: economic_benefits - total_cost,
        roi_years: roi_years,
        benefit_cost_ratio: economic_benefits / total_cost.to_f
      }
    end

    def calculate_network_utilization(routes, graph)
      wormhole_usage = Hash.new(0)

      routes.each do |route|
        route[:wormholes_used].each do |wormhole_id|
          wormhole_usage[wormhole_id] += 1
        end
      end

      utilization_stats = wormhole_usage.map do |wormhole_id, usage_count|
        edge = graph[:edges].find { |e| e[:wormhole].id == wormhole_id }
        capacity = edge ? edge[:capacity] : 0

        {
          wormhole_id: wormhole_id,
          usage_count: usage_count,
          capacity: capacity,
          utilization_percentage: capacity > 0 ? (usage_count / capacity.to_f) * 100 : 0
        }
      end

      {
        wormhole_usage: wormhole_usage,
        utilization_stats: utilization_stats,
        bottleneck_wormholes: utilization_stats.select { |stat| stat[:utilization_percentage] > 80 },
        average_utilization: utilization_stats.sum { |s| s[:utilization_percentage] } / utilization_stats.length.to_f
      }
    end

    def generate_coordination_plan(routes)
      # Group routes by timeline phases
      phases = {
        immediate: [],    # Within 1 month
        short_term: [],   # 1-6 months
        medium_term: [],  # 6-18 months
        long_term: []     # 18+ months
      }

      routes.each do |route|
        schedule_time = route[:scheduled_time]
        phase = case schedule_time
                when 0..30 then :immediate
                when 31..180 then :short_term
                when 181..540 then :medium_term
                else :long_term
                end

        phases[phase] << route
      end

      # Generate coordination requirements
      coordination_requirements = calculate_coordination_requirements(phases)

      {
        phases: phases,
        coordination_requirements: coordination_requirements,
        critical_path: identify_critical_path(routes),
        resource_dependencies: identify_resource_dependencies(routes)
      }
    end

    # Helper methods
    def find_connected_wormholes(system)
      system_id = system[:id] || system[:identifier]
      Wormhole.where(solar_system_a_id: system_id).or(Wormhole.where(solar_system_b_id: system_id))
    end

    def calculate_wormhole_traversal_cost(wormhole)
      base_cost = 10000 # Base GCC cost

      # Adjust for stability
      stability_multiplier = case wormhole.stability
                            when 'stable' then 1.0
                            when 'stabilizing' then 1.5
                            else 2.0
                            end

      # Adjust for type
      type_multiplier = case wormhole.wormhole_type
                       when 'traversable' then 1.0
                       when 'one_way' then 1.3
                       else 3.0 # non_traversable
                       end

      (base_cost * stability_multiplier * type_multiplier).to_i
    end

    def calculate_traversal_time(edge)
      base_time = 24 # hours

      # Adjust for stability
      stability_multiplier = edge[:stability] == 'stable' ? 1.0 : 2.0

      # Adjust for distance (each hop adds time)
      distance_multiplier = 1.0 # Direct wormhole

      (base_time * stability_multiplier * distance_multiplier).to_i
    end

    def extract_route_wormholes(route, route_option)
      # This is a simplified implementation - in reality would need to map route hops to wormhole IDs
      # For now, return mock wormhole IDs based on route length
      (1..(route.length - 1)).map { |i| "wormhole_#{route[i-1]}_#{route[i]}" }
    end

    def can_schedule_concurrently(new_wormholes, used_wormholes)
      # Simple check - allow concurrency if less than 50% overlap
      overlap = (new_wormholes & used_wormholes).length
      overlap < (new_wormholes.length * 0.5)
    end

    def calculate_route_schedule(route, used_wormholes)
      # Simple scheduling - add delay based on conflicts
      base_time = route[:total_time]
      conflict_delay = used_wormholes.any? { |wh| route[:wormholes_used].include?(wh) } ? 168 : 0 # 1 week delay

      base_time + conflict_delay
    end

    def analyze_settlement_interdependencies(settlement_plans, wormhole_network)
      # Analyze how settlements depend on each other for resources, transportation, etc.
      interdependencies = []

      settlement_plans.each do |plan_a|
        settlement_plans.each do |plan_b|
          next if plan_a == plan_b

          dependency = analyze_pair_interdependency(plan_a, plan_b, wormhole_network)
          interdependencies << dependency if dependency
        end
      end

      interdependencies
    end

    def analyze_pair_interdependency(plan_a, plan_b, wormhole_network)
      # Check if systems are connected
      system_a = plan_a[:target_system]
      system_b = plan_b[:target_system]

      connection = find_wormhole_connection(system_a, system_b, wormhole_network)

      return nil unless connection

      # Analyze resource dependencies
      resource_overlap = calculate_resource_overlap(plan_a, plan_b)
      transport_dependency = calculate_transport_dependency(plan_a, plan_b, connection)

      if resource_overlap > 0.3 || transport_dependency > 0.5
        {
          settlement_a: plan_a[:settlement_id],
          settlement_b: plan_b[:settlement_id],
          connection_type: :wormhole,
          resource_overlap: resource_overlap,
          transport_dependency: transport_dependency,
          coordination_priority: [resource_overlap, transport_dependency].max
        }
      end
    end

    def optimize_development_sequence(settlement_plans, interdependencies)
      # Use topological sort based on interdependencies
      # Simplified implementation - sort by economic value and dependencies

      sorted_plans = settlement_plans.sort_by do |plan|
        economic_value = plan[:economic_value] || 1000
        dependency_penalty = interdependencies.count { |dep| dep[:settlement_b] == plan[:settlement_id] } * 10000

        -(economic_value - dependency_penalty)
      end

      sorted_plans.map.with_index do |plan, index|
        {
          settlement: plan,
          sequence_position: index + 1,
          dependencies_satisfied: check_dependencies_satisfied(plan, sorted_plans[0...index], interdependencies)
        }
      end
    end

    def calculate_resource_sharing_opportunities(settlement_plans, wormhole_network)
      opportunities = []

      settlement_plans.each do |plan_a|
        settlement_plans.each do |plan_b|
          next if plan_a == plan_b

          sharing_opportunity = analyze_resource_sharing(plan_a, plan_b, wormhole_network)
          opportunities << sharing_opportunity if sharing_opportunity
        end
      end

      opportunities.sort_by { |opp| -opp[:potential_savings] }
    end

    def generate_coordination_timeline(development_sequence, resource_sharing)
      timeline = []
      current_time = 0

      development_sequence.each do |seq_item|
        settlement = seq_item[:settlement]

        # Calculate development time
        base_time = settlement[:estimated_completion_days] || 365
        parallel_bonus = calculate_parallel_bonus(settlement, resource_sharing, current_time)

        actual_time = [base_time - parallel_bonus, base_time * 0.5].max # Minimum 50% of base time

        timeline << {
          settlement: settlement[:settlement_id],
          start_time: current_time,
          end_time: current_time + actual_time,
          parallel_savings: parallel_bonus,
          resource_sharing_active: parallel_bonus > 0
        }

        current_time += actual_time
      end

      timeline
    end

    def calculate_parallel_efficiency(timeline)
      total_duration = timeline.last[:end_time]
      sequential_duration = timeline.sum { |item| item[:end_time] - item[:start_time] }

      efficiency = sequential_duration / total_duration.to_f

      {
        total_duration: total_duration,
        sequential_duration: sequential_duration,
        efficiency_ratio: efficiency,
        time_saved_percentage: (1 - total_duration / sequential_duration.to_f) * 100
      }
    end

    # Additional helper methods would be implemented here
    def find_wormhole_connection(system_a, system_b, network)
      # Implementation for finding connection between two systems
      nil # Placeholder
    end

    def calculate_resource_overlap(plan_a, plan_b)
      # Implementation for calculating resource overlap between plans
      0.0 # Placeholder
    end

    def calculate_transport_dependency(plan_a, plan_b, connection)
      # Implementation for calculating transport dependency
      0.0 # Placeholder
    end

    def check_dependencies_satisfied(plan, completed_plans, interdependencies)
      # Implementation for checking if dependencies are satisfied
      true # Placeholder
    end

    def analyze_resource_sharing(plan_a, plan_b, network)
      # Implementation for analyzing resource sharing opportunities
      nil # Placeholder
    end

    def calculate_parallel_bonus(settlement, resource_sharing, current_time)
      # Implementation for calculating parallel development bonus
      0 # Placeholder
    end

    def calculate_coordination_requirements(phases)
      # Implementation for calculating coordination requirements
      {} # Placeholder
    end

    def identify_critical_path(routes)
      # Implementation for identifying critical path
      [] # Placeholder
    end

    def identify_resource_dependencies(routes)
      # Implementation for identifying resource dependencies
      [] # Placeholder
    end
  end
end